#!/usr/bin/env python3
"""
Generate Dart WebSocket config class from schema config.

Usage:
    python3 generate_config.py --config-dir CONFIG_DIR --config CONFIG_NAME [--output PATH]
    python3 generate_config.py --config-dir CONFIG_DIR --config CONFIG_NAME --dry-run

Examples:
    python3 generate_config.py --config-dir config/ --config LiveGenerationConfig --dry-run
    python3 generate_config.py --config-dir config/ --list-configs

Exit codes:
    0 - Success
    1 - Config type not found
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
        'schema': {},
        'specs': {},
    }

    package_file = config_dir / 'package.json'
    if package_file.exists():
        with open(package_file) as f:
            config['package'] = json.load(f)

    schema_file = config_dir / 'schema.json'
    if schema_file.exists():
        with open(schema_file) as f:
            config['schema'] = json.load(f)

    specs_file = config_dir / 'specs.json'
    if specs_file.exists():
        with open(specs_file) as f:
            config['specs'] = json.load(f)

    return config


def to_snake_case(name: str) -> str:
    """Convert PascalCase to snake_case."""
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\\1_\\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\\1_\\2', s1).lower()


def get_dart_type(type_str: str, required: bool = False) -> str:
    """Map schema type to Dart type."""
    type_map = {
        'string': 'String',
        'integer': 'int',
        'number': 'double',
        'boolean': 'bool',
        'object': 'Map<String, dynamic>',
        'array': 'List<dynamic>',
    }

    # Handle List<T> patterns
    if type_str.startswith('List<'):
        return type_str + ('' if required else '?')

    dart_type = type_map.get(type_str, type_str)
    return dart_type + ('' if required else '?')


def generate_config_class(
    config_name: str,
    config_def: dict,
    config: dict,
) -> str:
    """Generate Dart config class code."""
    description = config_def.get('description', f'{config_name} configuration.')
    fields = config_def.get('fields', {})

    # Generate field declarations
    field_lines = []
    ctor_params = []
    from_json_lines = []
    to_json_lines = []
    copy_params = []
    copy_body = []

    for field_name, field_def in fields.items():
        field_type = field_def.get('type', 'dynamic')
        required = field_def.get('required', False)
        field_desc = field_def.get('description', f'The {field_name}.')

        # Handle array types
        if field_type == 'array':
            items_type = field_def.get('items', 'dynamic')
            dart_type = f'List<{items_type}>' + ('' if required else '?')
        else:
            dart_type = get_dart_type(field_type, required)

        field_lines.append(f"  /// {field_desc}")
        field_lines.append(f"  final {dart_type} {field_name};")
        field_lines.append('')

        prefix = 'required ' if required else ''
        ctor_params.append(f"    {prefix}this.{field_name},")

        # fromJson - check if it's a nested config type
        base_type = dart_type.rstrip('?')
        is_list = base_type.startswith('List<')

        if is_list:
            inner_type = base_type[5:-1]  # Extract type from List<Type>
            if inner_type in ('String', 'int', 'double', 'bool', 'dynamic'):
                from_json_lines.append(
                    f"      {field_name}: (json['{field_name}'] as List?)?.cast<{inner_type}>(),"
                )
            else:
                from_json_lines.append(
                    f"      {field_name}: (json['{field_name}'] as List?)?.map("
                )
                from_json_lines.append(
                    f"        (e) => {inner_type}.fromJson(e as Map<String, dynamic>)"
                )
                from_json_lines.append(f"      ).toList(),")
        elif base_type in ('String', 'int', 'double', 'bool', 'dynamic', 'Map<String, dynamic>'):
            from_json_lines.append(
                f"      {field_name}: json['{field_name}'] as {dart_type},"
            )
        else:
            # Nested config type
            from_json_lines.append(
                f"      {field_name}: json['{field_name}'] != null"
            )
            from_json_lines.append(
                f"          ? {base_type}.fromJson(json['{field_name}'] as Map<String, dynamic>)"
            )
            from_json_lines.append(f"          : null,")

        # toJson
        if is_list:
            inner_type = base_type[5:-1]
            if inner_type in ('String', 'int', 'double', 'bool', 'dynamic'):
                to_json_lines.append(f"      if ({field_name} != null) '{field_name}': {field_name},")
            else:
                to_json_lines.append(
                    f"      if ({field_name} != null) '{field_name}': {field_name}!.map((e) => e.toJson()).toList(),"
                )
        elif base_type in ('String', 'int', 'double', 'bool', 'dynamic', 'Map<String, dynamic>'):
            to_json_lines.append(f"      if ({field_name} != null) '{field_name}': {field_name},")
        else:
            to_json_lines.append(
                f"      if ({field_name} != null) '{field_name}': {field_name}!.toJson(),"
            )

        # copyWith
        copy_params.append(f"    Object? {field_name} = unsetCopyWithValue,")
        nullable_type = base_type + '?'
        copy_body.append(f"      {field_name}: {field_name} == unsetCopyWithValue")
        copy_body.append(f"          ? this.{field_name}")
        copy_body.append(f"          : {field_name} as {nullable_type},")

    # Generate equality
    eq_conditions = [f"{name} == other.{name}" for name in fields.keys()]
    eq_body = ' &&\\n          '.join(eq_conditions) if eq_conditions else 'true'

    # Generate hashCode
    prop_names = list(fields.keys())
    if len(prop_names) == 0:
        hash_body = "runtimeType.hashCode"
    elif len(prop_names) <= 20:
        hash_body = f"Object.hash({', '.join(prop_names)})"
    else:
        hash_body = f"Object.hashAll([{', '.join(prop_names)}])"

    # Generate toString
    to_string_parts = [f"{name}: ${name}" for name in fields.keys()]
    to_string_body = ', '.join(to_string_parts)

    code = f"""import '../copy_with_sentinel.dart';

/// {description}
class {config_name} {{
{chr(10).join(field_lines) if field_lines else ''}
  /// Creates a [{config_name}].
  const {config_name}({{
{chr(10).join(ctor_params) if ctor_params else ''}
  }});

  /// Creates a [{config_name}] from JSON.
  factory {config_name}.fromJson(Map<String, dynamic> json) {{
    return {config_name}(
{chr(10).join(from_json_lines) if from_json_lines else ''}
    );
  }}

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {{
{chr(10).join(to_json_lines) if to_json_lines else ''}
    }};

  /// Creates a copy with replaced values.
  {config_name} copyWith({{
{chr(10).join(copy_params) if copy_params else ''}
  }}) {{
    return {config_name}(
{chr(10).join(copy_body) if copy_body else ''}
    );
  }}

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is {config_name} &&
          runtimeType == other.runtimeType &&
          {eq_body};

  @override
  int get hashCode => {hash_body};

  @override
  String toString() => '{config_name}({to_string_body})';
}}
"""
    return code


def list_configs(config: dict) -> None:
    """List all available config types from schema config."""
    schema = config.get('schema', {})
    config_types = schema.get('config_types', {})

    print("Available Config Types:")
    print()

    if config_types:
        for name, config_def in config_types.items():
            fields = config_def.get('fields', {})
            print(f"  - {name}: {len(fields)} fields")
    else:
        print("  No config types defined in schema")
    print()


def main():
    parser = argparse.ArgumentParser(description='Generate Dart WebSocket config class')
    parser.add_argument(
        '--config-dir', type=Path, required=True,
        help='Directory containing config files'
    )
    parser.add_argument(
        '--config', '-c', type=str,
        help='Config type name to generate'
    )
    parser.add_argument(
        '--output', '-o', type=Path, default=None,
        help='Output file path (default: stdout)'
    )
    parser.add_argument(
        '--dry-run', action='store_true',
        help='Print to stdout instead of writing file'
    )
    parser.add_argument(
        '--list-configs', action='store_true',
        help='List available config types from schema'
    )
    args = parser.parse_args()

    if not args.config_dir.exists():
        print(f"Error: Config directory not found: {args.config_dir}", file=sys.stderr)
        sys.exit(2)

    config = load_config(args.config_dir)

    if args.list_configs:
        list_configs(config)
        sys.exit(0)

    if not args.config:
        print("Error: --config is required (or use --list-configs)", file=sys.stderr)
        sys.exit(2)

    # Find config type in schema
    schema = config.get('schema', {})
    config_types = schema.get('config_types', {})

    config_def = config_types.get(args.config)

    if not config_def:
        print(f"Error: Config type '{args.config}' not found in schema", file=sys.stderr)
        print("\\nUse --list-configs to see available config types", file=sys.stderr)
        sys.exit(1)

    try:
        code = generate_config_class(args.config, config_def, config)
    except Exception as e:
        print(f"Error generating config: {e}", file=sys.stderr)
        sys.exit(1)

    if args.dry_run or not args.output:
        print(code)
    else:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(code)
        print(f"Generated: {args.output}")

    sys.exit(0)


if __name__ == '__main__':
    main()
