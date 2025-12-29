#!/usr/bin/env python3
"""
Generate Dart model class from OpenAPI schema.

Usage:
    python3 generate_model.py --config-dir CONFIG_DIR --schema SCHEMA_NAME --output OUTPUT_PATH
    python3 generate_model.py --config-dir CONFIG_DIR --schema SCHEMA_NAME --dry-run
    python3 generate_model.py --config-dir CONFIG_DIR --batch --output-dir OUTPUT_DIR [--skip SCHEMAS]

Examples:
    python3 generate_model.py --config-dir config/ --schema FileSearchStore --output lib/src/models/files/file_search_store.dart
    python3 generate_model.py --config-dir config/ --schema GenerationConfig --dry-run
    python3 generate_model.py --config-dir config/ --batch --output-dir lib/src/models --skip Part,Content

Exit codes:
    0 - Success
    1 - Schema not found or is an enum
    2 - Config error
"""

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


def load_config(config_dir: Path) -> dict:
    """Load configuration from config directory."""
    config = {
        'package': {},
        'specs': {},
        'schemas': {},
    }

    package_file = config_dir / 'package.json'
    if package_file.exists():
        with open(package_file) as f:
            config['package'] = json.load(f)

    specs_file = config_dir / 'specs.json'
    if specs_file.exists():
        with open(specs_file) as f:
            config['specs'] = json.load(f)

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
        spec_path = Path(f'packages/{package_name}/{local_file}')

    if not spec_path.exists():
        return None

    with open(spec_path) as f:
        return json.load(f)


def to_snake_case(name: str) -> str:
    """Convert PascalCase to snake_case."""
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()


def resolve_ref(ref: str, spec: dict) -> tuple[str, dict]:
    """Resolve a $ref to schema name and schema dict."""
    if not ref.startswith('#/components/schemas/'):
        return ref, {}
    schema_name = ref.split('/')[-1]
    schemas = spec.get('components', {}).get('schemas', {})
    return schema_name, schemas.get(schema_name, {})


def get_dart_type(prop: dict, spec: dict, nullable: bool = True) -> tuple[str, str, str]:
    """
    Get Dart type info for a property.
    Returns: (dart_type, from_json_expr, to_json_expr)
    """
    suffix = '?' if nullable else ''

    if '$ref' in prop:
        ref_name, ref_schema = resolve_ref(prop['$ref'], spec)
        if ref_schema.get('enum'):
            # Enum type
            camel_name = ref_name[0].lower() + ref_name[1:]
            return (
                f'{ref_name}{suffix}',
                f'{camel_name}FromString(json[\'{{prop}}\'] as String?)',
                f'if ({{prop}} != null) \'{{prop}}\': {camel_name}ToString({{prop}}!)'
            )
        else:
            # Object type
            return (
                f'{ref_name}{suffix}',
                f'json[\'{{prop}}\'] != null ? {ref_name}.fromJson(json[\'{{prop}}\'] as Map<String, dynamic>) : null',
                f'if ({{prop}} != null) \'{{prop}}\': {{prop}}!.toJson()'
            )

    prop_type = prop.get('type', 'object')

    if prop_type == 'string':
        return (
            f'String{suffix}',
            f'json[\'{{prop}}\'] as String{suffix}',
            f'if ({{prop}} != null) \'{{prop}}\': {{prop}}'
        )
    elif prop_type == 'integer':
        return (
            f'int{suffix}',
            f'json[\'{{prop}}\'] as int{suffix}',
            f'if ({{prop}} != null) \'{{prop}}\': {{prop}}'
        )
    elif prop_type == 'number':
        return (
            f'double{suffix}',
            f'(json[\'{{prop}}\'] as num{suffix})?.toDouble()',
            f'if ({{prop}} != null) \'{{prop}}\': {{prop}}'
        )
    elif prop_type == 'boolean':
        return (
            f'bool{suffix}',
            f'json[\'{{prop}}\'] as bool{suffix}',
            f'if ({{prop}} != null) \'{{prop}}\': {{prop}}'
        )
    elif prop_type == 'array':
        items = prop.get('items', {})
        if '$ref' in items:
            ref_name, ref_schema = resolve_ref(items['$ref'], spec)
            if ref_schema.get('enum'):
                camel_name = ref_name[0].lower() + ref_name[1:]
                return (
                    f'List<{ref_name}>{suffix}',
                    f'(json[\'{{prop}}\'] as List?)?.map((e) => {camel_name}FromString(e as String?)).toList()',
                    f'if ({{prop}} != null) \'{{prop}}\': {{prop}}!.map((e) => {camel_name}ToString(e)).toList()'
                )
            else:
                return (
                    f'List<{ref_name}>{suffix}',
                    f'(json[\'{{prop}}\'] as List?)?.map((e) => {ref_name}.fromJson(e as Map<String, dynamic>)).toList()',
                    f'if ({{prop}} != null) \'{{prop}}\': {{prop}}!.map((e) => e.toJson()).toList()'
                )
        else:
            item_type = items.get('type', 'dynamic')
            dart_item = {'string': 'String', 'integer': 'int', 'number': 'double', 'boolean': 'bool'}.get(item_type, 'dynamic')
            return (
                f'List<{dart_item}>{suffix}',
                f'(json[\'{{prop}}\'] as List?)?.cast<{dart_item}>()',
                f'if ({{prop}} != null) \'{{prop}}\': {{prop}}'
            )
    elif prop_type == 'object':
        additional = prop.get('additionalProperties')
        if additional:
            if additional.get('type') == 'string':
                return (
                    f'Map<String, String>{suffix}',
                    f'(json[\'{{prop}}\'] as Map?)?.cast<String, String>()',
                    f'if ({{prop}} != null) \'{{prop}}\': {{prop}}'
                )
            else:
                return (
                    f'Map<String, dynamic>{suffix}',
                    f'json[\'{{prop}}\'] as Map<String, dynamic>{suffix}',
                    f'if ({{prop}} != null) \'{{prop}}\': {{prop}}'
                )
        return (
            f'Map<String, dynamic>{suffix}',
            f'json[\'{{prop}}\'] as Map<String, dynamic>{suffix}',
            f'if ({{prop}} != null) \'{{prop}}\': {{prop}}'
        )
    else:
        return (
            f'dynamic',
            f'json[\'{{prop}}\']',
            f'if ({{prop}} != null) \'{{prop}}\': {{prop}}'
        )


def generate_model(schema_name: str, schema: dict, spec: dict) -> str:
    """Generate Dart model class code from schema."""
    description = schema.get('description', f'{schema_name} model.')
    properties = schema.get('properties', {})
    required = set(schema.get('required', []))

    if not properties:
        # Empty class
        return f'''/// {description}
class {schema_name} {{
  /// Creates a [{schema_name}].
  const {schema_name}();

  /// Creates a [{schema_name}] from JSON.
  factory {schema_name}.fromJson(Map<String, dynamic> json) => const {schema_name}();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {{}};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is {schema_name} && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => \'{schema_name}()\';
}}
'''

    # Collect property info
    props = []
    for prop_name, prop_def in properties.items():
        is_required = prop_name in required
        dart_type, from_json, to_json = get_dart_type(prop_def, spec, nullable=not is_required)
        prop_desc = prop_def.get('description', f'The {prop_name}.')
        props.append({
            'name': prop_name,
            'dart_type': dart_type,
            'from_json': from_json.replace('{prop}', prop_name),
            'to_json': to_json.replace('{prop}', prop_name),
            'description': prop_desc,
            'required': is_required,
        })

    # Generate field declarations
    field_lines = []
    for p in props:
        field_lines.append(f"  /// {p['description']}")
        field_lines.append(f"  final {p['dart_type']} {p['name']};")
        field_lines.append('')

    # Generate constructor parameters
    ctor_params = []
    for p in props:
        prefix = 'required ' if p['required'] else ''
        ctor_params.append(f"    {prefix}this.{p['name']},")

    # Generate fromJson body
    from_json_lines = []
    for p in props:
        from_json_lines.append(f"        {p['name']}: {p['from_json']},")

    # Generate toJson body
    to_json_lines = []
    for p in props:
        to_json_lines.append(f"        {p['to_json']},")

    # Generate copyWith parameters and body
    copy_params = []
    copy_body = []
    for p in props:
        copy_params.append(f"    Object? {p['name']} = unsetCopyWithValue,")
        base_type = p['dart_type'].rstrip('?')
        nullable_type = f"{base_type}?"
        copy_body.append(f"      {p['name']}:")
        copy_body.append(f"          {p['name']} == unsetCopyWithValue")
        copy_body.append(f"              ? this.{p['name']}")
        copy_body.append(f"              : {p['name']} as {nullable_type},")

    # Generate equality
    eq_conditions = [f"{p['name']} == other.{p['name']}" for p in props]
    eq_body = ' &&\n          '.join(eq_conditions)

    # Generate hashCode
    prop_names = [p['name'] for p in props]
    if len(prop_names) <= 20:
        hash_body = f"Object.hash({', '.join(prop_names)})"
    else:
        hash_body = f"Object.hashAll([{', '.join(prop_names)}])"

    # Generate toString
    to_string_parts = [f"{p['name']}: ${p['name']}" for p in props]
    to_string_body = ', '.join(to_string_parts)

    code = f'''import '../copy_with_sentinel.dart';

/// {description}
class {schema_name} {{
{chr(10).join(field_lines)}
  /// Creates a [{schema_name}].
  const {schema_name}({{
{chr(10).join(ctor_params)}
  }});

  /// Creates a [{schema_name}] from JSON.
  factory {schema_name}.fromJson(Map<String, dynamic> json) => {schema_name}(
{chr(10).join(from_json_lines)}
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {{
{chr(10).join(to_json_lines)}
      }};

  /// Creates a copy with replaced values.
  {schema_name} copyWith({{
{chr(10).join(copy_params)}
  }}) {{
    return {schema_name}(
{chr(10).join(copy_body)}
    );
  }}

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is {schema_name} &&
          runtimeType == other.runtimeType &&
          {eq_body};

  @override
  int get hashCode => {hash_body};

  @override
  String toString() => \'{schema_name}({to_string_body})\';
}}
'''
    return code


def run_batch_mode(config: dict, spec: dict, output_dir: Path, skip_schemas: set, dry_run: bool) -> int:
    """Generate all models from spec in batch mode."""
    schemas = spec.get('components', {}).get('schemas', {})

    # Find all model schemas (not enums)
    models = [(name, schema) for name, schema in schemas.items()
              if 'enum' not in schema and name not in skip_schemas]

    if not models:
        print("No model schemas found in spec (after filtering)")
        return 0

    generated = 0
    errors = 0

    for schema_name, schema in sorted(models):
        try:
            code = generate_model(schema_name, schema, spec)
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

    print(f"\nGenerated {generated} model(s), {errors} error(s)")
    if skip_schemas:
        print(f"Skipped: {', '.join(sorted(skip_schemas))}")
    return 0 if errors == 0 else 1


def main():
    parser = argparse.ArgumentParser(description='Generate Dart model from OpenAPI schema')
    parser.add_argument(
        '--config-dir', type=Path, required=True,
        help='Directory containing config files'
    )
    parser.add_argument(
        '--schema', '-s', type=str, default=None,
        help='Schema name to generate model for (single mode)'
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
        help='Generate all models from spec'
    )
    parser.add_argument(
        '--output-dir', type=Path, default=None,
        help='Output directory for batch mode'
    )
    parser.add_argument(
        '--skip', type=str, default='',
        help='Comma-separated list of schema names to skip (for sealed class parents)'
    )
    parser.add_argument(
        '--dry-run', action='store_true',
        help='Print what would be done without writing files'
    )
    args = parser.parse_args()

    if not args.config_dir.exists():
        print(f"Error: Config directory not found: {args.config_dir}", file=sys.stderr)
        sys.exit(2)

    config = load_config(args.config_dir)

    spec = load_spec(config, args.spec)
    if not spec:
        print(f"Error: Could not load spec '{args.spec}'", file=sys.stderr)
        sys.exit(2)

    # Batch mode
    if args.batch:
        if not args.output_dir:
            print("Error: --output-dir is required for batch mode", file=sys.stderr)
            sys.exit(2)
        skip_schemas = set(s.strip() for s in args.skip.split(',') if s.strip())
        exit_code = run_batch_mode(config, spec, args.output_dir, skip_schemas, args.dry_run)
        sys.exit(exit_code)

    # Single mode
    if not args.schema:
        print("Error: --schema is required (or use --batch)", file=sys.stderr)
        sys.exit(2)

    schemas = spec.get('components', {}).get('schemas', {})
    schema = schemas.get(args.schema)

    if not schema:
        print(f"Error: Schema '{args.schema}' not found in spec", file=sys.stderr)
        print(f"Available schemas: {', '.join(sorted(schemas.keys())[:20])}...", file=sys.stderr)
        sys.exit(1)

    if 'enum' in schema:
        print(f"Error: Schema '{args.schema}' is an enum, use generate_enum.py instead", file=sys.stderr)
        sys.exit(1)

    try:
        code = generate_model(args.schema, schema, spec)
    except Exception as e:
        print(f"Error generating model: {e}", file=sys.stderr)
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
