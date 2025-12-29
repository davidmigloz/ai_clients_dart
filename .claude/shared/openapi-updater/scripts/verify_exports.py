#!/usr/bin/env python3
"""
Verify all model files are exported in the barrel file.

This is a config-driven script that loads package structure from config files.

Usage:
    python3 verify_exports.py --config-dir CONFIG_DIR

Exit codes:
    0 - All files are exported
    1 - Unexported files found
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
        'barrel_file': 'lib/googleai_dart.dart',
        'models_dir': 'lib/src/models',
        'skip_files': ['copy_with_sentinel.dart'],
        'internal_barrel_files': [],
    }

    # Load package.json
    pkg_file = config_dir / 'package.json'
    if pkg_file.exists():
        with open(pkg_file) as f:
            pkg = json.load(f)
            config['barrel_file'] = pkg.get('barrel_file', config['barrel_file'])
            config['models_dir'] = pkg.get('models_dir', config['models_dir'])
            config['skip_files'] = pkg.get('skip_files', config['skip_files'])
            config['internal_barrel_files'] = pkg.get('internal_barrel_files', config['internal_barrel_files'])

    return config


def is_part_file(file: Path) -> bool:
    """Check if a file uses 'part of' directive (included in another file)."""
    try:
        content = file.read_text()
        for line in content.split('\n'):
            line = line.strip()
            if not line or line.startswith('//'):
                continue
            if line.startswith('part of'):
                return True
            if line.startswith(('import ', 'export ', 'library ')):
                return False
        return False
    except Exception:
        return False


def find_model_files(models_dir: Path, config: dict) -> list[Path]:
    """Find all .dart files in models subdirectories (recursive)."""
    files = []

    skip_files = set(config['skip_files'])
    internal_barrel_files = set(config['internal_barrel_files'])

    for dart_file in models_dir.glob('**/*.dart'):
        if any(part.startswith('.') for part in dart_file.parts):
            continue
        if dart_file.name in skip_files:
            continue
        if dart_file.name in internal_barrel_files:
            continue
        if is_part_file(dart_file):
            continue
        files.append(dart_file)

    return sorted(files)


def get_barrel_exports(barrel_file: Path) -> set[str]:
    """Extract exported filenames from barrel file."""
    exports = set()
    content = barrel_file.read_text()
    pattern = r"export\s+'[^']*?([^/]+\.dart)'"
    for match in re.finditer(pattern, content):
        exports.add(match.group(1))
    return exports


def extract_types_from_file(file: Path) -> set[str]:
    """Extract class, enum, and sealed class names from a Dart file."""
    content = file.read_text()
    pattern = r'(?:class|enum|sealed class)\s+(\w+)'
    return set(re.findall(pattern, content))


def find_type_usages(file: Path, type_names: set[str]) -> set[str]:
    """Find which types from type_names are used in the file."""
    content = file.read_text()
    used = set()
    for type_name in type_names:
        if re.search(rf'\b{type_name}\b', content):
            used.add(type_name)
    return used


def check_transitive_dependencies(
    unexported_files: list[Path],
    exported_files: list[Path],
    models_dir: Path,
) -> dict[str, list[str]]:
    """Check if unexported types are used by exported types."""
    unexported_types: dict[str, Path] = {}
    for f in unexported_files:
        for type_name in extract_types_from_file(f):
            unexported_types[type_name] = f

    dependencies: dict[str, list[str]] = {}

    for exported_file in exported_files:
        used_types = find_type_usages(exported_file, set(unexported_types.keys()))
        for type_name in used_types:
            unexported_file = unexported_types[type_name]
            file_key = unexported_file.name
            if file_key not in dependencies:
                dependencies[file_key] = []
            dependencies[file_key].append(f"{type_name} (used by {exported_file.name})")

    return dependencies


def main():
    parser = argparse.ArgumentParser(
        description='Verify all model files are exported in barrel file.'
    )
    parser.add_argument(
        '--config-dir', type=Path, required=True,
        help='Directory containing config files'
    )
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Show detailed output including transitive dependency analysis'
    )
    parser.add_argument(
        '--check-transitive',
        action='store_true',
        default=True,
        help='Check for transitive dependencies (default: True)'
    )
    args = parser.parse_args()

    # Validate config directory
    if not args.config_dir.exists():
        print(f"Error: Config directory not found: {args.config_dir}")
        sys.exit(2)

    # Load configuration
    config = load_config(args.config_dir)

    models_dir = Path(config['models_dir'])
    barrel_file = Path(config['barrel_file'])

    # Verify we're in the right directory
    if not models_dir.exists():
        print(f"Error: {config['models_dir']}/ not found. Run from package root directory.")
        sys.exit(2)

    if not barrel_file.exists():
        print(f"Error: {config['barrel_file']} not found. Run from package root directory.")
        sys.exit(2)

    print("Checking barrel file completeness...")
    print()

    # Find all model files and check exports
    model_files = find_model_files(models_dir, config)
    exports = get_barrel_exports(barrel_file)

    unexported = []
    exported_paths = []

    for f in model_files:
        if f.name not in exports:
            unexported.append(f)
        else:
            exported_paths.append(f)

    if args.verbose:
        print(f"Found {len(model_files)} model files")
        print(f"Found {len(exports)} exports in barrel file")
        print()

    if not unexported:
        print("✓ All model files are exported.")
        sys.exit(0)

    # Report unexported files
    print("UNEXPORTED FILES:")
    for f in unexported:
        print(f"  - {f}")
    print()

    # Check transitive dependencies
    if args.check_transitive and unexported:
        dependencies = check_transitive_dependencies(
            unexported, exported_paths, models_dir
        )

        if dependencies:
            print("USED BY EXPORTED CLASSES (should be exported):")
            for file_name, usages in sorted(dependencies.items()):
                print(f"  - {file_name}:")
                for usage in usages:
                    print(f"      → {usage}")
            print()

    # Summary
    print(f"Found {len(unexported)} unexported file(s).")
    print()
    print(f"To fix, add exports to {config['barrel_file']}:")
    print()
    for f in unexported:
        relative_import = str(f.relative_to(Path('lib')))
        print(f"export '{relative_import}';")

    sys.exit(1)


if __name__ == '__main__':
    main()
