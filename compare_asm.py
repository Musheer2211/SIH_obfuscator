#!/usr/bin/env python3
"""compare_asm.py
Produce a normalized assembly diff between an original and an obfuscated object file
(or between their corresponding assembly dumps) for a single function or all functions.

Usage examples:
  # Compare a single function using GNU objdump (recommended)
  python compare_asm.py --orig test.original.o --obf test.obf.o --func MyFunc --tool objdump

  # Compare all functions (may be noisy)
  python compare_asm.py --orig test.original.o --obf test.obf.o --func all --tool llvm-objdump

Options:
  --orig PATH        Path to original object (.o) or assembly (.s/.asm)
  --obf PATH         Path to obfuscated object or assembly
  --func NAME        Function name to compare (symbol name; use mangled name if needed). Use 'all' to compare everything.
  --tool TOOL        'objdump' (GNU) or 'llvm' (llvm-objdump). Default: auto-detect.
  --outdir DIR       Directory to write intermediate files and diffs. Default: ./compare_out
  --open             If VS Code 'code' is available, opens the two normalized asm files in a diff view.
  --keep             Keep intermediate files (by default they're kept anyway; use to inspect)
  --quiet            Suppress non-error prints
Notes:
 - For 'objdump' mode the script uses: objdump -d --disassemble=<SYM> -M intel <file>
 - For 'llvm' mode the script runs: llvm-objdump -d <file> and extracts the function block using pattern <SYM>:
 - If the supplied files are assembly (extensions .s/.asm/.ll), the script will skip objdump and use them directly.
 - If a function name contains characters that require quoting (C++ mangled), pass the mangled name as returned by `nm`/`llvm-nm`.
"""

import argparse
import os
import shutil
import subprocess
import sys
import difflib
import re
from pathlib import Path

def find_executable(names):
    for name in names:
        path = shutil.which(name)
        if path:
            return path
    return None

def is_asm_file(p: Path):
    return p.suffix.lower() in ('.s', '.asm', '.ll')

def run_cmd(cmd, cwd=None):
    proc = subprocess.run(cmd, shell=False, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return proc.returncode, proc.stdout, proc.stderr

def extract_with_objdump(objdump, infile, symbol, outpath):
    # GNU objdump supports --disassemble=SYMBOL
    cmd = [objdump, '-d', f'--disassemble={symbol}', '-M', 'intel', str(infile)]
    rc, out, err = run_cmd(cmd)
    if rc != 0:
        raise RuntimeError(f"objdump failed: {err.strip()}")
    Path(outpath).write_text(out, encoding='utf-8')
    return outpath

def extract_with_llvm(llvmobjdump, infile, symbol, outpath):
    # llvm-objdump may not accept --disassemble=symbol; instead dump all and extract block
    cmd = [llvmobjdump, '-d', str(infile)]
    rc, out, err = run_cmd(cmd)
    if rc != 0:
        raise RuntimeError(f"llvm-objdump failed: {err.strip()}")
    text = out
    # pattern like "<symbol>:" at line start
    pattern = re.compile(rf"^<{re.escape(symbol)}>:", re.MULTILINE)
    m = pattern.search(text)
    if not m:
        raise RuntimeError(f"symbol <{symbol}> not found in llvm-objdump output")
    start = m.start()
    # find next function label (line that starts with <...>:)
    next_func = re.search(r"^<[^>]+>:", text[m.end():], re.MULTILINE)
    end = m.end() + next_func.start() if next_func else len(text)
    snippet = text[start:end]
    Path(outpath).write_text(snippet, encoding='utf-8')
    return outpath

def normalize_asm_file(infile, outfile):
    # remove addresses, leading whitespace, and trailing comments, blank lines
    lines = Path(infile).read_text(encoding='utf-8').splitlines()
    norm = []
    for L in lines:
        # strip common leading address patterns: "  4005f4: 48 89 ..." or "0000000000000120 <+0>:    ..."
        s = re.sub(r'^\s*[0-9A-Fa-fx:<>._$-]+\s*', '', L)
        # remove comments starting with ';' or '#' or '//'
        s = re.split(r'\s[;#//]', s)[0]
        # collapse multiple spaces to single space
        s = re.sub(r'\s+', ' ', s).strip()
        if s:
            norm.append(s)
    Path(outfile).write_text('\n'.join(norm), encoding='utf-8')
    return outfile

def disasm_to_file(tool, infile, symbol, outpath):
    if tool == 'objdump':
        objdump = find_executable(['objdump', 'x86_64-w64-mingw32-objdump', 'mingw32-objdump'])
        if not objdump:
            raise RuntimeError("objdump not found in PATH")
        return extract_with_objdump(objdump, infile, symbol, outpath)
    else:
        llvmobjdump = find_executable(['llvm-objdump', 'llvm-objdump.exe', 'objdump'])
        if not llvmobjdump:
            raise RuntimeError("llvm-objdump not found in PATH")
        return extract_with_llvm(llvmobjdump, infile, symbol, outpath)

def assemble_if_asm(src: Path, out_obj: Path, llc=None):
    # If src is assembly (.s/.asm/.ll), optionally convert to obj via llc if needed (not used by default)
    raise NotImplementedError("assembly->obj conversion not implemented in this helper script")

def compare_text_files(a_path, b_path):
    a = Path(a_path).read_text(encoding='utf-8').splitlines()
    b = Path(b_path).read_text(encoding='utf-8').splitlines()
    diff = list(difflib.unified_diff(a, b, fromfile=a_path, tofile=b_path, lineterm=''))
    return diff

def main():
    parser = argparse.ArgumentParser(prog='compare_asm.py', description='Compare assembly between original and obfuscated object files.')
    parser.add_argument('--orig', required=True, help='Original object (.o) or assembly (.s/.asm/.ll)')
    parser.add_argument('--obf', required=True, help='Obfuscated object or assembly')
    parser.add_argument('--func', default='all', help="Function name to compare (symbol). Use 'all' to compare entire file.")
    parser.add_argument('--tool', choices=['objdump', 'llvm', 'auto'], default='auto', help="Which disassembler to use. 'auto' tries objdump then llvm-objdump.")
    parser.add_argument('--outdir', default='compare_out', help='Output directory')
    parser.add_argument('--open', action='store_true', help='Open diff in VS Code if available')
    parser.add_argument('--quiet', action='store_true', help='Less verbose output')
    args = parser.parse_args()

    orig = Path(args.orig).resolve()
    obf = Path(args.obf).resolve()
    outdir = Path(args.outdir).resolve()
    outdir.mkdir(parents=True, exist_ok=True)

    if args.tool == 'auto':
        tool = 'objdump' if find_executable(['objdump']) else 'llvm'
    else:
        tool = args.tool

    def process_file(input_path: Path, kind: str):
        # If assembly text file provided, use it directly.
        asm_src = outdir / f"{input_path.stem}.{kind}.asm"
        if is_asm_file(input_path):
            shutil.copyfile(input_path, asm_src)
            return asm_src
        if args.func == 'all':
            # disassemble whole file
            # prefer llvm-objdump to dump whole file
            if tool == 'objdump':
                objdump = find_executable(['objdump', 'x86_64-w64-mingw32-objdump', 'mingw32-objdump'])
                if not objdump:
                    raise RuntimeError("objdump not found")
                cmd = [objdump, '-d', '-M', 'intel', str(input_path)]
                rc, out, err = run_cmd(cmd)
                if rc != 0:
                    raise RuntimeError(f"objdump failed: {err.strip()}")
                asm_src.write_text(out, encoding='utf-8')
                return asm_src
            else:
                llvmobj = find_executable(['llvm-objdump', 'llvm-objdump.exe', 'objdump'])
                if not llvmobj:
                    raise RuntimeError("llvm-objdump not found")
                cmd = [llvmobj, '-d', str(input_path)]
                rc, out, err = run_cmd(cmd)
                if rc != 0:
                    raise RuntimeError(f"llvm-objdump failed: {err.strip()}")
                asm_src.write_text(out, encoding='utf-8')
                return asm_src
        else:
            # extract single function
            try:
                disasm_to_file(tool, input_path, args.func, str(asm_src))
                return asm_src
            except Exception as e:
                raise

    try:
        if not orig.exists():
            print(f"Error: original file {orig} not found", file=sys.stderr); sys.exit(2)
        if not obf.exists():
            print(f"Error: obfuscated file {obf} not found", file=sys.stderr); sys.exit(2)

        orig_asm = process_file(orig, 'orig')
        obf_asm  = process_file(obf,  'obf')

        orig_norm = outdir / f"{orig.stem}.norm.asm"
        obf_norm  = outdir / f"{obf.stem}.norm.asm"
        normalize_asm_file(orig_asm, orig_norm)
        normalize_asm_file(obf_asm, obf_norm)

        diff = compare_text_files(str(orig_norm), str(obf_norm))
        diff_file = outdir / "diff.unified.txt"
        diff_file.write_text('\\n'.join(diff), encoding='utf-8')

        if not args.quiet:
            if diff:
                print(f"Diff saved to: {diff_file}")
                print('\\n'.join(diff[:500]))  # show first part
            else:
                print("No differences found (after normalization).")

        # Optionally open in code --diff
        if args.open and shutil.which('code'):
            os.system(f'code --diff \"{orig_norm}\" \"{obf_norm}\"')

        print("Finished. Intermediate files in:", outdir)
    except Exception as exc:
        print("ERROR:", exc, file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
