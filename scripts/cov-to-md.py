#!/usr/bin/env python3
"""Convert an lcov tracefile to a GitHub-flavoured Markdown coverage table.

Usage:
    python3 scripts/cov-to-md.py coverage.lcov        # from a file
    llvm-cov export -format=lcov ... | python3 scripts/cov-to-md.py   # from stdin

Reads the per-file LF/LH (lines), FNF/FNH (functions), BRF/BRH (branches) records that
llvm-cov (or gcov/lcov) emit, and prints one row per file plus a TOTAL row.
"""
import os
import sys


def read_text() -> str:
    if len(sys.argv) > 1:
        with open(sys.argv[1], encoding="utf-8") as handle:
            return handle.read()
    return sys.stdin.read()


def pct(hit: int, found: int) -> str:
    return f"{100.0 * hit / found:.1f}%" if found else "—"


KEYS = ("LF", "LH", "FNF", "FNH", "BRF", "BRH")


def parse(text: str):
    files, totals, current = [], dict.fromkeys(KEYS, 0), None
    for line in text.splitlines():
        if line.startswith("SF:"):
            current = {"file": os.path.basename(line[3:]), **dict.fromkeys(KEYS, 0)}
        elif line == "end_of_record" and current:
            files.append(current)
            current = None
        elif current:
            for key in KEYS:
                if line.startswith(key + ":"):
                    value = int(line[len(key) + 1:])
                    current[key] = value
                    totals[key] += value
                    break
    return files, totals


def main() -> None:
    files, totals = parse(read_text())
    rows = ["| File | Lines | Functions | Branches |", "|---|---|---|---|"]
    for f in sorted(files, key=lambda x: x["file"]):
        rows.append(
            f"| `{f['file']}` | {pct(f['LH'], f['LF'])} "
            f"| {pct(f['FNH'], f['FNF'])} | {pct(f['BRH'], f['BRF'])} |"
        )
    rows.append(
        f"| **TOTAL** | **{pct(totals['LH'], totals['LF'])}** "
        f"| **{pct(totals['FNH'], totals['FNF'])}** | **{pct(totals['BRH'], totals['BRF'])}** |"
    )
    print("\n".join(rows))


if __name__ == "__main__":
    main()
