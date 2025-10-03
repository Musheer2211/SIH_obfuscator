// obfuscator_with_bogus.cpp
#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/Support/raw_ostream.h"
#include <memory>

using namespace llvm;

static Function *getOrCreateOpaqueTrue(Module &M) {
    LLVMContext &Ctx = M.getContext();
    FunctionType *ft = FunctionType::get(Type::getInt1Ty(Ctx), {}, /*isVarArg=*/false);
    FunctionCallee fc = M.getOrInsertFunction("__opaque_true", ft);
    Function *f = dyn_cast<Function>(fc.getCallee());
    if (!f) return nullptr;
    if (!f->empty()) return f;
    BasicBlock *bb = BasicBlock::Create(Ctx, "entry", f);
    IRBuilder<> B(bb);
    f->addFnAttr(Attribute::NoInline);
    B.CreateRet(ConstantInt::getTrue(Ctx));
    return f;
}

// Create or return a global i32 used as a volatile sink for bogus stores.
// Volatile store prevents the optimizer from removing the bogus code.
static GlobalVariable *getOrCreateObfSink(Module &M) {
    LLVMContext &Ctx = M.getContext();
    Type *I32 = Type::getInt32Ty(Ctx);
    GlobalVariable *G = M.getGlobalVariable("__obf_sink");
    if (G) return G;
    Constant *Zero = ConstantInt::get(I32, 0);
    // ExternalLinkage so it won't be removed by MOdules with LTO maybe; adjust as needed.
    G = new GlobalVariable(M, I32, /*isConstant=*/false, GlobalValue::ExternalLinkage, Zero, "__obf_sink");
    return G;
}

// Insert a small bogus computation at function entry, guarded by opaque pred.
// The bogus code computes some values and does a volatile store to the global sink.
static void insertBogusAtEntry(Function &F, GlobalVariable *sink, Function *opaque) {
    if (F.isDeclaration()) return;
    // Find insertion point: after alloca area (first non-alloca instruction in entry block)
    BasicBlock &entry = F.getEntryBlock();
    Instruction *insertPoint = entry.getFirstNonPHI(); // safe for basic blocks with allocas
    // If still at beginning, use first instruction
    if (!insertPoint) insertPoint = &*entry.begin();

    // Split the entry into two so we can guard bogus code behind a conditional
    // We'll split at the insertion point so bogus code runs after allocations.
    BasicBlock *cont = entry.splitBasicBlock(insertPoint, entry.getName() + ".entry.cont");
    // Remove the unconditional branch created by splitBasicBlock
    entry.getTerminator()->eraseFromParent();

    IRBuilder<> B(&entry);
    // call opaque predicate
    CallInst *ci = B.CreateCall(opaque);
    ci->setTailCall(false);

    // Make two bogus blocks
    Function *parent = &F;
    BasicBlock *altTrue  = BasicBlock::Create(F.getContext(), "bogus.true", parent);
    BasicBlock *altFalse = BasicBlock::Create(F.getContext(), "bogus.false", parent);

    // In both branches, do some bogus arithmetic and volatile store to sink, then jump to cont
    // altTrue
    IRBuilder<> BT(altTrue);
    // Example bogus computations
    Value *a = ConstantInt::get(Type::getInt32Ty(F.getContext()), 0x1234);
    Value *b = ConstantInt::get(Type::getInt32Ty(F.getContext()), 0x5678);
    Value *t1 = BT.CreateAdd(a, b, "bog_add");
    // store volatile t1 -> sink
    BT.CreateStore(t1, sink, true /*isVolatile*/);
    BT.CreateBr(cont);

    // altFalse
    IRBuilder<> BF(altFalse);
    Value *c = ConstantInt::get(Type::getInt32Ty(F.getContext()), 0x9abc);
    Value *d = ConstantInt::get(Type::getInt32Ty(F.getContext()), 0xdef0);
    Value *t2 = BF.CreateMul(c, d, "bog_mul");
    BF.CreateStore(t2, sink, true /*isVolatile*/);
    BF.CreateBr(cont);

    // Branch based on opaque predicate
    B.CreateCondBr(ci, altTrue, altFalse);
}

// Optionally: insert bogus code inside basic blocks (before terminators)
static void insertBogusInBlocks(Function &F, GlobalVariable *sink, Function *opaque) {
    SmallVector<BasicBlock*, 8> blocks;
    for (BasicBlock &BB : F) blocks.push_back(&BB);
    for (BasicBlock *BB : blocks) {
        Instruction *term = BB->getTerminator();
        if (!term) continue;
        // Avoid trivial cases and skip if BB is tiny
        if (BB->size() <= 1) continue;
        // Insert just before terminator
        IRBuilder<> B(term);
        // call opaque
        CallInst *ci = B.CreateCall(opaque);
        ci->setTailCall(false);
        // create small conditional sequence inline
        // if opaque -> do a volatile store of an add; else -> do a volatile store of a mul
        BasicBlock *cont = BB->splitBasicBlock(term, BB->getName() + ".cont2");
        BB->getTerminator()->eraseFromParent();

        BasicBlock *alt1 = BasicBlock::Create(F.getContext(), "blk.alt1", F);
        BasicBlock *alt2 = BasicBlock::Create(F.getContext(), "blk.alt2", F);

        IRBuilder<> B1(alt1);
        Value *v1 = B1.CreateAdd(ConstantInt::get(Type::getInt32Ty(F.getContext()), 7),
                                 ConstantInt::get(Type::getInt32Ty(F.getContext()), 11));
        B1.CreateStore(v1, sink, true);
        B1.CreateBr(cont);

        IRBuilder<> B2(alt2);
        Value *v2 = B2.CreateMul(ConstantInt::get(Type::getInt32Ty(F.getContext()), 3),
                                 ConstantInt::get(Type::getInt32Ty(F.getContext()), 5));
        B2.CreateStore(v2, sink, true);
        B2.CreateBr(cont);

        IRBuilder<> BI(BB);
        BI.CreateCondBr(ci, alt1, alt2);
    }
}

struct SimpleObfPass : public PassInfoMixin<SimpleObfPass> {
    PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM) {
        Function *opaque = getOrCreateOpaqueTrue(M);
        if (!opaque) return PreservedAnalyses::none();

        GlobalVariable *sink = getOrCreateObfSink(M);

        errs() << "SimpleObfPass: running on module: " << M.getName() << "\n";

        SmallVector<Function *, 16> targets;
        for (Function &F : M) {
            if (F.isDeclaration()) continue;
            // skip our helpers
            if (&F == opaque) continue;
            if (F.getName() == "__obf_sink") continue;
            targets.push_back(&F);
        }

        for (Function *F : targets) {
            // Insert bogus at entry
            insertBogusAtEntry(*F, sink, opaque);

            // Optionally, also insert bogus inside blocks
            insertBogusInBlocks(*F, sink, opaque);
        }

        return PreservedAnalyses::none();
    }
};

// plugin registration (unchanged)
extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
    return {LLVM_PLUGIN_API_VERSION, "SimpleObfPass", LLVM_VERSION_STRING,
            [](PassBuilder &PB) {
                PB.registerPipelineParsingCallback(
                    [](StringRef Name, ModulePassManager &MPM, ArrayRef<PassBuilder::PipelineElement> Pipeline) -> bool {
                        (void)Pipeline;
                        if (Name == "simple-obf") {
                            MPM.addPass(SimpleObfPass());
                            return true;
                        }
                        return false;
                    });
            }};
}
