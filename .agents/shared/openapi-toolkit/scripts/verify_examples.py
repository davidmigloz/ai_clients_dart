#!/usr/bin/env python3
"""
Verify example files exist for all resources.

This is a config-driven script that loads verification rules from config files.

Usage:
    python3 verify_examples.py --config-dir CONFIG_DIR

Exit codes:
    0 - All resources have examples
    1 - Resources without examples found
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
        'resources_dir': 'lib/src/resources',
        'examples_dir': 'example',
        'excluded_from_examples': [],
        'resource_to_example': {},
        'excluded_resources': [],
    }

    # Load package.json for paths
    pkg_file = config_dir / 'package.json'
    if pkg_file.exists():
        with open(pkg_file) as f:
            pkg = json.load(f)
            config['resources_dir'] = pkg.get('resources_dir', config['resources_dir'])
            config['examples_dir'] = pkg.get('examples_dir', config['examples_dir'])

    # Load documentation.json for exclusions and mappings
    doc_file = config_dir / 'documentation.json'
    if doc_file.exists():
        with open(doc_file) as f:
            doc = json.load(f)
            config['excluded_from_examples'] = doc.get('excluded_from_examples', [])
            config['resource_to_example'] = doc.get('resource_to_example', {})
            config['excluded_resources'] = doc.get('excluded_resources', [])

    return config


def snake_to_camel(name: str) -> str:
    """Convert snake_case to camelCase."""
    components = name.split('_')
    return components[0] + ''.join(x.title() for x in components[1:])


def find_resources(resources_dir: Path, config: dict) -> set[str]:
    """Find all resource names from *_resource.dart files."""
    resources = set()
    excluded = set(config['excluded_resources'])

    if not resources_dir.exists():
        return resources

    for item in resources_dir.iterdir():
        if item.name.startswith('.'):
            continue

        if item.is_dir():
            resource_file = item / f'{item.name}_resource.dart'
            if resource_file.exists():
                name = item.name + '_resource'
            else:
                dart_files = list(item.glob('*_resource.dart'))
                if dart_files:
                    name = dart_files[0].stem
                else:
                    continue
        elif item.is_file() and item.suffix == '.dart':
            name = item.stem
        else:
            continue

        if not name.endswith('_resource'):
            continue

        if name in excluded:
            continue

        base_name = name.replace('_resource', '')
        resource_name = snake_to_camel(base_name)

        resources.add(resource_name)

    return resources


def find_examples(example_dir: Path) -> set[str]:
    """Find all example file names."""
    examples = set()

    if not example_dir.exists():
        return examples

    for f in example_dir.glob('*_example.dart'):
        name = f.stem.replace('_example', '')
        resource_name = snake_to_camel(name)
        examples.add(resource_name)

    return examples


def main():
    parser = argparse.ArgumentParser(
        description='Verify example files exist for all resources'
    )
    parser.add_argument(
        '--config-dir', type=Path, required=True,
        help='Directory containing config files'
    )
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Show detailed output'
    )
    args = parser.parse_args()

    # Validate config directory
    if not args.config_dir.exists():
        print(f"Error: Config directory not found: {args.config_dir}")
        sys.exit(2)

    # Load configuration
    config = load_config(args.config_dir)

    resources_dir = Path(config['resources_dir'])
    example_dir = Path(config['examples_dir'])

    # Validate directory
    if not resources_dir.exists():
        print(f"Error: {config['resources_dir']}/ not found. Run from package root directory.")
        sys.exit(2)

    print("Checking example file completeness...")
    print()

    # Find all resources and examples
    resources = find_resources(resources_dir, config)
    examples = find_examples(example_dir)

    # Remove excluded resources from check
    excluded = set(config['excluded_from_examples'])
    resources_to_check = resources - excluded

    if args.verbose:
        print(f"Resources found: {sorted(resources)}")
        print(f"Examples found: {sorted(examples)}")
        print(f"Checking (after exclusions): {sorted(resources_to_check)}")
        print()

    # Check for resources without examples
    resource_to_example = config['resource_to_example']
    missing = set()
    for resource in resources_to_check:
        mapped_example = resource_to_example.get(resource)
        if mapped_example and mapped_example in examples:
            continue
        if resource in examples:
            continue
        missing.add(resource)

    if not missing:
        print("✓ All resources have example files.")
        sys.exit(0)

    # Report missing examples
    print("RESOURCES WITHOUT EXAMPLES:")
    for r in sorted(missing):
        snake_name = re.sub(r'([A-Z])', r'_\1', r).lower().lstrip('_')
        print(f"  - {r}")
        print(f"      → Create: {config['examples_dir']}/{snake_name}_example.dart")
    print()

    print(f"Found {len(missing)} resource(s) without examples.")
    print()
    print("To fix:")
    print("  1. Create example files using assets/example_template.dart")
    print("  2. Follow patterns in references/implementation-patterns.md Section 9")
    print()

    sys.exit(1)


if __name__ == '__main__':
    main()
