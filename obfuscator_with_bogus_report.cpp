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

// Creates or finds a function that always returns true. Used as an opaque predicate.
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

// Creates or finds a global variable to act as a volatile sink for bogus computations.
static GlobalVariable *getOrCreateObfSink(Module &M) {
    LLVMContext &Ctx = M.getContext();
    Type *I32 = Type::getInt32Ty(Ctx);
    GlobalVariable *G = M.getGlobalVariable("__obf_sink");
    if (G) return G;
    Constant *Zero = ConstantInt::get(I32, 0);
    G = new GlobalVariable(M, I32, /*isConstant=*/false, GlobalValue::ExternalLinkage, Zero, "__obf_sink");
    return G;
}

// Inserts bogus control flow at the entry of a function.
static void insertBogusAtEntry(Function &F, GlobalVariable *sink, Function *opaque) {
    if (F.isDeclaration()) return;
    
    errs() << "  [Entry] Modifying entry of function: " << F.getName() << "\n";

    BasicBlock &entry = F.getEntryBlock();
    Instruction *insertPoint = entry.getFirstNonPHI();
    if (!insertPoint) insertPoint = &*entry.begin();

    // Split the entry block. The part with the original instructions is now in 'cont'.
    BasicBlock *cont = entry.splitBasicBlock(insertPoint, entry.getName() + ".entry.cont");
    errs() << "    - Split entry block '" << entry.getName() << "' into '" << cont->getName() << "'\n";
    
    // The unconditional branch created by splitBasicBlock is now the terminator of 'entry'.
    Instruction* oldTerminator = entry.getTerminator();
    
    // Create an IRBuilder to insert the call *before* the old terminator.
    IRBuilder<> B(oldTerminator);
    CallInst *ci = B.CreateCall(opaque);
    ci->setTailCall(false);

    // Create the bogus blocks that will contain pointless computations.
    BasicBlock *altTrue  = BasicBlock::Create(F.getContext(), "bogus.true", &F);
    BasicBlock *altFalse = BasicBlock::Create(F.getContext(), "bogus.false", &F);
    errs() << "    - Added bogus code blocks: '" << altTrue->getName() << "' and '" << altFalse->getName() << "'\n";
    
    // Populate the 'true' bogus block
    IRBuilder<> BT(altTrue);
    Value *t1 = BT.CreateAdd(ConstantInt::get(Type::getInt32Ty(F.getContext()), 0x1234),
                             ConstantInt::get(Type::getInt32Ty(F.getContext()), 0x5678), "bog_add");
    BT.CreateStore(t1, sink, true);
    BT.CreateBr(cont);

    // Populate the 'false' bogus block
    IRBuilder<> BF(altFalse);
    Value *t2 = BF.CreateMul(ConstantInt::get(Type::getInt32Ty(F.getContext()), 0x9abc),
                             ConstantInt::get(Type::getInt32Ty(F.getContext()), 0xdef0), "bog_mul");
    BF.CreateStore(t2, sink, true);
    BF.CreateBr(cont);

    // --- CRASH FIX ---
    // Safely replace the terminator. First, remove the old one.
    oldTerminator->eraseFromParent();
    // Then, create the new one at the end of the entry block.
    BranchInst::Create(altTrue, altFalse, ci, &entry);
    errs() << "    - Replaced original terminator with opaque conditional branch.\n";
}

// Inserts bogus control flow inside existing basic blocks.
static void insertBogusInBlocks(Function &F, GlobalVariable *sink, Function *opaque) {
    // Collect blocks first to avoid iterator invalidation.
    SmallVector<BasicBlock*, 8> blocks;
    for (BasicBlock &BB : F) blocks.push_back(&BB);

    for (BasicBlock *BB : blocks) {
        // Skip the entry block (already handled) and tiny blocks.
        if (BB->isEntryBlock()) continue;
        Instruction *term = BB->getTerminator();
        if (!term || BB->size() <= 2) continue;
        
        errs() << "  [Block] Modifying basic block: '" << BB->getName() << "' in function '" << F.getName() << "'\n";

        // Split the block right before its terminator. 'cont' will hold the original terminator.
        BasicBlock *cont = BB->splitBasicBlock(term, BB->getName() + ".cont2");
        errs() << "    - Split block '" << BB->getName() << "' into '" << cont->getName() << "'\n";
        
        // The original block 'BB' now has a new unconditional branch to 'cont'.
        Instruction* oldTerminator = BB->getTerminator();
        
        // Insert the opaque predicate call before this new branch.
        IRBuilder<> BI(oldTerminator);
        CallInst *ci = BI.CreateCall(opaque);
        ci->setTailCall(false);

        // Create the bogus blocks.
        BasicBlock *alt1 = BasicBlock::Create(F.getContext(), "blk.alt1", &F);
        BasicBlock *alt2 = BasicBlock::Create(F.getContext(), "blk.alt2", &F);
        errs() << "    - Added bogus code blocks: '" << alt1->getName() << "' and '" << alt2->getName() << "'\n";

        // Populate the first bogus block
        IRBuilder<> B1(alt1);
        Value *v1 = B1.CreateAdd(ConstantInt::get(Type::getInt32Ty(F.getContext()), 7), ConstantInt::get(Type::getInt32Ty(F.getContext()), 11));
        B1.CreateStore(v1, sink, true);
        B1.CreateBr(cont);

        // Populate the second bogus block
        IRBuilder<> B2(alt2);
        Value *v2 = B2.CreateMul(ConstantInt::get(Type::getInt32Ty(F.getContext()), 3), ConstantInt::get(Type::getInt32Ty(F.getContext()), 5));
        B2.CreateStore(v2, sink, true);
        B2.CreateBr(cont);
        
        // --- CRASH FIX ---
        // Safely replace the terminator. First, remove the old one.
        oldTerminator->eraseFromParent();
        // Then, create the new conditional branch at the end of the block.
        BranchInst::Create(alt1, alt2, ci, BB);
        errs() << "    - Replaced original terminator with opaque conditional branch.\n";
    }
}

// The main pass structure.
struct SimpleObfPass : public PassInfoMixin<SimpleObfPass> {
    PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM) {
        errs() << "==== SimpleObfPass Transformation Log ====\n";
        errs() << "Running on module: " << M.getName() << "\n\n";

        Function *opaque = getOrCreateOpaqueTrue(M);
        if (!opaque) return PreservedAnalyses::none();
        errs() << "-> Created/found helper function: '__opaque_true'\n";
        
        GlobalVariable *sink = getOrCreateObfSink(M);
        errs() << "-> Created/found global sink: '__obf_sink'\n\n";

        SmallVector<Function *, 16> targets;
        for (Function &F : M) {
            if (F.isDeclaration() || &F == opaque || F.getName() == "__obf_sink") {
                continue;
            }
            targets.push_back(&F);
        }

        for (Function *F : targets) {
            insertBogusAtEntry(*F, sink, opaque);
            insertBogusInBlocks(*F, sink, opaque);
        }
        
        errs() << "\n==== Log End ====\n";
        return PreservedAnalyses::none();
    }
};

// Plugin registration boilerplate.
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

