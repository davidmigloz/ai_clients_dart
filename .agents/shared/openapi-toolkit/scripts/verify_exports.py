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
        'barrel_file': 'lib/googleai_dart.dart',  # Legacy single-file option
        'barrel_files': [],  # New: explicit list of barrel files
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
            config['barrel_files'] = pkg.get('barrel_files', [])
            config['models_dir'] = pkg.get('models_dir', config['models_dir'])
            config['skip_files'] = pkg.get('skip_files', config['skip_files'])
            config['internal_barrel_files'] = pkg.get('internal_barrel_files', config['internal_barrel_files'])

    return config


def discover_barrel_files(lib_dir: Path) -> list[Path]:
    """
    Auto-discover library entry points.

    In Dart, files directly in lib/ (not lib/src/) are public library entry points.
    This follows the standard Dart package layout convention.
    """
    barrel_files = []

    if not lib_dir.exists():
        return barrel_files

    for dart_file in lib_dir.glob('*.dart'):
        # Skip private files (starting with underscore)
        if dart_file.name.startswith('_'):
            continue
        barrel_files.append(dart_file)

    return sorted(barrel_files)


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


def parse_exports_from_file(file_path: Path) -> list[str]:
    """Extract export paths from a Dart file."""
    if not file_path.exists():
        return []
    content = file_path.read_text()
    # Match: export 'path/to/file.dart';
    pattern = r"export\s+'([^']+\.dart)'"
    return re.findall(pattern, content)


def get_transitive_exports(barrel_file: Path, visited: set[Path] | None = None) -> set[Path]:
    """Recursively collect all transitively exported files."""
    if visited is None:
        visited = set()

    if barrel_file in visited or not barrel_file.exists():
        return set()

    visited.add(barrel_file)
    exported = set()
    base_dir = barrel_file.parent

    for export_path in parse_exports_from_file(barrel_file):
        # Resolve relative path from the barrel file's directory
        full_path = (base_dir / export_path).resolve()
        exported.add(full_path)

        # Recursively follow exports from this file
        exported.update(get_transitive_exports(full_path, visited))

    return exported


def get_barrel_exports(barrel_file: Path) -> tuple[set[str], set[Path]]:
    """Extract exported filenames from barrel file (with transitive support).

    Returns:
        Tuple of (filename set, full path set) to handle both simple cases
        and potential filename collisions across subdirectories.
    """
    # Get all transitively exported file paths
    transitive_paths = get_transitive_exports(barrel_file)

    # Return both filenames (for simple matching) and full paths (for collision handling)
    filenames = {p.name for p in transitive_paths}
    return filenames, transitive_paths


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

    # Load package name for error messages
    pkg_file = args.config_dir / 'package.json'
    pkg_name = 'unknown'
    if pkg_file.exists():
        with open(pkg_file) as f:
            pkg_name = json.load(f).get('name', 'unknown')

    # Verify we're in the right directory
    if not models_dir.exists():
        print(f"ERROR: Directory '{config['models_dir']}' not found.", file=sys.stderr)
        print("", file=sys.stderr)
        print("This script must be run from the PACKAGE ROOT directory,", file=sys.stderr)
        print("not from the repository root.", file=sys.stderr)
        print("", file=sys.stderr)
        print("Example:", file=sys.stderr)
        print(f"  cd packages/{pkg_name}", file=sys.stderr)
        print(f"  python3 ../../.claude/shared/openapi-toolkit/scripts/verify_exports.py \\", file=sys.stderr)
        print(f"    --config-dir {args.config_dir}", file=sys.stderr)
        print("", file=sys.stderr)
        print(f"Current working directory: {Path.cwd()}", file=sys.stderr)
        sys.exit(2)

    # Determine barrel files to check
    # Priority: 1) config barrel_files list, 2) auto-discover, 3) legacy single barrel_file
    barrel_files_to_check = []
    lib_dir = Path('lib')

    if config.get('barrel_files'):
        # Explicit list in config
        barrel_files_to_check = [Path(bf) for bf in config['barrel_files']]
    else:
        # Auto-discover barrel files
        discovered = discover_barrel_files(lib_dir)
        if discovered:
            barrel_files_to_check = discovered
        else:
            # Fall back to legacy single barrel_file
            barrel_files_to_check = [Path(config['barrel_file'])]

    # Validate barrel files exist
    missing_barrels = [bf for bf in barrel_files_to_check if not bf.exists()]
    if missing_barrels:
        if len(barrel_files_to_check) == 1:
            print(f"ERROR: Barrel file '{barrel_files_to_check[0]}' not found.", file=sys.stderr)
        else:
            print("ERROR: Some barrel files not found:", file=sys.stderr)
            for bf in missing_barrels:
                print(f"  - {bf}", file=sys.stderr)
        print("", file=sys.stderr)
        print("Make sure you're running from the package root directory.", file=sys.stderr)
        print(f"Current working directory: {Path.cwd()}", file=sys.stderr)
        sys.exit(2)

    print("Checking barrel file completeness...")
    print(f"Discovered {len(barrel_files_to_check)} barrel file(s):")
    for bf in barrel_files_to_check:
        print(f"  - {bf}")
    print()

    # Find all model files
    model_files = find_model_files(models_dir, config)

    # Collect exports from ALL barrel files
    export_filenames = set()
    export_full_paths = set()
    for barrel_file in barrel_files_to_check:
        filenames, full_paths = get_barrel_exports(barrel_file)
        export_filenames.update(filenames)
        export_full_paths.update(full_paths)

    # Check for filename collisions in model files (different paths, same filename)
    filename_to_paths: dict[str, list[Path]] = {}
    for f in model_files:
        filename_to_paths.setdefault(f.name, []).append(f)

    has_collisions = any(len(paths) > 1 for paths in filename_to_paths.values())

    unexported = []
    exported_paths = []

    for f in model_files:
        # Use full path comparison if there are filename collisions
        if has_collisions and len(filename_to_paths.get(f.name, [])) > 1:
            # For colliding filenames, check against resolved full paths
            is_exported = f.resolve() in export_full_paths
        else:
            # Simple filename comparison for unique filenames
            is_exported = f.name in export_filenames

        if is_exported:
            exported_paths.append(f)
        else:
            unexported.append(f)

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
    barrel_names = ', '.join(str(bf) for bf in barrel_files_to_check)
    print(f"To fix, add exports to one of: {barrel_names}")
    print()
    print("Suggested exports:")
    for f in unexported:
        relative_import = str(f.relative_to(Path('lib')))
        print(f"export '{relative_import}';")

    sys.exit(1)


if __name__ == '__main__':
    main()
