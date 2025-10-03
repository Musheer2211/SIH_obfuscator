# Adjust these two paths:
LLVM_BIN=/c/LLVM/bin                          # path to clang, opt, llc, llvm-objdump
PLUGIN=/c/Users/mushe/Desktop/Musheer_CS1/SIH/SimpleObfPass/build/libSimpleObfPass.dll
PASSNAME=simple-obf
WORKDIR=./obf_run
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# 1) Generate canonical original .ll (no plugin)
$LLVM_BIN/clang.exe -S -emit-llvm -O0 -fno-inline -g ../test.c -o test.original.ll
echo "==== original.ll (head) ===="; sed -n '1,120p' test.original.ll

# 2) Run opt with your plugin to produce obf.ll
$LLVM_BIN/opt.exe -load-pass-plugin="$PLUGIN" -passes="$PASSNAME" -S test.original.ll -o test.obf.ll
echo "==== obf.ll (head) ===="; sed -n '1,120p' test.obf.ll

# 3) Make objects from each IR
$LLVM_BIN/llc.exe -filetype=obj -o test.original.o test.original.ll
$LLVM_BIN/llc.exe -filetype=obj -o test.obf.o      test.obf.ll

# 4) Disassemble the objects (use llvm-objdump here)
$LLVM_BIN/llvm-objdump.exe -d test.original.o > orig.asm
$LLVM_BIN/llvm-objdump.exe -d test.obf.o      > obf.asm

# 5) Normalize (strip addresses/labels/comments) and diff
sed -E 's/^[[:space:]]*[0-9A-Fa-fx:]+[[:space:]]*//' orig.asm | sed 's/;.*$//' | sed '/^\s*$/d' > orig.norm
sed -E 's/^[[:space:]]*[0-9A-Fa-fx:]+[[:space:]]*//' obf.asm  | sed 's/;.*$//' | sed '/^\s*$/d' > obf.norm

echo "==== diff (first 200 lines) ===="
diff -u orig.norm obf.norm | sed -n '1,200p' || true

# 6) Optional: compile the two objects into executables (driver included in test.c)
$LLVM_BIN/clang.exe test.original.o -o test.original.exe || true
$LLVM_BIN/clang.exe test.obf.o      -o test.obf.exe      || true

# Run them to verify behavior is identical
echo "---- run original ----"
./test.original.exe || true
echo "---- run obfuscated ----"
./test.obf.exe || true
