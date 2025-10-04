#!/bin/bash
#
# ✅ Cross-Platform LLVM Obfuscation Build Script
# - Generates target-specific IR for Linux & Windows
# - Runs LLVM pass
# - Produces obfuscated executables for both
#
# Requirements:
#   - LLVM & Clang installed (Linux)
#   - MinGW cross toolchain (for Windows build): sudo apt install mingw-w64
#

set -e

############################################################
# 1. CONFIGURATION
############################################################

LLVM_BIN=/usr/bin
PLUGIN_DIR=/mnt/c/Users/mushe/Desktop/Musheer_CS1/SIH/SimpleObfPass/build
PASSNAME="simple-obf"
PLUGIN_PATH="$PLUGIN_DIR/SimpleObfPass.so"
SRC=../test.c

LINUX_TRIPLE="x86_64-pc-linux-gnu"
WINDOWS_TRIPLE="x86_64-w64-windows-gnu"

OUTDIR="obfuscation_run"
LINUX_DIR="$OUTDIR/linux"
WINDOWS_DIR="$OUTDIR/windows"

############################################################
# 2. PREP
############################################################

echo ">> Initializing..."
if [ ! -f "$PLUGIN_PATH" ]; then
    echo "!! Plugin not found: $PLUGIN_PATH"
    exit 1
fi

if [ ! -f "$SRC" ]; then
    echo "!! Source file not found: $SRC"
    exit 1
fi

rm -rf "$OUTDIR"
mkdir -p "$LINUX_DIR" "$WINDOWS_DIR"

############################################################
# 3. LINUX PIPELINE
############################################################
echo "--------------------------------------------------"
echo ">> 🐧 Building for Linux..."

# IR Generation (Linux)
$LLVM_BIN/clang --target=$LINUX_TRIPLE -S -emit-llvm -O0 -fno-inline -g $SRC -o $LINUX_DIR/test.linux.ll

# Run obfuscation pass
$LLVM_BIN/opt -load-pass-plugin="$PLUGIN_PATH" -passes=$PASSNAME -S \
    $LINUX_DIR/test.linux.ll -o $LINUX_DIR/test.linux.obf.ll 2> $LINUX_DIR/transformation.log

# Lower to object file
$LLVM_BIN/llc -filetype=obj -o $LINUX_DIR/test.linux.o $LINUX_DIR/test.linux.obf.ll

# Link
$LLVM_BIN/clang -no-pie $LINUX_DIR/test.linux.o -o $LINUX_DIR/test.linux

# Build original for comparison
$LLVM_BIN/clang --target=$LINUX_TRIPLE $SRC -o $LINUX_DIR/test.linux.original

echo ">> ✅ Linux build complete: $LINUX_DIR/test.linux"

############################################################
# 4. WINDOWS PIPELINE
############################################################
echo "--------------------------------------------------"
echo ">> 🪟 Building for Windows..."

# IR Generation (Windows)
$LLVM_BIN/clang --target=$WINDOWS_TRIPLE -S -emit-llvm -O0 -fno-inline -g $SRC -o $WINDOWS_DIR/test.windows.ll

# Run obfuscation pass
$LLVM_BIN/opt -load-pass-plugin="$PLUGIN_PATH" -passes=$PASSNAME -S \
    $WINDOWS_DIR/test.windows.ll -o $WINDOWS_DIR/test.windows.obf.ll 2> $WINDOWS_DIR/transformation.log

# Lower to Windows object file
$LLVM_BIN/llc -filetype=obj --mtriple=$WINDOWS_TRIPLE -o $WINDOWS_DIR/test.windows.o $WINDOWS_DIR/test.windows.obf.ll

# Link using MinGW
$LLVM_BIN/clang --target=$WINDOWS_TRIPLE $WINDOWS_DIR/test.windows.o -o $WINDOWS_DIR/test.windows.exe

# Original Windows build
$LLVM_BIN/clang --target=$WINDOWS_TRIPLE $SRC -o $WINDOWS_DIR/test.windows.original.exe

echo ">> ✅ Windows build complete: $WINDOWS_DIR/test.windows.exe"

############################################################
# 5. REPORT GENERATION
############################################################
echo "--------------------------------------------------"
echo ">> 📝 Generating build report..."

REPORT=$OUTDIR/report.md

{
    echo "# 🛡️ LLVM Obfuscation Build Report"
    echo
    echo "**Date:** $(date)"
    echo
    echo "## Linux Transformation Log"
    echo '```'
    cat $LINUX_DIR/transformation.log
    echo '```'
    echo
    echo "## Windows Transformation Log"
    echo '```'
    cat $WINDOWS_DIR/transformation.log
    echo '```'
    echo
    echo "## Diff (Linux IR)"
    echo '```diff'
    diff -u $LINUX_DIR/test.linux.ll $LINUX_DIR/test.linux.obf.ll || true
    echo '```'
    echo
    echo "## Diff (Windows IR)"
    echo '```diff'
    diff -u $WINDOWS_DIR/test.windows.ll $WINDOWS_DIR/test.windows.obf.ll || true
    echo '```'
    echo
    echo "## Artifacts"
    echo "| Platform | Original | Obfuscated |"
    echo "|----------|----------|------------|"
    echo "| Linux    | $LINUX_DIR/test.linux.original | $LINUX_DIR/test.linux |"
    echo "| Windows  | $WINDOWS_DIR/test.windows.original.exe | $WINDOWS_DIR/test.windows.exe |"
} > $REPORT

echo ">> ✅ Report generated at: $REPORT"
echo "--------------------------------------------------"
echo "🎉 All builds completed successfully."
