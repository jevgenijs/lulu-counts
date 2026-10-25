#!/usr/bin/env python3
"""Print the string literals used as UI text in Sources/UI (Text("..."), Button("..."), Label("..."), ...) and L10n.tr/format keys.
Used to check that Localizable.strings has every UI string. Usage: python3 -I tools/ui_keys.py"""
import re, pathlib
keys = set()
pat = re.compile(r'(?:Text|Button|Label|navigationTitle|accessibilityLabel|accessibilityValue|Picker|Section|confirmationDialog|L10n\.tr|L10n\.format|t)\(\s*"((?:[^"\\]|\\.)*)"')
for f in pathlib.Path('Sources').rglob('*.swift'):
    for m in pat.finditer(f.read_text()):
        k = m.group(1)
        if '\\' in k or not k.strip(): continue
        keys.add(k)
print("\n".join(sorted(keys)))
