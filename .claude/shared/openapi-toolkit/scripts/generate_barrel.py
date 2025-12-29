#!/usr/bin/env python3
"""
Generate or update barrel file exports for a Dart package.

Usage:
    python3 generate_barrel.py --config-dir CONFIG_DIR [--dry-run]
    python3 generate_barrel.py --config-dir CONFIG_DIR --subdirectory models/tools

Examples:
    python3 generate_barrel.py --config-dir config/ --dry-run
    python3 generate_barrel.py --config-dir config/ --subdirectory models/files

Exit codes:
    0 - Success
    1 - No changes needed
    2 - Config error
"""

import argparse
import json
import sys
from pathlib import Path


def load_config(config_dir: Path) -> dict:
    """Load configuration from config directory."""
    config = {
        'package': {},
    }

    package_file = config_dir / 'package.json'
    if package_file.exists():
        with open(package_file) as f:
            config['package'] = json.load(f)

    return config


def find_dart_files(directory: Path, skip_files: set[str]) -> list[Path]:
    """Find all .dart files in directory, excluding skip files and barrel files."""
    files = []
    for f in sorted(directory.glob('*.dart')):
        name = f.name
        # Skip barrel files (same name as directory)
        if name == f'{directory.name}.dart':
            continue
        # Skip internal files
        if name.startswith('_'):
            continue
        # Skip explicitly excluded files
        if name in skip_files:
            continue
        files.append(f)
    return files


def generate_barrel_content(files: list[Path]) -> str:
    """Generate barrel file content."""
    exports = [f"export '{f.name}';" for f in files]
    return '\n'.join(exports) + '\n'


def generate_subdirectory_barrel(subdir: Path, package_config: dict) -> tuple[str, Path]:
    """Generate barrel file for a subdirectory."""
    skip_files = set(package_config.get('skip_files', []))
    files = find_dart_files(subdir, skip_files)

    if not files:
        return '', subdir / f'{subdir.name}.dart'

    content = generate_barrel_content(files)
    barrel_path = subdir / f'{subdir.name}.dart'
    return content, barrel_path


def find_model_subdirs(models_dir: Path) -> list[Path]:
    """Find all subdirectories in models directory."""
    return sorted([d for d in models_dir.iterdir() if d.is_dir()])


def main():
    parser = argparse.ArgumentParser(description='Generate barrel file exports')
    parser.add_argument(
        '--config-dir', type=Path, required=True,
        help='Directory containing config files'
    )
    parser.add_argument(
        '--subdirectory', '-s', type=str, default=None,
        help='Specific subdirectory to generate barrel for (relative to lib/src/)'
    )
    parser.add_argument(
        '--dry-run', action='store_true',
        help='Print what would be done without making changes'
    )
    args = parser.parse_args()

    if not args.config_dir.exists():
        print(f"Error: Config directory not found: {args.config_dir}", file=sys.stderr)
        sys.exit(2)

    config = load_config(args.config_dir)
    package_config = config.get('package', {})
    package_name = package_config.get('name', '')

    if not package_name:
        print("Error: Package name not found in config", file=sys.stderr)
        sys.exit(2)

    package_dir = Path(f'packages/{package_name}')
    if not package_dir.exists():
        print(f"Error: Package directory not found: {package_dir}", file=sys.stderr)
        sys.exit(2)

    models_dir = package_dir / 'lib' / 'src' / 'models'

    if args.subdirectory:
        # Generate barrel for specific subdirectory
        subdir = package_dir / 'lib' / 'src' / args.subdirectory
        if not subdir.exists():
            print(f"Error: Subdirectory not found: {subdir}", file=sys.stderr)
            sys.exit(2)

        content, barrel_path = generate_subdirectory_barrel(subdir, package_config)

        if not content:
            print(f"No files to export in {subdir}")
            sys.exit(1)

        if args.dry_run:
            print(f"Would write to: {barrel_path}")
            print(content)
        else:
            barrel_path.write_text(content)
            print(f"Generated: {barrel_path}")
    else:
        # Generate barrels for all model subdirectories
        if not models_dir.exists():
            print(f"Error: Models directory not found: {models_dir}", file=sys.stderr)
            sys.exit(2)

        subdirs = find_model_subdirs(models_dir)
        if not subdirs:
            print("No model subdirectories found")
            sys.exit(1)

        generated = 0
        for subdir in subdirs:
            content, barrel_path = generate_subdirectory_barrel(subdir, package_config)

            if not content:
                continue

            if args.dry_run:
                print(f"Would write to: {barrel_path}")
                print(content)
                print('---')
            else:
                barrel_path.write_text(content)
                print(f"Generated: {barrel_path}")

            generated += 1

        if generated == 0:
            print("No barrel files generated")
            sys.exit(1)

        print(f"\nGenerated {generated} barrel file(s)")

    sys.exit(0)


if __name__ == '__main__':
    main()
