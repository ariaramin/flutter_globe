#!/usr/bin/env python3
"""Check repository-relative Markdown links and analyze fenced Dart examples."""
from pathlib import Path
import re
import shutil
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
sources = [root / 'README.md', root / 'CONTRIBUTING.md', root / 'example/README.md', *sorted((root / 'doc').glob('*.md'))]
imports = "import 'package:flutter/material.dart';\nimport 'package:flutter_globe/flutter_globe.dart';\n"
out = root / '.dart_tool/doc_checks'
out.mkdir(parents=True, exist_ok=True)
errors = []
count = 0
for source in sources:
    text = source.read_text()
    for link in re.findall(r'\]\(([^)]+)\)|src="([^"]+)"', text):
        target = next(part for part in link if part).split('#')[0]
        if not target or '://' in target or target.startswith('mailto:'):
            continue
        if not (source.parent / target).exists():
            errors.append(f'{source.relative_to(root)}: missing {target}')
    for index, snippet in enumerate(re.findall(r'```dart\n(.*?)```', text, re.S)):
        count += 1
        file = out / f'{source.stem}_{index}.dart'
        if snippet.lstrip().startswith('import '):
            code = snippet
        elif snippet.lstrip().startswith('class '):
            code = imports + snippet
        else:
            code = imports + 'void example() {\n' + snippet + '\n}\n'
        file.write_text('// ignore_for_file: unused_import, unused_local_variable, prefer_const_constructors, prefer_const_literals_to_create_immutables\n' + code)
flutter = shutil.which('flutter')
dart = str(Path(flutter).parent / 'cache/dart-sdk/bin/dart') if flutter else (shutil.which('dart') or 'dart')
result = subprocess.run([dart, 'analyze', str(out)], cwd=root, text=True, capture_output=True)
if result.returncode:
    errors.append(result.stdout + result.stderr)
if errors:
    print('\n'.join(errors))
    sys.exit(1)
print(f'Checked local links and analyzed {count} Dart examples.')
