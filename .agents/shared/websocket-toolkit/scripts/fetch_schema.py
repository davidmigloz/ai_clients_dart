#!/usr/bin/env python3
"""
Fetch the latest WebSocket API schema.

This is a config-driven script that loads schema definition from config files.

Usage:
    python3 fetch_schema.py --config-dir CONFIG_DIR [--spec NAME]

Exit codes:
    0 - Success
    1 - Fetch error
    2 - Config error
"""

import argparse
import json
import sys
from pathlib import Path


def load_config(config_dir: Path) -> dict:
    """Load configuration from config directory."""
    config = {
        'specs': {},
        'output_dir': '/tmp/websocket-toolkit',
        'schema': {},
    }

    # Load specs.json
    specs_file = config_dir / 'specs.json'
    if specs_file.exists():
        with open(specs_file) as f:
            specs = json.load(f)
            config['specs'] = specs.get('specs', {})
            config['output_dir'] = specs.get('output_dir', config['output_dir'])

    # Load schema.json (the actual schema definition)
    schema_file = config_dir / 'schema.json'
    if schema_file.exists():
        with open(schema_file) as f:
            config['schema'] = json.load(f)

    return config


def main():
    parser = argparse.ArgumentParser(
        description='Fetch the latest WebSocket API schema.'
    )
    parser.add_argument(
        '--config-dir', type=Path, required=True,
        help='Directory containing config files'
    )
    parser.add_argument(
        '--spec', '-s',
        type=str,
        default='live',
        help='Spec to fetch (default: live)'
    )
    parser.add_argument(
        '--output', '-o',
        type=Path,
        help='Output file (overrides default)'
    )
    args = parser.parse_args()

    # Validate config directory
    if not args.config_dir.exists():
        print(f"Error: Config directory not found: {args.config_dir}")
        sys.exit(2)

    # Load configuration
    config = load_config(args.config_dir)

    if not config['schema']:
        print(f"Error: No schema defined in {args.config_dir / 'schema.json'}")
        sys.exit(2)

    if args.spec not in config['specs']:
        print(f"Error: Unknown spec '{args.spec}'")
        if config['specs']:
            print(f"Available: {', '.join(config['specs'].keys())}")
        sys.exit(2)

    # Create output directory
    output_dir = Path(config['output_dir'])
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Fetching {args.spec} API schema...")

    # Get the schema from config
    schema = config['schema']

    # Save to output
    output_file = args.output or (output_dir / f'latest-{args.spec}.json')
    output_file.write_text(json.dumps(schema, indent=2))

    print(f"✓ Schema saved to {output_file}")
    print()

    # Print summary
    msg_types = schema.get('message_types', {})
    client_msgs = msg_types.get('client', {})
    server_msgs = msg_types.get('server', {})

    print(f"Message types: {len(client_msgs)} client, {len(server_msgs)} server")
    print(f"Config types: {len(schema.get('config_types', {}))}")
    print(f"Enums: {len(schema.get('enums', {}))}")

    sys.exit(0)


if __name__ == '__main__':
    main()
