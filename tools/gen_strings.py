#!/usr/bin/env python3
"""Regenerate Resources/{en,ru,lv}.lproj/Localizable.strings from tools/strings_data.py. Usage: python3 -I tools/gen_strings.py (repo root)"""
import pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).parent))
from strings_data import S
def esc(s): return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
for i, lang in enumerate(["en", "ru", "lv"]):
    lines = [f'"{esc(k)}" = "{esc(k if i == 0 else v[i - 1])}";' for k, v in S.items()]
    pathlib.Path(f"Resources/{lang}.lproj/Localizable.strings").write_text("\n".join(lines) + "\n", encoding="utf-8")
print(len(S), "strings")
