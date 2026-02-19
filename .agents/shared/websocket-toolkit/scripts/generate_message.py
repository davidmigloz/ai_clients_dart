#!/usr/bin/env python3
"""
Generate Dart WebSocket message class from schema config.

Usage:
    python3 generate_message.py --config-dir CONFIG_DIR --message MESSAGE_NAME --direction [client|server]
    python3 generate_message.py --config-dir CONFIG_DIR --message MESSAGE_NAME --dry-run

Examples:
    python3 generate_message.py --config-dir config/ --message BidiGenerateContentSetup --direction client --dry-run
    python3 generate_message.py --config-dir config/ --list-messages

Exit codes:
    0 - Success
    1 - Message not found
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
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()


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


def generate_message_class(
    message_name: str,
    message_def: dict,
    direction: str,
    config: dict,
) -> str:
    """Generate Dart message class code."""
    description = message_def.get('description', f'{message_name} message.')
    fields = message_def.get('fields', {})

    # Generate wrapper key from message name
    # e.g., BidiGenerateContentSetup -> setup
    if message_name.startswith('BidiGenerateContent'):
        wrapper_key = message_name[len('BidiGenerateContent'):]
        wrapper_key = wrapper_key[0].lower() + wrapper_key[1:]
    else:
        wrapper_key = to_snake_case(message_name)

    # Determine base class
    base_class = f'BidiGenerateContent{"Client" if direction == "client" else "Server"}Message'

    # Generate field declarations
    field_lines = []
    ctor_params = []
    from_json_lines = []
    to_json_lines = []

    for field_name, field_def in fields.items():
        field_type = field_def.get('type', 'dynamic')
        required = field_def.get('required', False)
        field_desc = field_def.get('description', f'The {field_name}.')
        dart_type = get_dart_type(field_type, required)

        field_lines.append(f"  /// {field_desc}")
        field_lines.append(f"  final {dart_type} {field_name};")
        field_lines.append('')

        prefix = 'required ' if required else ''
        ctor_params.append(f"    {prefix}this.{field_name},")

        # fromJson
        if required:
            from_json_lines.append(f"      {field_name}: json['{field_name}'] as {dart_type.rstrip('?')},")
        else:
            from_json_lines.append(f"      {field_name}: json['{field_name}'] as {dart_type},")

        # toJson
        if required:
            to_json_lines.append(f"        '{field_name}': {field_name},")
        else:
            to_json_lines.append(f"        if ({field_name} != null) '{field_name}': {field_name},")

    code = f'''import '../../copy_with_sentinel.dart';

/// {description}
class {message_name} extends {base_class} {{
{chr(10).join(field_lines) if field_lines else ''}
  /// Creates a [{message_name}].
  const {message_name}({{
{chr(10).join(ctor_params) if ctor_params else ''}
  }});

  /// Creates from JSON (inner object, not wrapped).
  factory {message_name}.fromJson(Map<String, dynamic> json) {{
    return {message_name}(
{chr(10).join(from_json_lines) if from_json_lines else ''}
    );
  }}

  @override
  Map<String, dynamic> toJson() => {{
    '{wrapper_key}': {{
{chr(10).join(to_json_lines) if to_json_lines else ''}
    }},
  }};

  @override
  String toString() => '{message_name}({", ".join(f"{name}: ${name}" for name in fields.keys())})';
}}
'''
    return code


def list_messages(config: dict) -> None:
    """List all available messages from schema config."""
    schema = config.get('schema', {})
    message_types = schema.get('message_types', {})

    print("Available Messages:")
    print()

    for direction in ['client', 'server']:
        messages = message_types.get(direction, {})
        if messages:
            print(f"{direction.upper()} MESSAGES:")
            for name, msg_def in messages.items():
                desc = msg_def.get('description', 'No description')[:50]
                print(f"  - {name}: {desc}")
            print()


def main():
    parser = argparse.ArgumentParser(description='Generate Dart WebSocket message class')
    parser.add_argument(
        '--config-dir', type=Path, required=True,
        help='Directory containing config files'
    )
    parser.add_argument(
        '--message', '-m', type=str,
        help='Message name to generate'
    )
    parser.add_argument(
        '--direction', '-d', choices=['client', 'server'],
        help='Message direction (client or server)'
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
        '--list-messages', action='store_true',
        help='List available messages from schema'
    )
    args = parser.parse_args()

    if not args.config_dir.exists():
        print(f"Error: Config directory not found: {args.config_dir}", file=sys.stderr)
        sys.exit(2)

    config = load_config(args.config_dir)

    if args.list_messages:
        list_messages(config)
        sys.exit(0)

    if not args.message:
        print("Error: --message is required (or use --list-messages)", file=sys.stderr)
        sys.exit(2)

    # Find message in schema
    schema = config.get('schema', {})
    message_types = schema.get('message_types', {})

    message_def = None
    direction = args.direction

    # Search in specified direction or both
    for d in ([direction] if direction else ['client', 'server']):
        messages = message_types.get(d, {})
        if args.message in messages:
            message_def = messages[args.message]
            direction = d
            break

    if not message_def:
        print(f"Error: Message '{args.message}' not found in schema", file=sys.stderr)
        print("\nUse --list-messages to see available messages", file=sys.stderr)
        sys.exit(1)

    try:
        code = generate_message_class(args.message, message_def, direction, config)
    except Exception as e:
        print(f"Error generating message: {e}", file=sys.stderr)
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
