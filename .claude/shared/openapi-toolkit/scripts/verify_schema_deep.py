#!/usr/bin/env python3
"""
Deep verification of Dart model classes against OpenAPI spec.

This script performs schema verification including:
1. Property name validation (checks that all spec properties exist in Dart)
2. Required/optional (nullable) validation
3. Nested schema verification
4. Sealed class variant verification

Note: Full type validation is not yet implemented. The script currently
focuses on property presence and nullability checks.

Usage:
    python3 verify_schema_deep.py --config-dir CONFIG_DIR --spec SPEC_FILE

Exit codes:
    0 - All verifications pass
    1 - Issues found
    2 - Error (missing files, invalid config, etc.)
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Optional


@dataclass
class Issue:
    """Represents a verification issue."""
    level: str  # 'error', 'warning', or 'info'
    schema: str
    message: str
    property_name: Optional[str] = None


@dataclass
class DartProperty:
    """Represents a Dart property with type info."""
    name: str
    dart_type: str
    is_nullable: bool
    line_number: int


# Default type mappings from OpenAPI to Dart
DEFAULT_TYPE_MAPPINGS = {
    'string': 'String',
    'integer': 'int',
    'number': 'double',
    'boolean': 'bool',
    'array': 'List',
    'object': 'Map',
}


def get_level_marker(level: str) -> str:
    """Get the display marker for an issue level."""
    if level == 'error':
        return '!'
    elif level == 'warning':
        return '?'
    return 'i'


def load_config(config_dir: Path) -> dict:
    """Load configuration from config directory."""
    config = {
        'critical_models': [],
        'nested_schemas': [],
        'sealed_classes': [],
        'type_mappings': DEFAULT_TYPE_MAPPINGS.copy(),
        'excluded_properties': {'global': []},
    }

    models_file = config_dir / 'models.json'
    if models_file.exists():
        try:
            with open(models_file) as f:
                data = json.load(f)
                config['critical_models'] = data.get('critical_models', [])
                config['nested_schemas'] = data.get('nested_schemas', [])
                config['sealed_classes'] = data.get('sealed_classes', [])
                if 'type_mappings' in data:
                    config['type_mappings'].update(data['type_mappings'])
                if 'excluded_properties' in data:
                    config['excluded_properties'].update(data['excluded_properties'])
        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON in {models_file}: {e}")
            sys.exit(2)
        except (OSError, IOError) as e:
            print(f"Error: Unable to read config file {models_file}: {e}")
            sys.exit(2)

    return config


def load_openapi_spec(spec_path: Path) -> dict:
    """Load OpenAPI specification (JSON or YAML)."""
    try:
        content = spec_path.read_text()
    except (OSError, IOError) as e:
        print(f"Error: Unable to read OpenAPI spec {spec_path}: {e}")
        sys.exit(2)

    # Try JSON first
    try:
        return json.loads(content)
    except json.JSONDecodeError:
        pass

    # Try YAML
    try:
        import yaml
        return yaml.safe_load(content)
    except ImportError:
        print("ERROR: PyYAML not available.", file=sys.stderr)
        print(f"       Install: {sys.executable} -m pip install pyyaml --user", file=sys.stderr)
        sys.exit(2)
    except Exception as e:
        print(f"Error: Failed to parse spec: {e}", file=sys.stderr)
        sys.exit(2)


def extract_dart_properties_with_types(
    file_path: Path,
    class_name: Optional[str] = None
) -> dict[str, DartProperty]:
    """
    Extract properties with types from a Dart class file.

    Args:
        file_path: Path to the Dart file
        class_name: Optional class name to target (for files with multiple classes)

    Returns:
        Dictionary mapping property names to DartProperty objects
    """
    if not file_path.exists():
        return {}

    try:
        content = file_path.read_text()
    except (OSError, UnicodeDecodeError) as e:
        print(f"Warning: Could not read Dart file {file_path}: {e}", file=sys.stderr)
        return {}

    properties = {}

    # Pattern for final field declarations: final Type? propertyName;
    # Captures: full type (including generics), property name, optional ?
    field_pattern = r'^\s*final\s+([\w<>?,\s]+?)\s+(\w+)\s*;'

    # Pattern for getter declarations: Type get propertyName => ...;
    # or: Type get propertyName { ... }
    # Captures: return type (including generics), property name
    getter_pattern = r'^\s*([\w<>?,\s]+?)\s+get\s+(\w+)\s*(?:=>|{)'

    # If class_name is specified, find that class's content
    if class_name:
        # Find the class block
        # Note: This regex assumes standard Dart class patterns without deeply nested
        # braces in the class signature. Works for typical generated model classes.
        class_pattern = rf'class\s+{re.escape(class_name)}\s*[^{{]*\{{(.*?)\n}}'
        class_match = re.search(class_pattern, content, re.DOTALL)
        if class_match:
            content = class_match.group(0)

    lines = content.split('\n')
    for line_num, line in enumerate(lines, 1):
        # Try to match final field declarations first
        match = re.match(field_pattern, line)
        if match:
            full_type = match.group(1).strip()
            prop_name = match.group(2)

            # Check if nullable
            is_nullable = full_type.endswith('?')
            dart_type = full_type.rstrip('?').strip()

            properties[prop_name] = DartProperty(
                name=prop_name,
                dart_type=dart_type,
                is_nullable=is_nullable,
                line_number=line_num
            )
            continue

        # Try to match getter declarations
        getter_match = re.match(getter_pattern, line)
        if getter_match:
            full_type = getter_match.group(1).strip()
            prop_name = getter_match.group(2)

            # Skip if the extracted "type" is actually a keyword or empty
            # (can happen with malformed matches or static/abstract getters)
            if full_type in ('', '@override', 'static', 'abstract'):
                continue

            # Check if nullable
            is_nullable = full_type.endswith('?')
            dart_type = full_type.rstrip('?').strip()

            # Don't overwrite if we already have a field declaration
            if prop_name not in properties:
                properties[prop_name] = DartProperty(
                    name=prop_name,
                    dart_type=dart_type,
                    is_nullable=is_nullable,
                    line_number=line_num
                )

    return properties


def get_schema_properties(spec: dict, schema_name: str) -> dict:
    """
    Get properties from an OpenAPI schema with full type info.

    Returns dict of property_name -> {
        'type': openapi_type,
        'required': bool,
        'ref': optional_ref_name,
        'items': for arrays,
        'format': optional format
    }
    """
    schemas = spec.get('components', {}).get('schemas', {})
    schema = schemas.get(schema_name, {})

    if not schema:
        return {}

    properties = {}
    required_set = set(schema.get('required', []))

    # Direct properties
    for prop_name, prop_spec in schema.get('properties', {}).items():
        # Skip underscore-prefixed properties - these are typically internal/metadata
        # fields in OpenAPI specs that don't map to public Dart class properties
        if prop_name.startswith('_'):
            continue

        prop_info = parse_property_spec(prop_spec, required_set, prop_name)
        properties[prop_name] = prop_info

    # Handle allOf (merged schemas)
    for item in schema.get('allOf', []):
        if 'properties' in item:
            item_required = set(item.get('required', []))
            for prop_name, prop_spec in item['properties'].items():
                # Skip underscore-prefixed properties (same as direct properties)
                if prop_name.startswith('_'):
                    continue
                prop_info = parse_property_spec(prop_spec, item_required, prop_name)
                properties[prop_name] = prop_info
        elif '$ref' in item:
            ref_name = item['$ref'].split('/')[-1]
            ref_props = get_schema_properties(spec, ref_name)
            properties.update(ref_props)

    return properties


def parse_property_spec(
    prop_spec: dict,
    required_set: set,
    prop_name: str
) -> dict:
    """Parse a single property specification."""
    result = {
        'required': prop_name in required_set,
        'type': None,
        'ref': None,
        'items': None,
        'format': prop_spec.get('format'),
    }

    # Handle anyOf (often used for nullable)
    if 'anyOf' in prop_spec:
        any_of = prop_spec['anyOf']
        non_null_types = [t for t in any_of if t.get('type') != 'null']
        if non_null_types:
            # If there's anyOf with null, it's optional even if in required
            has_null = any(t.get('type') == 'null' for t in any_of)
            if has_null:
                result['required'] = False

            # Use the first non-null type
            first_type = non_null_types[0]
            if '$ref' in first_type:
                result['ref'] = first_type['$ref'].split('/')[-1]
            elif 'allOf' in first_type:
                # Handle nested allOf
                for nested in first_type['allOf']:
                    if '$ref' in nested:
                        result['ref'] = nested['$ref'].split('/')[-1]
                        break
            else:
                result['type'] = first_type.get('type')
                result['items'] = first_type.get('items')
        return result

    # Handle direct $ref
    if '$ref' in prop_spec:
        result['ref'] = prop_spec['$ref'].split('/')[-1]
        return result

    # Handle allOf at property level
    if 'allOf' in prop_spec:
        for item in prop_spec['allOf']:
            if '$ref' in item:
                result['ref'] = item['$ref'].split('/')[-1]
                break
        return result

    # Direct type
    result['type'] = prop_spec.get('type')
    result['items'] = prop_spec.get('items')

    return result


def map_openapi_to_dart_type(
    prop_info: dict,
    spec: dict,
    type_mappings: dict
) -> str:
    """
    Convert OpenAPI property info to expected Dart type.

    Returns the expected Dart type string.
    """
    # If it's a reference, use the reference name as the type
    if prop_info.get('ref'):
        ref_name = prop_info['ref']
        # Check if ref is an enum
        schemas = spec.get('components', {}).get('schemas', {})
        ref_schema = schemas.get(ref_name, {})
        if ref_schema.get('enum'):
            # It's an enum - the Dart type is the enum name
            return ref_name
        return ref_name

    openapi_type = prop_info.get('type')

    if not openapi_type:
        return 'dynamic'

    # Handle arrays
    if openapi_type == 'array':
        items = prop_info.get('items', {})
        if '$ref' in items:
            item_type = items['$ref'].split('/')[-1]
        else:
            item_type = type_mappings.get(items.get('type', 'dynamic'), 'dynamic')
        return f'List<{item_type}>'

    # Handle objects with additionalProperties (Map)
    if openapi_type == 'object':
        return 'Map<String, dynamic>'

    # Simple type mapping
    return type_mappings.get(openapi_type, openapi_type)


def to_camel_case(name: str) -> str:
    """Convert snake_case to camelCase."""
    if '_' not in name:
        return name
    parts = name.split('_')
    return parts[0] + ''.join(p.title() for p in parts[1:])


def verify_schema(
    spec: dict,
    schema_name: str,
    dart_file: Path,
    dart_class_name: Optional[str],
    type_mappings: dict,
    excluded_props: set,
    verbose: bool = False
) -> list[Issue]:
    """
    Verify a single schema against its Dart implementation.

    Returns list of issues found.
    """
    issues = []

    # Get spec properties
    spec_props = get_schema_properties(spec, schema_name)
    if not spec_props:
        issues.append(Issue(
            level='warning',
            schema=schema_name,
            message=f"Schema '{schema_name}' not found in OpenAPI spec"
        ))
        return issues

    # Get Dart properties
    dart_props = extract_dart_properties_with_types(dart_file, dart_class_name)
    if not dart_props:
        issues.append(Issue(
            level='error',
            schema=schema_name,
            message=f"Could not extract properties from {dart_file}"
        ))
        return issues

    # Check each spec property
    for spec_prop_name, spec_prop_info in spec_props.items():
        if spec_prop_name in excluded_props:
            continue

        # Convert to camelCase for Dart
        dart_prop_name = to_camel_case(spec_prop_name)

        if dart_prop_name not in dart_props:
            expected_type = map_openapi_to_dart_type(spec_prop_info, spec, type_mappings)
            req_status = 'required' if spec_prop_info['required'] else 'optional'
            issues.append(Issue(
                level='error',
                schema=schema_name,
                property_name=spec_prop_name,
                message=f"Missing property '{spec_prop_name}' ({expected_type}, {req_status})"
            ))
            continue

        dart_prop = dart_props[dart_prop_name]

        # Check required/optional matches nullable
        if spec_prop_info['required'] and dart_prop.is_nullable:
            issues.append(Issue(
                level='warning',
                schema=schema_name,
                property_name=spec_prop_name,
                message=f"Property '{spec_prop_name}' is required in spec but nullable in Dart"
            ))
        elif not spec_prop_info['required'] and not dart_prop.is_nullable:
            # This is often intentional (Dart uses default values), so just a verbose warning
            if verbose:
                issues.append(Issue(
                    level='info',
                    schema=schema_name,
                    property_name=spec_prop_name,
                    message=f"Property '{spec_prop_name}' is optional in spec but non-nullable in Dart"
                ))

    return issues


def verify_sealed_class(
    spec: dict,
    sealed_config: dict,
    type_mappings: dict,
    excluded_props: set,
    verbose: bool = False
) -> list[Issue]:
    """
    Verify a sealed class and all its variants.

    Returns list of issues found.
    """
    issues = []

    # Validate required config keys
    if 'name' not in sealed_config:
        issues.append(Issue(
            level='error',
            schema='<unknown>',
            message="Sealed class config missing required 'name' key"
        ))
        return issues
    if 'file' not in sealed_config:
        issues.append(Issue(
            level='error',
            schema=sealed_config['name'],
            message="Sealed class config missing required 'file' key"
        ))
        return issues

    sealed_name = sealed_config['name']
    dart_file = Path(sealed_config['file'])

    if not dart_file.exists():
        issues.append(Issue(
            level='error',
            schema=sealed_name,
            message=f"Sealed class file not found: {dart_file}"
        ))
        return issues

    for variant in sealed_config.get('variants', []):
        # Validate required variant keys
        if 'dart_class' not in variant:
            issues.append(Issue(
                level='error',
                schema=sealed_name,
                message="Variant config missing required 'dart_class' key"
            ))
            continue

        dart_class = variant['dart_class']
        spec_schema = variant.get('spec_schema')
        is_extension = variant.get('extension', False)

        # Skip extension classes (not in spec)
        if is_extension or spec_schema is None:
            if verbose:
                issues.append(Issue(
                    level='info',
                    schema=dart_class,
                    message="Skipped (extension class, not in spec)"
                ))
            continue

        # Verify this variant
        variant_issues = verify_schema(
            spec=spec,
            schema_name=spec_schema,
            dart_file=dart_file,
            dart_class_name=dart_class,
            type_mappings=type_mappings,
            excluded_props=excluded_props,
            verbose=verbose
        )

        issues.extend(variant_issues)

    return issues


def main():
    parser = argparse.ArgumentParser(
        description='Deep verification of Dart models against OpenAPI spec.'
    )
    parser.add_argument(
        '--config-dir', type=Path, required=True,
        help='Directory containing config files (models.json)'
    )
    parser.add_argument(
        '--spec', '-s', type=Path, required=True,
        help='Path to OpenAPI spec file'
    )
    parser.add_argument(
        '--verbose', '-v', action='store_true',
        help='Show detailed output including info-level messages'
    )
    parser.add_argument(
        '--schema', type=str,
        help='Check only a specific schema'
    )
    args = parser.parse_args()

    # Validate inputs
    if not args.config_dir.exists():
        print(f"Error: Config directory not found: {args.config_dir}")
        sys.exit(2)

    if not args.spec.exists():
        print(f"Error: OpenAPI spec not found: {args.spec}")
        sys.exit(2)

    # Load configuration
    config = load_config(args.config_dir)
    type_mappings = config['type_mappings']
    excluded = config['excluded_properties']
    global_excluded = set(excluded.get('global', []))

    # Load spec
    spec = load_openapi_spec(args.spec)

    print("Deep Schema Verification")
    print("=" * 60)
    print()

    all_issues = []

    # Verify critical models
    if config['critical_models']:
        print("Checking critical models...")
        for model in config['critical_models']:
            # Validate required config keys
            if 'name' not in model:
                print("  [!] <unknown>: Critical model config missing required 'name' key")
                all_issues.append(Issue(
                    level='error',
                    schema='<unknown>',
                    message="Critical model config missing required 'name' key"
                ))
                continue
            if 'file' not in model:
                print(f"  [!] {model['name']}: Critical model config missing required 'file' key")
                all_issues.append(Issue(
                    level='error',
                    schema=model['name'],
                    message="Critical model config missing required 'file' key"
                ))
                continue

            model_name = model['name']
            if args.schema and model_name != args.schema:
                continue

            spec_schema = model.get('spec_schema', model_name)
            dart_file = Path(model['file'])
            dart_class = model.get('class_name')
            model_excluded = global_excluded | set(excluded.get(spec_schema, []))

            issues = verify_schema(
                spec=spec,
                schema_name=spec_schema,
                dart_file=dart_file,
                dart_class_name=dart_class,
                type_mappings=type_mappings,
                excluded_props=model_excluded,
                verbose=args.verbose
            )

            if not issues:
                print(f"  [PASS] {model_name}")
            else:
                for issue in issues:
                    all_issues.append(issue)
                    level_marker = get_level_marker(issue.level)
                    print(f"  [{level_marker}] {model_name}: {issue.message}")

    # Verify nested schemas
    if config['nested_schemas']:
        print()
        print("Checking nested schemas...")
        for nested in config['nested_schemas']:
            # Validate required config keys
            if 'name' not in nested:
                print("  [!] <unknown>: Nested schema config missing required 'name' key")
                all_issues.append(Issue(
                    level='error',
                    schema='<unknown>',
                    message="Nested schema config missing required 'name' key"
                ))
                continue
            if 'file' not in nested:
                print(f"  [!] {nested['name']}: Nested schema config missing required 'file' key")
                all_issues.append(Issue(
                    level='error',
                    schema=nested['name'],
                    message="Nested schema config missing required 'file' key"
                ))
                continue

            schema_name = nested['name']
            if args.schema and schema_name != args.schema:
                continue

            spec_schema = nested.get('spec_schema', schema_name)
            dart_file = Path(nested['file'])
            dart_class = nested.get('class_name')
            schema_excluded = global_excluded | set(excluded.get(spec_schema, []))

            issues = verify_schema(
                spec=spec,
                schema_name=spec_schema,
                dart_file=dart_file,
                dart_class_name=dart_class,
                type_mappings=type_mappings,
                excluded_props=schema_excluded,
                verbose=args.verbose
            )

            if not issues:
                print(f"  [PASS] {schema_name}")
            else:
                for issue in issues:
                    all_issues.append(issue)
                    level_marker = get_level_marker(issue.level)
                    print(f"  [{level_marker}] {schema_name}: {issue.message}")

    # Verify sealed classes
    if config['sealed_classes']:
        print()
        print("Checking sealed class variants...")
        for sealed_config in config['sealed_classes']:
            # Validate 'name' key exists before accessing
            sealed_name = sealed_config.get('name')
            if not sealed_name:
                print("  [!] <unknown>: Sealed class config missing required 'name' key")
                all_issues.append(Issue(
                    level='error',
                    schema='<unknown>',
                    message="Sealed class config missing required 'name' key"
                ))
                continue

            if args.schema and sealed_name != args.schema:
                continue

            print(f"  {sealed_name}:")
            issues = verify_sealed_class(
                spec=spec,
                sealed_config=sealed_config,
                type_mappings=type_mappings,
                excluded_props=global_excluded,
                verbose=args.verbose
            )

            if not issues:
                variant_count = len(sealed_config.get('variants', []))
                print(f"    [PASS] All {variant_count} variants verified")
            else:
                for issue in issues:
                    all_issues.append(issue)
                    level_marker = get_level_marker(issue.level)
                    print(f"    [{level_marker}] {issue.schema}: {issue.message}")

    # Summary
    print()
    print("=" * 60)
    error_count = sum(1 for i in all_issues if i.level == 'error')
    warning_count = sum(1 for i in all_issues if i.level == 'warning')

    if error_count == 0 and warning_count == 0:
        print("All verifications passed.")
        sys.exit(0)
    else:
        print(f"Found {error_count} error(s) and {warning_count} warning(s).")
        if error_count > 0:
            print()
            print("ACTION REQUIRED: Fix missing or mismatched properties.")
            sys.exit(1)
        sys.exit(0)


if __name__ == '__main__':
    main()
