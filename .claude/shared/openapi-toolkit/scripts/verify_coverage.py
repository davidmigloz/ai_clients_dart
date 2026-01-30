#!/usr/bin/env python3
"""
Verify API coverage: compare OpenAPI spec endpoints against implemented resources.

This script identifies:
- Unimplemented endpoints (in spec but not in code)
- Implemented endpoints (coverage report)
- Unknown implementations (in code but not in spec - may be custom)

Usage:
    python3 verify_coverage.py --config-dir CONFIG_DIR --spec SPEC_FILE

Exit codes:
    0 - Full coverage (or only warnings)
    1 - Unimplemented endpoints found
    2 - Error (missing files, invalid config, etc.)
"""

import argparse
import json
import re
import sys
from pathlib import Path
from dataclasses import dataclass, field
@dataclass
class EndpointInfo:
    """Information about an API endpoint."""
    path: str
    method: str
    operation_id: str
    description: str = ""
    tags: list = field(default_factory=list)

    @property
    def resource_name(self) -> str:
        """Extract resource name from path (e.g., /v1/responses -> responses, /api/v2/chat -> chat)."""
        parts = self.path.strip('/').split('/')
        idx = 0
        # Skip leading "api" prefix if present (e.g., /api/..., /api/v2/...)
        if idx < len(parts) and parts[idx] == 'api':
            idx += 1
        # Skip version prefix (v1, v2, etc.) whether or not it follows "api"
        if idx < len(parts) and re.match(r'^v\d+$', parts[idx]):
            idx += 1
        normalized_parts = parts[idx:]
        return normalized_parts[0] if normalized_parts else 'root'


def load_config(config_dir: Path) -> dict:
    """Load configuration from config directory."""
    config = {
        'package_name': 'dart_api_client',
        'resources_dir': 'lib/src/resources',
        'excluded_paths': [],  # Paths to exclude from coverage check
        'excluded_tags': [],   # Tags to exclude (e.g., 'admin', 'internal')
    }

    # Load package.json
    pkg_file = config_dir / 'package.json'
    if pkg_file.exists():
        with open(pkg_file) as f:
            pkg = json.load(f)
            config['package_name'] = pkg.get('name', config['package_name'])
            config['resources_dir'] = pkg.get('resources_dir', config['resources_dir'])
            config['excluded_paths'] = pkg.get('excluded_paths', [])
            config['excluded_tags'] = pkg.get('excluded_tags', [])

    # Load coverage.json for additional exclusions
    coverage_file = config_dir / 'coverage.json'
    if coverage_file.exists():
        with open(coverage_file) as f:
            cov = json.load(f)
            config['excluded_paths'].extend(cov.get('excluded_paths', []))
            config['excluded_tags'].extend(cov.get('excluded_tags', []))
            config['priority_resources'] = cov.get('priority_resources', [])

    return config


def load_spec(path: Path) -> dict:
    """Load OpenAPI spec (JSON or YAML)."""
    content = path.read_text()

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
        print(f"       Python executable: {sys.executable}", file=sys.stderr)
        print(f"       Python version: {sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}", file=sys.stderr)
        print("", file=sys.stderr)
        print("       Install for this Python version:", file=sys.stderr)
        print(f"         {sys.executable} -m pip install pyyaml --user", file=sys.stderr)
        print("", file=sys.stderr)
        print("       Verify installation:", file=sys.stderr)
        print(f"         {sys.executable} -c \"import yaml; print(yaml.__version__)\"", file=sys.stderr)
        raise
    except Exception as e:
        print(f"ERROR: Failed to parse spec: {e}", file=sys.stderr)
        sys.exit(2)


def auto_locate_spec(config_dir: Path) -> Path | None:
    """
    Auto-locate the fetched spec file from specs.json config.

    Returns the path to the latest fetched spec, or None if not found.
    """
    specs_config = config_dir / 'specs.json'
    if not specs_config.exists():
        return None

    try:
        with open(specs_config) as f:
            cfg = json.load(f)
    except (json.JSONDecodeError, IOError):
        return None

    output_dir = Path(cfg.get('output_dir', '/tmp'))

    for spec_name in cfg.get('specs', {}).keys():
        candidate = output_dir / f"latest-{spec_name}.json"
        if candidate.exists():
            return candidate
        break  # Use first spec

    return None


def extract_endpoints(spec: dict, config: dict) -> list[EndpointInfo]:
    """Extract all endpoints from OpenAPI spec."""
    endpoints = []
    excluded_paths = config.get('excluded_paths', [])
    excluded_tags = set(config.get('excluded_tags', []))

    for path, path_data in spec.get('paths', {}).items():
        # Check path exclusions
        if any(re.match(pattern, path) for pattern in excluded_paths):
            continue

        for method in ['get', 'post', 'put', 'patch', 'delete']:
            if method not in path_data:
                continue

            op = path_data[method]
            tags = op.get('tags', [])

            # Check tag exclusions
            if excluded_tags and any(tag in excluded_tags for tag in tags):
                continue

            endpoints.append(EndpointInfo(
                path=path,
                method=method.upper(),
                operation_id=op.get('operationId', ''),
                description=op.get('summary', op.get('description', ''))[:100],
                tags=tags,
            ))

    return endpoints


def find_resource_files(resources_dir: Path) -> list[Path]:
    """Find all resource files in the resources directory (including subdirectories)."""
    if not resources_dir.exists():
        return []
    # Use recursive glob to find resources in subdirectories
    return sorted(resources_dir.glob('**/*_resource.dart'))


def extract_implemented_methods(resource_file: Path) -> set[str]:
    """Extract HTTP method calls from a resource file."""
    content = resource_file.read_text()

    # Look for patterns like:
    # - makeRequest('GET', ...)
    # - _client.get(...)
    # - HttpMethod.get
    # - method: 'POST'
    methods = set()

    # Pattern: makeRequest('METHOD', '/path')
    for match in re.finditer(r"makeRequest\s*\(\s*['\"](\w+)['\"]", content):
        methods.add(match.group(1).upper())

    # Pattern: _client.get/post/put/delete/patch
    for match in re.finditer(r"_client\.(get|post|put|delete|patch)\s*\(", content, re.IGNORECASE):
        methods.add(match.group(1).upper())

    # Pattern: method: 'GET'
    for match in re.finditer(r"method:\s*['\"](\w+)['\"]", content):
        methods.add(match.group(1).upper())

    return methods


def extract_implemented_paths(resource_file: Path) -> set[str]:
    """Extract API paths from a resource file."""
    content = resource_file.read_text()
    paths = set()

    # Look for path patterns in strings
    # Pattern: '/v1/something' or 'something/$id'
    for match in re.finditer(r"['\"](/[\w\-/${}]+)['\"]", content):
        path = match.group(1)
        # Normalize path parameters
        path = re.sub(r'\$\{?\w+\}?', '{param}', path)
        path = re.sub(r'\$\w+', '{param}', path)
        paths.add(path)

    return paths


def analyze_coverage(
    spec_endpoints: list[EndpointInfo],
    resource_files: list[Path],
    config: dict,
) -> dict:
    """Analyze coverage between spec and implementation."""

    # Group spec endpoints by resource
    spec_by_resource: dict[str, list[EndpointInfo]] = {}
    for ep in spec_endpoints:
        resource = ep.resource_name
        if resource not in spec_by_resource:
            spec_by_resource[resource] = []
        spec_by_resource[resource].append(ep)

    # Map resource files to resource names
    implemented_resources = set()
    for rf in resource_files:
        # Extract resource name from file (e.g., chat_resource.dart -> chat)
        name = rf.stem.replace('_resource', '')
        implemented_resources.add(name)

    # Analyze coverage
    results = {
        'total_spec_endpoints': len(spec_endpoints),
        'total_spec_resources': len(spec_by_resource),
        'implemented_resources': len(implemented_resources),
        'unimplemented_resources': [],
        'unimplemented_endpoints': [],
        'implemented_endpoints': [],
        'coverage_by_resource': {},
    }

    for resource, endpoints in sorted(spec_by_resource.items()):
        # Handle special cases (pluralization, naming differences)
        alt_names = [
            resource,
            resource + 's',
            resource.rstrip('s'),
            resource.replace('-', '_'),
            resource.replace('_', '-'),
        ]
        is_implemented = any(name in implemented_resources for name in alt_names)

        if is_implemented:
            results['implemented_endpoints'].extend(endpoints)
            results['coverage_by_resource'][resource] = {
                'status': 'implemented',
                'endpoint_count': len(endpoints),
            }
        else:
            results['unimplemented_resources'].append(resource)
            results['unimplemented_endpoints'].extend(endpoints)
            results['coverage_by_resource'][resource] = {
                'status': 'missing',
                'endpoint_count': len(endpoints),
                'endpoints': [{'method': ep.method, 'path': ep.path, 'operation_id': ep.operation_id}
                             for ep in endpoints],
            }

    # Calculate coverage percentage
    if results['total_spec_endpoints'] > 0:
        results['coverage_percent'] = round(
            len(results['implemented_endpoints']) / results['total_spec_endpoints'] * 100, 1
        )
    else:
        results['coverage_percent'] = 100.0

    return results


def format_report(results: dict, config: dict, verbose: bool = False) -> str:
    """Format the coverage report."""
    lines = [
        "=" * 60,
        f"API Coverage Report: {config.get('package_name', 'unknown')}",
        "=" * 60,
        "",
        "## Summary",
        "",
        f"Coverage: {results['coverage_percent']}%",
        f"Spec Endpoints: {results['total_spec_endpoints']}",
        f"Spec Resources: {results['total_spec_resources']}",
        f"Implemented Resources: {results['implemented_resources']}",
        f"Missing Resources: {len(results['unimplemented_resources'])}",
        "",
    ]

    # Missing resources (critical)
    if results['unimplemented_resources']:
        lines.extend([
            "-" * 60,
            "## MISSING RESOURCES (Not Implemented)",
            "",
        ])
        for resource in sorted(results['unimplemented_resources']):
            info = results['coverage_by_resource'].get(resource, {})
            lines.append(f"### {resource} ({info.get('endpoint_count', 0)} endpoints)")
            lines.append("")
            if 'endpoints' in info:
                for ep in info['endpoints']:
                    lines.append(f"  - {ep['method']} {ep['path']}")
                    if ep.get('operation_id'):
                        lines.append(f"    Operation: {ep['operation_id']}")
            lines.append("")

    # Coverage by resource (verbose)
    if verbose:
        lines.extend([
            "-" * 60,
            "## Coverage by Resource",
            "",
        ])
        for resource, info in sorted(results['coverage_by_resource'].items()):
            status_icon = "✓" if info['status'] == 'implemented' else "✗"
            lines.append(f"{status_icon} {resource}: {info['endpoint_count']} endpoints")
        lines.append("")

    # Recommendations
    if results['unimplemented_resources']:
        lines.extend([
            "-" * 60,
            "## Recommendations",
            "",
            "Create the following resource files:",
            "",
        ])
        resources_dir = config.get('resources_dir', 'lib/src/resources')
        for resource in sorted(results['unimplemented_resources']):
            lines.append(f"  - {resources_dir}/{resource}_resource.dart")
        lines.append("")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description='Verify API coverage between OpenAPI spec and implementation.'
    )
    parser.add_argument(
        '--config-dir', type=Path, required=True,
        help='Directory containing config files'
    )
    parser.add_argument(
        '--spec', type=Path, default=None,
        help='Path to OpenAPI spec file (JSON or YAML). Auto-located if not provided.'
    )
    parser.add_argument(
        '--format', '-f', choices=['text', 'json'], default='text',
        help='Output format (default: text)'
    )
    parser.add_argument(
        '--verbose', '-v', action='store_true',
        help='Show detailed coverage by resource'
    )
    parser.add_argument(
        '--fail-threshold', type=float, default=0,
        help='Fail if coverage is below this percentage (default: 0 = fail on any missing)'
    )
    args = parser.parse_args()

    # Validate inputs
    if not args.config_dir.exists():
        print(f"ERROR: Config directory not found: {args.config_dir}", file=sys.stderr)
        sys.exit(2)

    # Auto-locate spec if not provided
    spec_path = args.spec
    if not spec_path:
        spec_path = auto_locate_spec(args.config_dir)
        if spec_path:
            print(f"Auto-located spec: {spec_path}", file=sys.stderr)
        else:
            print("ERROR: Could not auto-locate spec file.", file=sys.stderr)
            print("       Run fetch_spec.py first, or provide --spec path.", file=sys.stderr)
            sys.exit(2)

    if not spec_path.exists():
        print(f"ERROR: Spec file not found: {spec_path}", file=sys.stderr)
        print("       Did you run fetch_spec.py first?", file=sys.stderr)
        sys.exit(2)

    # Load config and spec
    config = load_config(args.config_dir)
    spec = load_spec(spec_path)

    # Find implemented resources
    resources_dir = Path(config['resources_dir'])
    resource_files = find_resource_files(resources_dir)

    # Check for wrong working directory - provide helpful error
    if not resource_files and not resources_dir.exists():
        pkg_name = config.get('package_name', 'unknown')
        print(f"ERROR: Directory '{config['resources_dir']}' not found.", file=sys.stderr)
        print("", file=sys.stderr)
        print("This script must be run from the PACKAGE ROOT directory,", file=sys.stderr)
        print("not from the repository root.", file=sys.stderr)
        print("", file=sys.stderr)
        print("Example:", file=sys.stderr)
        print(f"  cd packages/{pkg_name}", file=sys.stderr)
        print(f"  python3 ../../.claude/shared/openapi-toolkit/scripts/verify_coverage.py \\", file=sys.stderr)
        print(f"    --config-dir {args.config_dir}", file=sys.stderr)
        print("", file=sys.stderr)
        print(f"Current working directory: {Path.cwd()}", file=sys.stderr)
        sys.exit(2)

    if not resource_files:
        print(f"WARNING: No resource files found in {resources_dir}", file=sys.stderr)

    # Extract spec endpoints
    spec_endpoints = extract_endpoints(spec, config)

    if not spec_endpoints:
        print("WARNING: No endpoints found in spec", file=sys.stderr)
        sys.exit(0)

    # Analyze coverage
    results = analyze_coverage(spec_endpoints, resource_files, config)

    # Output results
    if args.format == 'json':
        # Remove non-serializable data for JSON output
        output = {k: v for k, v in results.items()
                  if k not in ['implemented_endpoints', 'unimplemented_endpoints']}
        print(json.dumps(output, indent=2))
    else:
        print(format_report(results, config, args.verbose))

    # Exit code based on coverage
    if results['unimplemented_resources']:
        if args.fail_threshold > 0:
            if results['coverage_percent'] < args.fail_threshold:
                print(f"\nFAILED: Coverage {results['coverage_percent']}% < threshold {args.fail_threshold}%")
                sys.exit(1)
        else:
            # Default: fail if any missing
            sys.exit(1)

    print("\n✓ Full API coverage achieved!")
    sys.exit(0)


if __name__ == '__main__':
    main()
