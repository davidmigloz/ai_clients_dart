#!/usr/bin/env python3
"""
Verify README code examples match actual Dart API.

This is a config-driven script that loads drift patterns from config files.

Usage:
    python3 verify_readme_code.py --config-dir CONFIG_DIR

Exit codes:
    0 - No issues found
    1 - Errors detected (must fix)
    2 - Error (wrong directory, missing files, etc.)
"""

import argparse
import json
import re
import sys
from pathlib import Path


def load_config(config_dir: Path) -> dict:
    """Load configuration from config directory."""
    config = {
        'drift_patterns': [],
    }

    # Load documentation.json
    doc_file = config_dir / 'documentation.json'
    if doc_file.exists():
        with open(doc_file) as f:
            doc = json.load(f)
            config['drift_patterns'] = doc.get('drift_patterns', [])

    return config


def extract_dart_blocks(readme_path: Path) -> list[tuple[int, str]]:
    """Extract dart code blocks with their starting line numbers."""
    content = readme_path.read_text()
    blocks = []
    in_dart = False
    start_line = 0
    current_block = []

    for i, line in enumerate(content.split('\n'), 1):
        if line.strip() == '```dart':
            in_dart = True
            start_line = i
            current_block = []
        elif line.strip() == '```' and in_dart:
            in_dart = False
            blocks.append((start_line, '\n'.join(current_block)))
        elif in_dart:
            current_block.append(line)

    return blocks


def check_block(line_num: int, code: str, config: dict) -> list[dict]:
    """Check a code block for drift patterns."""
    issues = []
    for pattern_info in config['drift_patterns']:
        pattern = pattern_info.get('pattern', '')
        message = pattern_info.get('message', 'Documentation drift detected')
        severity = pattern_info.get('severity', 'warning')

        for match in re.finditer(pattern, code):
            block_line = code[:match.start()].count('\n') + 1
            issues.append({
                'line': line_num + block_line,
                'match': match.group(),
                'message': message,
                'severity': severity,
            })
    return issues


def main():
    parser = argparse.ArgumentParser(
        description='Verify README code examples for API drift'
    )
    parser.add_argument(
        '--config-dir', type=Path, required=True,
        help='Directory containing config files'
    )
    args = parser.parse_args()

    # Validate config directory
    if not args.config_dir.exists():
        print(f"Error: Config directory not found: {args.config_dir}")
        sys.exit(2)

    # Load configuration
    config = load_config(args.config_dir)

    # Verify we're in the right directory
    readme = Path('README.md')
    if not readme.exists():
        print("Error: README.md not found. Run from package root directory.")
        sys.exit(2)

    if not config['drift_patterns']:
        print("Warning: No drift patterns defined in config/documentation.json")
        print("✓ No README code drift detected (no patterns to check)")
        sys.exit(0)

    print("Checking README code examples for API drift...\n")

    blocks = extract_dart_blocks(readme)
    all_issues = []

    for line_num, code in blocks:
        all_issues.extend(check_block(line_num, code, config))

    if all_issues:
        errors = [i for i in all_issues if i['severity'] == 'error']
        warnings = [i for i in all_issues if i['severity'] == 'warning']

        if errors:
            print("ERRORS (must fix):\n")
            for issue in errors:
                print(f"  Line {issue['line']}: `{issue['match']}`")
                print(f"    → {issue['message']}\n")

        if warnings:
            print("WARNINGS (review):\n")
            for issue in warnings:
                print(f"  Line {issue['line']}: `{issue['match']}`")
                print(f"    → {issue['message']}\n")

        print(f"Summary: {len(errors)} error(s), {len(warnings)} warning(s)")

        if errors:
            print("\nFix errors before proceeding.")
            sys.exit(1)
        else:
            print("\nWarnings are informational - review if they apply.")
    else:
        print("✓ No README code drift detected")

    sys.exit(0)


if __name__ == '__main__':
    main()
