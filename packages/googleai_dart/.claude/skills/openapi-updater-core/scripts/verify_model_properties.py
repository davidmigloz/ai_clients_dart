#!/usr/bin/env python3
"""
Verify critical model classes have all properties from OpenAPI spec.

This is a config-driven script that loads the list of critical models
from a JSON config file.

Usage:
    python3 verify_model_properties.py --config-dir CONFIG_DIR [--spec SPEC_FILE]

Exit codes:
    0 - All properties match
    1 - Missing properties found
    2 - Error (wrong directory, missing files, etc.)
"""

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Optional


def load_config(config_dir: Path) -> dict:
    """Load configuration from config directory."""
    config = {
        'critical_models': [],
        'expected_properties': {},
    }

    # Load models.json
    models_file = config_dir / 'models.json'
    if models_file.exists():
        with open(models_file) as f:
            models = json.load(f)
            config['critical_models'] = models.get('critical_models', [])
            config['expected_properties'] = models.get('expected_properties', {})

    return config


def load_openapi_spec(spec_path: Path) -> dict:
    """Load OpenAPI specification."""
    with open(spec_path) as f:
        return json.load(f)


def get_spec_properties(spec: dict, schema_name: str) -> set[str]:
    """Extract property names from OpenAPI schema."""
    schemas = spec.get('components', {}).get('schemas', {})
    schema = schemas.get(schema_name, {})

    properties = set()

    # Direct properties (skip internal properties starting with underscore)
    for prop in schema.get('properties', {}).keys():
        if not prop.startswith('_'):
            properties.add(prop)

    # Handle allOf (merged schemas)
    for item in schema.get('allOf', []):
        if 'properties' in item:
            for prop in item['properties'].keys():
                properties.add(prop)
        elif '$ref' in item:
            ref_name = item['$ref'].split('/')[-1]
            # Don't recurse infinitely, just get direct properties
            ref_schema = schemas.get(ref_name, {})
            for prop in ref_schema.get('properties', {}).keys():
                properties.add(prop)

    # Handle oneOf (for sealed classes like Part)
    for item in schema.get('oneOf', []):
        if '$ref' in item:
            ref_name = item['$ref'].split('/')[-1]
            ref_schema = schemas.get(ref_name, {})
            for prop in ref_schema.get('properties', {}).keys():
                properties.add(prop)

    return properties


def get_dart_properties(dart_file: Path) -> set[str]:
    """Extract property names from Dart class file."""
    if not dart_file.exists():
        return set()

    content = dart_file.read_text()
    properties = set()

    # Match final field declarations: final Type? propertyName;
    # Also handles: final Type propertyName;
    field_pattern = r'final\s+[\w<>?,\s]+\s+(\w+)\s*;'
    for match in re.finditer(field_pattern, content):
        properties.add(match.group(1))

    # Match constructor named parameters: this.propertyName
    constructor_pattern = r'this\.(\w+)'
    for match in re.finditer(constructor_pattern, content):
        properties.add(match.group(1))

    # Match factory fromJson parameters (for sealed classes)
    # These may define properties via case statements
    factory_pattern = r"'(\w+)':\s*"
    for match in re.finditer(factory_pattern, content):
        prop = match.group(1)
        # Only add if it looks like a JSON property name (camelCase)
        if prop[0].islower():
            properties.add(prop)

    return properties


def to_camel_case(name: str) -> str:
    """Convert snake_case or PascalCase to camelCase for comparison."""
    # Already camelCase
    if '_' not in name and name[0].islower():
        return name
    # snake_case to camelCase
    if '_' in name:
        parts = name.split('_')
        return parts[0].lower() + ''.join(p.title() for p in parts[1:])
    # PascalCase to camelCase
    return name[0].lower() + name[1:]


def normalize_property_name(name: str) -> str:
    """Normalize property name for comparison."""
    # Remove common prefixes/suffixes used in OpenAPI vs Dart
    normalized = to_camel_case(name)
    return normalized


def verify_model(
    spec: Optional[dict],
    schema_name: str,
    dart_file: Path,
    expected_properties: Optional[set[str]] = None,
    verbose: bool = False
) -> tuple[bool, set[str], set[str]]:
    """
    Verify a model has all properties from spec or expected list.

    Returns (is_complete, missing_in_dart, extra_in_dart)
    """
    # Get expected properties from spec or explicit list
    if expected_properties:
        spec_props = expected_properties
    elif spec:
        spec_props = get_spec_properties(spec, schema_name)
    else:
        return True, set(), set()

    dart_props = get_dart_properties(dart_file)

    # Normalize both sets for comparison
    normalized_spec = {normalize_property_name(p) for p in spec_props}
    normalized_dart = {normalize_property_name(p) for p in dart_props}

    # Skip internal Dart properties
    internal_props = {'hashCode', 'runtimeType', 'copyWith', 'toJson', 'fromJson'}
    normalized_dart -= internal_props

    missing_in_dart = normalized_spec - normalized_dart
    extra_in_dart = normalized_dart - normalized_spec

    # Filter out false positives (common internal fields)
    common_internal = {'value', 'values', 'map', 'type', 'key', 'index'}
    extra_in_dart -= common_internal

    return len(missing_in_dart) == 0, missing_in_dart, extra_in_dart


def main():
    parser = argparse.ArgumentParser(
        description='Verify model properties match OpenAPI spec or expected list.'
    )
    parser.add_argument(
        '--config-dir', type=Path, required=True,
        help='Directory containing config files (models.json)'
    )
    parser.add_argument(
        '--spec', '-s',
        type=Path,
        default=Path('openapi.json'),
        help='Path to OpenAPI spec (default: openapi.json)'
    )
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Show detailed output including extra properties'
    )
    parser.add_argument(
        '--model', '-m',
        type=str,
        help='Check only a specific model (e.g., "Tool")'
    )
    args = parser.parse_args()

    # Validate config directory
    if not args.config_dir.exists():
        print(f"Error: Config directory not found: {args.config_dir}")
        sys.exit(2)

    # Load configuration
    config = load_config(args.config_dir)
    critical_models = config['critical_models']
    expected_properties = config['expected_properties']

    if not critical_models:
        print("Warning: No critical models defined in config/models.json")
        sys.exit(0)

    # Load spec if available
    spec = None
    if args.spec.exists():
        spec = load_openapi_spec(args.spec)
    elif not expected_properties:
        print(f"Warning: OpenAPI spec not found at {args.spec}")
        print("Will use expected_properties from config if available.")

    print("Checking model properties...")
    print()

    # Filter models if specific one requested
    models_to_check = critical_models
    if args.model:
        models_to_check = [m for m in critical_models if m['name'] == args.model]
        if not models_to_check:
            print(f"Error: Unknown model '{args.model}'")
            print(f"Available: {', '.join(m['name'] for m in critical_models)}")
            sys.exit(2)

    has_issues = False

    for model in models_to_check:
        model_name = model['name']
        dart_path = model['file']
        spec_schema = model.get('spec_schema', model_name)

        dart_file = Path(dart_path)

        if not dart_file.exists():
            print(f"⚠️  {model_name}: File not found - {dart_path}")
            continue

        # Use expected_properties if available for this model
        model_expected = None
        if model_name in expected_properties:
            model_expected = set(expected_properties[model_name])

        is_complete, missing, extra = verify_model(
            spec, spec_schema, dart_file, model_expected, args.verbose
        )

        if is_complete:
            print(f"✓  {model_name}: All properties present")
        else:
            has_issues = True
            print(f"⚠️  {model_name}: Missing properties - {', '.join(sorted(missing))}")
            if args.verbose and extra:
                print(f"   Extra in Dart (may be computed): {', '.join(sorted(extra))}")

    print()

    if has_issues:
        print("ACTION REQUIRED: Add missing properties to Dart models.")
        print()
        print("For each missing property:")
        print("  1. Check the OpenAPI spec for the property definition")
        print("  2. Add the field to the Dart class")
        print("  3. Update constructor, fromJson, toJson, and copyWith")
        sys.exit(1)
    else:
        print("✓ All critical models have complete properties.")
        sys.exit(0)


if __name__ == '__main__':
    main()
