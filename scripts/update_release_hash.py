#!/usr/bin/env python3
import hashlib
import re
from pathlib import Path

SCRIPT = Path(__file__).resolve().parent.parent / 'NetInfo.ps1'
README = Path(__file__).resolve().parent.parent / 'README.md'


def main() -> None:
    if not SCRIPT.exists():
        raise FileNotFoundError(f'Missing script file: {SCRIPT}')
    if not README.exists():
        raise FileNotFoundError(f'Missing README file: {README}')

    digest = hashlib.sha256(SCRIPT.read_bytes()).hexdigest().lower()
    lines = README.read_text(encoding='utf-8').splitlines()

    for i, line in enumerate(lines):
        if 'Official SHA-256 Hash:' in line:
            lines[i] = re.sub(r'`[a-f0-9]{64}`', f'`{digest}`', line, count=1)
            break
    else:
        raise ValueError('Could not find the SHA-256 hash line in README.md.')

    README.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print(f'Updated README.md with SHA-256: {digest}')


if __name__ == '__main__':
    main()
