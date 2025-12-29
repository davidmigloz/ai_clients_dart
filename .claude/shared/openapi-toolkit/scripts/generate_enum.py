#!/usr/bin/env python3
"""
Generate Dart enum file from OpenAPI schema.

Usage:
    python3 generate_enum.py --config-dir CONFIG_DIR --schema SCHEMA_NAME --output OUTPUT_PATH
    python3 generate_enum.py --config-dir CONFIG_DIR --schema SCHEMA_NAME --dry-run
    python3 generate_enum.py --config-dir CONFIG_DIR --batch --output-dir OUTPUT_DIR

Examples:
    python3 generate_enum.py --config-dir config/ --schema HarmCategory --output lib/src/models/safety/harm_category.dart
    python3 generate_enum.py --config-dir config/ --schema FinishReason --dry-run
    python3 generate_enum.py --config-dir config/ --batch --output-dir lib/src/models

Exit codes:
    0 - Success
    1 - Schema not found or not an enum
    2 - Config error
"""

import argparse
import json
import re
import sys
from pathlib import Path


def load_config(config_dir: Path) -> dict:
    """Load configuration from config directory."""
    config = {
        'package': {},
        'specs': {},
        'schemas': {},
    }

    # Load package.json
    package_file = config_dir / 'package.json'
    if package_file.exists():
        with open(package_file) as f:
            config['package'] = json.load(f)

    # Load specs.json
    specs_file = config_dir / 'specs.json'
    if specs_file.exists():
        with open(specs_file) as f:
            config['specs'] = json.load(f)

    # Load schemas.json
    schemas_file = config_dir / 'schemas.json'
    if schemas_file.exists():
        with open(schemas_file) as f:
            config['schemas'] = json.load(f)

    return config


def get_schema_category(schema_name: str, config: dict) -> str:
    """Determine category for a schema based on pattern matching."""
    categories = config.get('schemas', {}).get('categories', {})
    default_category = config.get('schemas', {}).get('default_category', 'common')

    schema_lower = schema_name.lower()

    for category_name, category_config in categories.items():
        patterns = category_config.get('patterns', [])
        for pattern in patterns:
            if pattern.lower() in schema_lower:
                return category_config.get('directory', category_name)

    return default_category


def load_spec(config: dict, spec_name: str = 'main') -> dict | None:
    """Load OpenAPI spec from local file."""
    specs = config.get('specs', {}).get('specs', {})
    spec_config = specs.get(spec_name)
    if not spec_config:
        return None

    local_file = spec_config.get('local_file')
    if not local_file:
        return None

    package_name = config.get('package', {}).get('name', '')
    spec_path = Path(f'packages/{package_name}/specs/{local_file}')

    if not spec_path.exists():
        # Try old location
        spec_path = Path(f'packages/{package_name}/{local_file}')

    if not spec_path.exists():
        return None

    with open(spec_path) as f:
        return json.load(f)


def to_snake_case(name: str) -> str:
    """Convert PascalCase to snake_case."""
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()


def to_camel_case(name: str) -> str:
    """Convert SCREAMING_SNAKE_CASE or snake_case to camelCase."""
    parts = name.lower().split('_')
    return parts[0] + ''.join(p.capitalize() for p in parts[1:])


def to_pascal_case(name: str) -> str:
    """Convert snake_case to PascalCase."""
    return ''.join(p.capitalize() for p in name.split('_'))


def extract_enum_prefix(values: list[str]) -> str:
    """Extract common prefix from enum values (e.g., HARM_CATEGORY from HARM_CATEGORY_HATE_SPEECH)."""
    if not values:
        return ''

    # Find common prefix
    prefix_parts = values[0].split('_')
    for value in values[1:]:
        value_parts = value.split('_')
        common = []
        for i, part in enumerate(prefix_parts):
            if i < len(value_parts) and value_parts[i] == part:
                common.append(part)
            else:
                break
        prefix_parts = common

    return '_'.join(prefix_parts)


def get_value_name(value: str, prefix: str) -> str:
    """Get Dart enum value name from wire format."""
    if prefix and value.startswith(prefix + '_'):
        value = value[len(prefix) + 1:]
    return to_camel_case(value)


def generate_enum(schema_name: str, schema: dict, spec: dict) -> str:
    """Generate Dart enum code from schema."""
    description = schema.get('description', f'{schema_name} enumeration.')
    values = schema.get('enum', [])

    if not values:
        raise ValueError(f"Schema {schema_name} has no enum values")

    # Detect prefix for value names
    prefix = extract_enum_prefix(values)
    screaming_prefix = prefix if prefix else to_snake_case(schema_name).upper()

    # Generate value entries
    value_entries = []
    from_string_cases = []
    to_string_cases = []

    for value in values:
        dart_value = get_value_name(value, prefix)
        value_entries.append(f'  /// {dart_value.replace("_", " ").title()} value.\n  {dart_value},')
        from_string_cases.append(f"    '{value}' => {schema_name}.{dart_value},")
        to_string_cases.append(f"    {schema_name}.{dart_value} => '{value}',")

    # Add unspecified if not present
    has_unspecified = any('unspecified' in v.lower() for v in values)
    if not has_unspecified:
        value_entries.insert(0, '  /// Unspecified value.\n  unspecified,')
        to_string_cases.append(f"    {schema_name}.unspecified => '{screaming_prefix}_UNSPECIFIED',")

    camel_name = schema_name[0].lower() + schema_name[1:]

    code = f'''/// {description}
enum {schema_name} {{
{chr(10).join(value_entries)}
}}

/// Converts string to [{schema_name}] enum.
{schema_name} {camel_name}FromString(String? value) {{
  return switch (value?.toUpperCase()) {{
{chr(10).join(from_string_cases)}
    _ => {schema_name}.unspecified,
  }};
}}

/// Converts [{schema_name}] enum to string.
String {camel_name}ToString({schema_name} value) {{
  return switch (value) {{
{chr(10).join(to_string_cases)}
  }};
}}
'''
    return code


def run_batch_mode(config: dict, spec: dict, output_dir: Path, dry_run: bool) -> int:
    """Generate all enums from spec in batch mode."""
    schemas = spec.get('components', {}).get('schemas', {})
    package_name = config.get('package', {}).get('name', '')

    # Find all enum schemas
    enums = [(name, schema) for name, schema in schemas.items() if 'enum' in schema]

    if not enums:
        print("No enum schemas found in spec")
        return 0

    generated = 0
    errors = 0

    for schema_name, schema in sorted(enums):
        try:
            code = generate_enum(schema_name, schema, spec)
            category = get_schema_category(schema_name, config)
            snake_name = to_snake_case(schema_name)
            output_path = output_dir / category / f"{snake_name}.dart"

            if dry_run:
                print(f"Would generate: {output_path}")
            else:
                output_path.parent.mkdir(parents=True, exist_ok=True)
                output_path.write_text(code)
                print(f"Generated: {output_path}")

            generated += 1
        except Exception as e:
            print(f"Error generating {schema_name}: {e}", file=sys.stderr)
            errors += 1

    print(f"\nGenerated {generated} enum(s), {errors} error(s)")
    return 0 if errors == 0 else 1


def main():
    parser = argparse.ArgumentParser(description='Generate Dart enum from OpenAPI schema')
    parser.add_argument(
        '--config-dir', type=Path, required=True,
        help='Directory containing config files'
    )
    parser.add_argument(
        '--schema', '-s', type=str, default=None,
        help='Schema name to generate enum for (single mode)'
    )
    parser.add_argument(
        '--spec', type=str, default='main',
        help='Spec name to use (default: main)'
    )
    parser.add_argument(
        '--output', '-o', type=Path, default=None,
        help='Output file path (single mode, default: stdout)'
    )
    parser.add_argument(
        '--batch', action='store_true',
        help='Generate all enums from spec'
    )
    parser.add_argument(
        '--output-dir', type=Path, default=None,
        help='Output directory for batch mode'
    )
    parser.add_argument(
        '--dry-run', action='store_true',
        help='Print what would be done without writing files'
    )
    args = parser.parse_args()

    # Validate config directory
    if not args.config_dir.exists():
        print(f"Error: Config directory not found: {args.config_dir}", file=sys.stderr)
        sys.exit(2)

    # Load configuration
    config = load_config(args.config_dir)

    # Load spec
    spec = load_spec(config, args.spec)
    if not spec:
        print(f"Error: Could not load spec '{args.spec}'", file=sys.stderr)
        sys.exit(2)

    # Batch mode
    if args.batch:
        if not args.output_dir:
            print("Error: --output-dir is required for batch mode", file=sys.stderr)
            sys.exit(2)
        exit_code = run_batch_mode(config, spec, args.output_dir, args.dry_run)
        sys.exit(exit_code)

    # Single mode
    if not args.schema:
        print("Error: --schema is required (or use --batch)", file=sys.stderr)
        sys.exit(2)

    # Find schema
    schemas = spec.get('components', {}).get('schemas', {})
    schema = schemas.get(args.schema)

    if not schema:
        print(f"Error: Schema '{args.schema}' not found in spec", file=sys.stderr)
        print(f"Available schemas: {', '.join(sorted(schemas.keys())[:20])}...", file=sys.stderr)
        sys.exit(1)

    if 'enum' not in schema:
        print(f"Error: Schema '{args.schema}' is not an enum", file=sys.stderr)
        sys.exit(1)

    # Generate code
    try:
        code = generate_enum(args.schema, schema, spec)
    except Exception as e:
        print(f"Error generating enum: {e}", file=sys.stderr)
        sys.exit(1)

    # Output
    if args.dry_run or not args.output:
        print(code)
    else:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(code)
        print(f"Generated: {args.output}")

    sys.exit(0)


if __name__ == '__main__':
    main()
