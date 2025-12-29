#!/usr/bin/env python3
"""
Fetch the latest OpenAPI specifications.

This is a config-driven script that loads spec URLs from config files.

Usage:
    python3 fetch_spec.py --config-dir CONFIG_DIR [--spec NAME] [--no-discover]

Examples:
    python3 fetch_spec.py --config-dir config/      # Fetch all specs + discover new
    python3 fetch_spec.py --config-dir config/ --spec main   # Fetch only main spec
    python3 fetch_spec.py --config-dir config/ --no-discover # Skip discovery probing

Exit codes:
    0 - Success
    1 - Partial failure (some specs failed)
    2 - Error (config not found, etc.)
"""

import argparse
import json
import os
import sys
from datetime import datetime
from pathlib import Path
from urllib.request import urlopen, Request
from urllib.error import URLError, HTTPError


def load_config(config_dir: Path) -> dict:
    """Load configuration from config directory."""
    config = {
        'specs': {},
        'output_dir': '/tmp/openapi-toolkit',
        'discovery_patterns': [],
        'discovery_names': [],
        'auth_env_vars': ['GEMINI_API_KEY', 'GOOGLE_AI_API_KEY'],
    }

    # Load specs.json
    specs_file = config_dir / 'specs.json'
    if specs_file.exists():
        with open(specs_file) as f:
            specs = json.load(f)
            config['specs'] = specs.get('specs', {})
            config['output_dir'] = specs.get('output_dir', config['output_dir'])
            config['discovery_patterns'] = specs.get('discovery_patterns', [])
            config['discovery_names'] = specs.get('discovery_names', [])

    return config


def get_api_key(config: dict) -> str | None:
    """Get API key from environment (optional for some specs)."""
    # Check all possible auth env vars
    for env_var in config.get('auth_env_vars', []):
        key = os.environ.get(env_var)
        if key:
            return key

    # Also check spec-specific auth_env_vars
    for spec_config in config.get('specs', {}).values():
        for env_var in spec_config.get('auth_env_vars', []):
            key = os.environ.get(env_var)
            if key:
                return key

    return None


def fetch_url(url: str, api_key: str | None = None, requires_auth: bool = False) -> dict | None:
    """Fetch JSON from URL with optional auth."""
    if requires_auth:
        if not api_key:
            print(f"  ERROR: API key required but not set", file=sys.stderr)
            return None
        url = f"{url}&key={api_key}" if '?' in url else f"{url}?key={api_key}"

    try:
        req = Request(url, headers={'User-Agent': 'OpenAPI-Updater/1.0'})
        with urlopen(req, timeout=30) as response:
            data = response.read().decode('utf-8')
            return json.loads(data)
    except HTTPError as e:
        if e.code == 404:
            return None
        print(f"  ERROR: HTTP {e.code}: {e.reason}", file=sys.stderr)
        return None
    except URLError as e:
        print(f"  ERROR: Network error: {e.reason}", file=sys.stderr)
        return None
    except json.JSONDecodeError as e:
        print(f"  ERROR: Invalid JSON: {e}", file=sys.stderr)
        return None


def count_endpoints(spec: dict) -> int:
    """Count total endpoints in spec."""
    count = 0
    for path_data in spec.get('paths', {}).values():
        for method in ['get', 'post', 'put', 'patch', 'delete']:
            if method in path_data:
                count += 1
    return count


def count_schemas(spec: dict) -> int:
    """Count schemas in spec."""
    return len(spec.get('components', {}).get('schemas', {}))


def save_spec(spec: dict, output_dir: Path, spec_name: str) -> Path:
    """Save spec to output directory."""
    output_dir.mkdir(parents=True, exist_ok=True)
    filepath = output_dir / f"latest-{spec_name}.json"
    with open(filepath, 'w') as f:
        json.dump(spec, f, indent=2)
    return filepath


def print_spec_info(spec: dict, filepath: Path):
    """Print spec metadata."""
    info = spec.get('info', {})
    print(f"  Saved to: {filepath}")
    print(f"  OpenAPI: {spec.get('openapi', 'unknown')}")
    print(f"  Version: {info.get('version', 'unknown')}")
    print(f"  Title: {info.get('title', 'unknown')}")
    print(f"  Endpoints: {count_endpoints(spec)}")
    print(f"  Schemas: {count_schemas(spec)}")


def fetch_registered_specs(config: dict, spec_filter: str | None, output_dir: Path, api_key: str | None) -> int:
    """Fetch all registered specs (or a specific one)."""
    specs = config.get('specs', {})
    fetched = 0

    for name, spec_config in specs.items():
        if spec_filter and name != spec_filter:
            continue

        print(f"\n[{name}] {spec_config.get('name', 'Unknown')}")
        url = spec_config['url']
        requires_auth = spec_config.get('requires_auth', False)
        experimental = spec_config.get('experimental', False)

        if experimental:
            print(f"  (experimental)")

        print(f"  Fetching from {url.split('?')[0]}...")

        spec = fetch_url(url, api_key, requires_auth)
        if spec is None:
            print(f"  FAILED to fetch spec")
            continue

        if 'openapi' not in spec:
            print(f"  ERROR: Not a valid OpenAPI spec")
            continue

        filepath = save_spec(spec, output_dir, name)
        print_spec_info(spec, filepath)
        fetched += 1

    return fetched


def discover_new_specs(config: dict) -> list[tuple[str, str]]:
    """Probe for new specs at discovery patterns."""
    patterns = config.get('discovery_patterns', [])
    names = config.get('discovery_names', [])
    registered = set(config.get('specs', {}).keys())

    discovered = []

    for pattern in patterns:
        for name in names:
            if name in registered:
                continue

            url = pattern.replace('{name}', name)
            try:
                req = Request(url, headers={'User-Agent': 'OpenAPI-Updater/1.0'})
                with urlopen(req, timeout=5) as response:
                    if response.status == 200:
                        discovered.append((name, url))
            except:
                pass

    return discovered


def main():
    parser = argparse.ArgumentParser(description="Fetch OpenAPI specs")
    parser.add_argument(
        '--config-dir', type=Path, required=True,
        help='Directory containing config files'
    )
    parser.add_argument(
        '--spec', '-s', type=str, default=None,
        help="Fetch only this spec (default: all)"
    )
    parser.add_argument(
        '--no-discover', action='store_true',
        help="Skip discovery probing for new specs"
    )
    parser.add_argument(
        '--output', '-o', type=Path, default=None,
        help="Output directory (overrides config)"
    )
    args = parser.parse_args()

    # Validate config directory
    if not args.config_dir.exists():
        print(f"Error: Config directory not found: {args.config_dir}")
        sys.exit(2)

    # Load configuration
    config = load_config(args.config_dir)

    if not config['specs']:
        print(f"Error: No specs defined in {args.config_dir / 'specs.json'}")
        sys.exit(2)

    # Determine output directory
    output_dir = args.output or Path(config['output_dir'])

    api_key = get_api_key(config)

    print(f"OpenAPI Spec Fetcher")
    print(f"Config: {args.config_dir}")
    print(f"Output: {output_dir}")

    # Check for API key if needed
    if args.spec:
        spec_config = config.get('specs', {}).get(args.spec)
        if not spec_config:
            print(f"\nERROR: Unknown spec '{args.spec}'", file=sys.stderr)
            print(f"Available specs: {', '.join(config.get('specs', {}).keys())}")
            sys.exit(2)
        if spec_config.get('requires_auth') and not api_key:
            auth_vars = spec_config.get('auth_env_vars', config.get('auth_env_vars', []))
            print(f"\nERROR: {' or '.join(auth_vars)} required for '{args.spec}'",
                  file=sys.stderr)
            sys.exit(2)
    else:
        for name, spec_config in config.get('specs', {}).items():
            if spec_config.get('requires_auth') and not api_key:
                print(f"\nWARNING: API key not set - will skip '{name}' spec")

    # Fetch specs
    fetched = fetch_registered_specs(config, args.spec, output_dir, api_key)

    # Auto-discover new specs
    if not args.no_discover and not args.spec:
        print(f"\n--- Discovery ---")
        print(f"Probing for new specs...")
        discovered = discover_new_specs(config)

        if discovered:
            print(f"\n⚠️  NEW SPECS DISCOVERED:")
            for name, url in discovered:
                print(f"  - {name}: {url}")
            print(f"\nTo add to registry, update: {args.config_dir / 'specs.json'}")
        else:
            print(f"No new specs found.")

    print(f"\n--- Summary ---")
    print(f"Fetched: {fetched} spec(s)")
    print(f"Time: {datetime.now().isoformat()}")

    sys.exit(0 if fetched > 0 else 1)


if __name__ == '__main__':
    main()
