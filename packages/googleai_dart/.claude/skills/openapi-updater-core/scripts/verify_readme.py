#!/usr/bin/env python3
"""
Verify README.md completeness and accuracy against actual API implementation.

This is a config-driven script that loads verification rules from config files.

Usage:
    python3 verify_readme.py --config-dir CONFIG_DIR

Exit codes:
    0 - All checks passed
    1 - Validation issues found
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
        'removed_apis': [],
        'tool_properties': {},
        'excluded_resources': [],
        'resources_dir': 'lib/src/resources',
        'tool_file': 'lib/src/models/tools/tool.dart',
    }

    # Load documentation.json
    doc_file = config_dir / 'documentation.json'
    if doc_file.exists():
        with open(doc_file) as f:
            doc = json.load(f)
            config['removed_apis'] = doc.get('removed_apis', [])
            config['tool_properties'] = doc.get('tool_properties', {})
            config['excluded_resources'] = doc.get('excluded_resources', [])

    # Load package.json for paths
    pkg_file = config_dir / 'package.json'
    if pkg_file.exists():
        with open(pkg_file) as f:
            pkg = json.load(f)
            config['resources_dir'] = pkg.get('resources_dir', config['resources_dir'])
            # Tool file is typically in models/tools/
            models_dir = pkg.get('models_dir', 'lib/src/models')
            config['tool_file'] = f"{models_dir}/tools/tool.dart"

    return config


def snake_to_camel(name: str) -> str:
    """Convert snake_case to camelCase."""
    components = name.split('_')
    return components[0] + ''.join(x.title() for x in components[1:])


def find_implemented_resources(config: dict) -> set[str]:
    """Find all resource files and return expected client names."""
    resources_dir = Path(config['resources_dir'])
    excluded = set(config['excluded_resources'])
    resources = set()

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

        if name.endswith('.bak'):
            continue
        if not name.endswith('_resource'):
            continue
        if name in excluded:
            continue

        base_name = name.replace('_resource', '')
        client_name = snake_to_camel(base_name)
        resources.add(client_name)

    return resources


def extract_documented_resources(readme: str) -> set[str]:
    """Extract resource names from README API Coverage section."""
    pattern = r"### \w+(?:\s+\w+)* Resource \(`client\.(\w+)`\)"
    return set(re.findall(pattern, readme))


def find_tool_properties(config: dict) -> dict[str, int]:
    """Extract tool properties from Tool class with line numbers."""
    tool_file = Path(config['tool_file'])
    if not tool_file.exists():
        return {}

    content = tool_file.read_text()
    properties = {}

    for i, line in enumerate(content.split('\n'), 1):
        match = re.search(r'final\s+[\w<>?]+\s+(\w+);', line)
        if match:
            properties[match.group(1)] = i

    return properties


def check_tool_documentation(readme: str, config: dict) -> list[tuple[str, str]]:
    """Check if all tool properties are documented in README."""
    missing = []
    readme_lower = readme.lower()
    tool_properties = config['tool_properties']

    for prop, prop_config in tool_properties.items():
        description = prop_config.get('description', '')
        search_terms = prop_config.get('search_terms', [prop.lower()])

        found = any(term in readme_lower for term in search_terms)
        if not found:
            missing.append((prop, description))

    return missing


def check_stale_references(readme: str, config: dict) -> list[tuple[int, str, str]]:
    """Find references to removed APIs with line numbers."""
    issues = []
    lines = readme.split('\n')
    removed_apis = config['removed_apis']

    for i, line in enumerate(lines, 1):
        for api_info in removed_apis:
            api = api_info.get('api', '')
            reason = api_info.get('reason', 'API removed')
            if api in line:
                issues.append((i, api, reason))

    return issues


def check_example_files(readme: str) -> list[str]:
    """Check that referenced example files exist."""
    example_dir = Path('example')

    pattern = r'[`/]?(\w+(?:_\w+)*\.dart)[`]?'
    referenced = set(re.findall(pattern, readme))

    example_patterns = ['_example.dart', 'example.dart']

    missing = []
    for filename in referenced:
        is_example = any(p in filename for p in example_patterns)
        if is_example and not (example_dir / filename).exists():
            missing.append(filename)

    return missing


def main():
    parser = argparse.ArgumentParser(
        description='Verify README accuracy against implementation'
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

    # Validate directory
    readme_path = Path('README.md')
    if not readme_path.exists():
        print("Error: README.md not found. Run from package root directory.")
        sys.exit(2)

    resources_dir = Path(config['resources_dir'])
    if not resources_dir.exists():
        print(f"Error: {config['resources_dir']}/ not found. Run from package root directory.")
        sys.exit(2)

    print("Checking README completeness and accuracy...")
    print()

    readme = readme_path.read_text()
    total_issues = 0

    # Check 1: Resource validation
    impl_resources = find_implemented_resources(config)
    doc_resources = extract_documented_resources(readme)

    stale_resources = doc_resources - impl_resources
    missing_resources = impl_resources - doc_resources

    if args.verbose:
        print(f"Implemented resources: {sorted(impl_resources)}")
        print(f"Documented resources: {sorted(doc_resources)}")
        print()

    # Check 2: Tool properties
    missing_tools = check_tool_documentation(readme, config)

    # Check 3: Stale references
    stale_refs = check_stale_references(readme, config)

    # Check 4: Example files
    missing_examples = check_example_files(readme)

    # Report stale references
    if stale_refs:
        print("STALE REFERENCES (removed from API):")
        for line_num, api, reason in stale_refs:
            print(f"  - README.md:{line_num} - '{api}'")
            print(f"      → {reason}")
        print()
        total_issues += len(stale_refs)

    # Report stale resources
    if stale_resources:
        print("STALE RESOURCES (documented but not implemented):")
        for res in sorted(stale_resources):
            print(f"  - client.{res}")
        print()
        total_issues += len(stale_resources)

    # Report missing resources
    if missing_resources:
        print("MISSING RESOURCES (implemented but not documented):")
        for res in sorted(missing_resources):
            print(f"  - client.{res} ({config['resources_dir']}/)")
        print()
        total_issues += len(missing_resources)

    # Report missing tool documentation
    if missing_tools:
        print("MISSING TOOL DOCUMENTATION:")
        tool_props = find_tool_properties(config)
        for prop, description in missing_tools:
            line = tool_props.get(prop, '?')
            print(f"  - Tool.{prop} ({config['tool_file']}:{line})")
            print(f"      → {description}")
        print()
        total_issues += len(missing_tools)

    # Report missing examples
    if missing_examples:
        print("MISSING EXAMPLE FILES:")
        for example in sorted(missing_examples):
            print(f"  - {example}")
        print()
        total_issues += len(missing_examples)

    # Summary
    if total_issues == 0:
        print("✓ README is accurate and complete.")
        sys.exit(0)
    else:
        print(f"Found {total_issues} issue(s).")
        print()

        if stale_refs or stale_resources:
            print("SUGGESTED REMOVALS:")
            if stale_resources:
                for res in sorted(stale_resources):
                    print(f"  - Remove '{res} Resource' section from API Coverage")
            chunk_refs = [r for r in stale_refs if 'chunk' in r[1].lower()]
            rag_refs = [r for r in stale_refs if 'rag' in r[1].lower()]
            if chunk_refs:
                lines = sorted(set(r[0] for r in chunk_refs))
                print(f"  - Remove Chunk Management references (lines: {lines})")
            if rag_refs:
                lines = sorted(set(r[0] for r in rag_refs))
                print(f"  - Remove RAG Stores references (lines: {lines})")
            print()

        if missing_resources or missing_tools:
            print("SUGGESTED ADDITIONS:")
            if missing_resources:
                for res in sorted(missing_resources):
                    print(f"  - Add '{res}' Resource section to API Coverage")
            if missing_tools:
                for prop, desc in missing_tools:
                    print(f"  - Document Tool.{prop} in Function Calling section")
            print()

        sys.exit(1)


if __name__ == '__main__':
    main()
