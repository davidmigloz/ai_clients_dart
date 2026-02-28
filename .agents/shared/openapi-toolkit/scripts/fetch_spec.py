#!/usr/bin/env python3
"""
Fetch the latest OpenAPI specifications.

This is a config-driven script that loads spec URLs from config files.

Usage:
    python3 fetch_spec.py --config-dir CONFIG_DIR [--spec NAME] [--no-discover]
    python3 fetch_spec.py --config-dir CONFIG_DIR --preflight [--preflight-only]

Examples:
    python3 fetch_spec.py --config-dir config/                     # Fetch all specs + discover new
    python3 fetch_spec.py --config-dir config/ --spec main        # Fetch only main spec
    python3 fetch_spec.py --config-dir config/ --preflight-only   # Drift check only

Exit codes:
    0 - Success
    1 - Partial failure (some specs failed / offline preflight-only)
    2 - Error (config not found, etc.)
"""

import argparse
import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import unquote
from urllib.request import Request, urlopen

# Optional YAML support for specs served in YAML format
try:
    import yaml

    HAS_YAML = True
except ImportError:
    HAS_YAML = False


DEFAULT_PREFLIGHT = {
    "stats_url": "https://raw.githubusercontent.com/openai/openai-python/refs/heads/main/.stats.yml",
    "stats_field": "openapi_spec_url",
}


def load_config(config_dir: Path) -> dict:
    """Load configuration from config directory."""
    config = {
        "specs": {},
        "output_dir": "/tmp/openapi-toolkit",
        "specs_dir": None,
        "discovery_patterns": [],
        "discovery_names": [],
        "auth_env_vars": ["GEMINI_API_KEY", "GOOGLE_AI_API_KEY"],
        "preflight": dict(DEFAULT_PREFLIGHT),
    }

    specs_file = config_dir / "specs.json"
    if specs_file.exists():
        with open(specs_file) as f:
            specs = json.load(f)
            config["specs"] = specs.get("specs", {})
            config["output_dir"] = specs.get("output_dir", config["output_dir"])
            config["specs_dir"] = specs.get("specs_dir")
            config["discovery_patterns"] = specs.get("discovery_patterns", [])
            config["discovery_names"] = specs.get("discovery_names", [])
            config["preflight"].update(specs.get("preflight", {}))

    return config


def get_api_key(config: dict) -> str | None:
    """Get API key from environment (optional for some specs)."""
    for env_var in config.get("auth_env_vars", []):
        key = os.environ.get(env_var)
        if key:
            return key

    for spec_config in config.get("specs", {}).values():
        for env_var in spec_config.get("auth_env_vars", []):
            key = os.environ.get(env_var)
            if key:
                return key

    return None


def fetch_url(
    url: str,
    api_key: str | None = None,
    requires_auth: bool = False,
) -> tuple[dict | None, str | None]:
    """Fetch JSON or YAML from URL with optional auth.

    Returns (spec, error_message). error_message is None on success.
    """
    if requires_auth:
        if not api_key:
            return None, "API key required but not set"
        url = f"{url}&key={api_key}" if "?" in url else f"{url}?key={api_key}"

    try:
        req = Request(url, headers={"User-Agent": "OpenAPI-Updater/1.0"})
        with urlopen(req, timeout=30) as response:
            data = response.read().decode("utf-8")

            try:
                return json.loads(data), None
            except json.JSONDecodeError:
                pass

            if HAS_YAML:
                try:
                    return yaml.safe_load(data), None
                except yaml.YAMLError as e:
                    return None, f"Failed to parse as JSON or YAML: {e}"

            return (
                None,
                "Response is not JSON and PyYAML not installed. "
                "Install PyYAML with 'pip install pyyaml'.",
            )
    except HTTPError as e:
        if e.code == 404:
            return None, "HTTP 404: Not found"
        return None, f"HTTP {e.code}: {e.reason}"
    except URLError as e:
        return None, f"Network error: {e.reason}"


def fetch_text_url(url: str, timeout: int = 20) -> tuple[str | None, str | None]:
    """Fetch text from URL."""
    try:
        req = Request(url, headers={"User-Agent": "OpenAPI-Updater/1.0"})
        with urlopen(req, timeout=timeout) as response:
            return response.read().decode("utf-8"), None
    except HTTPError as e:
        return None, f"HTTP {e.code}: {e.reason}"
    except URLError as e:
        return None, f"Network error: {e.reason}"


def count_endpoints(spec: dict) -> int:
    """Count total endpoints in spec."""
    count = 0
    for path_data in spec.get("paths", {}).values():
        for method in ["get", "post", "put", "patch", "delete"]:
            if method in path_data:
                count += 1
    return count


def count_schemas(spec: dict) -> int:
    """Count schemas in spec."""
    return len(spec.get("components", {}).get("schemas", {}))


def save_spec(spec: dict, output_dir: Path, spec_name: str) -> Path:
    """Save spec to output directory."""
    output_dir.mkdir(parents=True, exist_ok=True)
    filepath = output_dir / f"latest-{spec_name}.json"
    with open(filepath, "w") as f:
        json.dump(spec, f, indent=2)
    return filepath


def save_spec_metadata(
    specs_dir: Path,
    spec_name: str,
    spec: dict,
    url: str,
) -> tuple[str, str | None]:
    """Save spec version metadata to specs_dir/spec_metadata.json."""
    metadata_file = specs_dir / "spec_metadata.json"
    info = spec.get("info", {})
    current_version = info.get("version", "unknown")

    metadata = {}
    if metadata_file.exists():
        with open(metadata_file) as f:
            metadata = json.load(f)

    spec_meta = metadata.get("specs", {}).get(spec_name, {})
    history = spec_meta.get("version_history", [])
    prev_version = spec_meta.get("current_version")

    if prev_version and prev_version != current_version:
        history.insert(
            0,
            {
                "version": prev_version,
                "fetched_at": spec_meta.get("last_fetched"),
            },
        )
        history = history[:10]

    if "specs" not in metadata:
        metadata["specs"] = {}
    metadata["specs"][spec_name] = {
        "title": info.get("title", "Unknown"),
        "current_version": current_version,
        "last_fetched": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "source_url": url,
        "version_history": history,
    }

    with open(metadata_file, "w") as f:
        json.dump(metadata, f, indent=2)

    return current_version, prev_version


def print_spec_info(spec: dict, filepath: Path):
    """Print spec metadata."""
    info = spec.get("info", {})
    print(f"  Saved to: {filepath}")
    print(f"  OpenAPI: {spec.get('openapi', 'unknown')}")
    print(f"  Version: {info.get('version', 'unknown')}")
    print(f"  Title: {info.get('title', 'unknown')}")
    print(f"  Endpoints: {count_endpoints(spec)}")
    print(f"  Schemas: {count_schemas(spec)}")


def get_spec_urls(spec_config: dict) -> list[str]:
    """Build ordered source list: primary URL, then fallback_urls."""
    urls = []
    primary = spec_config.get("url")
    if primary:
        urls.append(primary)
    for fallback in spec_config.get("fallback_urls", []):
        if fallback and fallback not in urls:
            urls.append(fallback)
    return urls


def format_retry_command(config_dir: Path) -> str:
    """Render retry command when network becomes available again."""
    return (
        'cd "$(git rev-parse --show-toplevel)" && '
        f"python3 .agents/shared/openapi-toolkit/scripts/fetch_spec.py --config-dir {config_dir}"
    )


def print_offline_mode(config_dir: Path, reason: str):
    """Print a clear offline mode message with exact next command."""
    print(f"  OFFLINE MODE: {reason}", file=sys.stderr)
    print("  Next command once network is available:", file=sys.stderr)
    print(f"    {format_retry_command(config_dir)}", file=sys.stderr)


def extract_hash_from_url(url: str | None) -> str | None:
    """Extract spec hash from stainless URL when available."""
    if not url:
        return None
    decoded = unquote(url)
    match = re.search(r"openai-([a-f0-9]{10,})\.(?:json|ya?ml)", decoded)
    if match:
        return match.group(1)
    return None


def parse_stats_field(content: str, field: str) -> str | None:
    """Parse a simple scalar field from YAML-ish text."""
    pattern = rf"^\s*{re.escape(field)}\s*:\s*['\"]?([^'\"\n]+)['\"]?\s*$"
    match = re.search(pattern, content, re.MULTILINE)
    return match.group(1).strip() if match else None


def run_preflight(config: dict, config_dir: Path, spec_filter: str | None) -> bool:
    """Run drift check against external stats file.

    Returns True when online check completed, False when network failed.
    """
    preflight_cfg = dict(DEFAULT_PREFLIGHT)
    preflight_cfg.update(config.get("preflight", {}))

    stats_url = preflight_cfg.get("stats_url")
    stats_field = preflight_cfg.get("stats_field", "openapi_spec_url")
    if not stats_url:
        print("Preflight: skipped (no preflight.stats_url configured)")
        return True

    print("\n--- Preflight ---")
    print(f"Checking latest spec URL from: {stats_url}")

    stats_text, err = fetch_text_url(stats_url)
    if stats_text is None:
        print(f"Preflight failed: {err}", file=sys.stderr)
        if err and err.lower().startswith("network error"):
            print_offline_mode(
                config_dir,
                "Could not reach drift source while running preflight.",
            )
            return False
        return True

    latest_url = parse_stats_field(stats_text, stats_field)
    if not latest_url:
        print(
            f"Preflight warning: could not parse '{stats_field}' from stats source.",
            file=sys.stderr,
        )
        return True

    latest_hash = extract_hash_from_url(latest_url)
    print(f"Latest ({stats_field}): {latest_url}")

    specs = config.get("specs", {})
    for name, spec_cfg in specs.items():
        if spec_filter and name != spec_filter:
            continue

        pinned = spec_cfg.get("url")
        pinned_hash = extract_hash_from_url(pinned)
        in_sync = pinned == latest_url
        marker = "OK" if in_sync else "OUTDATED"

        print(f"\n[{name}] {marker}")
        print(f"  Pinned URL : {pinned}")
        print(f"  Latest URL : {latest_url}")
        if pinned_hash or latest_hash:
            print(f"  Pinned hash: {pinned_hash or 'n/a'}")
            print(f"  Latest hash: {latest_hash or 'n/a'}")
        if not in_sync:
            print("  Action: update specs.json primary/fallback URLs.")

    return True


def fetch_registered_specs(
    config: dict,
    config_dir: Path,
    spec_filter: str | None,
    output_dir: Path,
    api_key: str | None,
) -> int:
    """Fetch all registered specs (or a specific one)."""
    specs = config.get("specs", {})
    fetched = 0

    for name, spec_config in specs.items():
        if spec_filter and name != spec_filter:
            continue

        print(f"\n[{name}] {spec_config.get('name', 'Unknown')}")
        requires_auth = spec_config.get("requires_auth", False)
        experimental = spec_config.get("experimental", False)

        if experimental:
            print("  (experimental)")

        urls = get_spec_urls(spec_config)
        if not urls:
            print("  FAILED to fetch spec (no URL configured)")
            continue

        last_error = None
        had_network_error = False
        fetched_from_url = None
        spec = None

        for idx, url in enumerate(urls):
            source_label = "primary" if idx == 0 else f"fallback #{idx}"
            print(f"  Fetching ({source_label}) from {url.split('?')[0]}...")

            candidate, err = fetch_url(url, api_key, requires_auth)
            if candidate is None:
                last_error = err or "Unknown error"
                print(f"    Attempt failed: {last_error}", file=sys.stderr)
                if last_error.lower().startswith("network error"):
                    had_network_error = True
                continue

            if "openapi" not in candidate:
                last_error = "Not a valid OpenAPI spec"
                print(f"    Attempt failed: {last_error}", file=sys.stderr)
                continue

            spec = candidate
            fetched_from_url = url
            break

        if spec is None:
            print("  FAILED to fetch spec")
            if had_network_error:
                print_offline_mode(
                    config_dir,
                    f"Unable to reach configured source(s) for '{name}'.",
                )
            elif last_error:
                print(f"  Last error: {last_error}", file=sys.stderr)
            continue

        filepath = save_spec(spec, output_dir, name)
        print_spec_info(spec, filepath)

        specs_dir = config.get("specs_dir")
        if specs_dir:
            specs_path = Path(specs_dir)
            if specs_path.exists():
                version, prev = save_spec_metadata(
                    specs_path,
                    name,
                    spec,
                    fetched_from_url or urls[0],
                )
                if prev and prev != version:
                    print(f"  Version: {prev} → {version}")

        fetched += 1

    return fetched


def discover_new_specs(config: dict) -> list[tuple[str, str]]:
    """Probe for new specs at discovery patterns."""
    patterns = config.get("discovery_patterns", [])
    names = config.get("discovery_names", [])
    registered = set(config.get("specs", {}).keys())

    discovered = []

    for pattern in patterns:
        for name in names:
            if name in registered:
                continue

            url = pattern.replace("{name}", name)
            try:
                req = Request(url, headers={"User-Agent": "OpenAPI-Updater/1.0"})
                with urlopen(req, timeout=5) as response:
                    if response.status == 200:
                        discovered.append((name, url))
            except Exception:
                pass

    return discovered


def main():
    parser = argparse.ArgumentParser(description="Fetch OpenAPI specs")
    parser.add_argument(
        "--config-dir",
        type=Path,
        required=True,
        help="Directory containing config files",
    )
    parser.add_argument(
        "--spec",
        "-s",
        type=str,
        default=None,
        help="Fetch only this spec (default: all)",
    )
    parser.add_argument(
        "--no-discover",
        action="store_true",
        help="Skip discovery probing for new specs",
    )
    parser.add_argument(
        "--output",
        "-o",
        type=Path,
        default=None,
        help="Output directory (overrides config)",
    )
    parser.add_argument(
        "--preflight",
        action="store_true",
        help="Run drift preflight check before fetch",
    )
    parser.add_argument(
        "--preflight-only",
        action="store_true",
        help="Run only preflight drift check and exit",
    )
    args = parser.parse_args()

    if not args.config_dir.exists():
        print(f"Error: Config directory not found: {args.config_dir}")
        sys.exit(2)

    config = load_config(args.config_dir)

    if not config["specs"]:
        print(f"Error: No specs defined in {args.config_dir / 'specs.json'}")
        sys.exit(2)

    output_dir = args.output or Path(config["output_dir"])
    api_key = get_api_key(config)

    print("OpenAPI Spec Fetcher")
    print(f"Config: {args.config_dir}")
    print(f"Output: {output_dir}")

    if args.preflight_only:
        args.preflight = True

    preflight_ok = True
    if args.preflight:
        preflight_ok = run_preflight(config, args.config_dir, args.spec)
        if args.preflight_only:
            sys.exit(0 if preflight_ok else 1)

    if args.spec:
        spec_config = config.get("specs", {}).get(args.spec)
        if not spec_config:
            print(f"\nERROR: Unknown spec '{args.spec}'", file=sys.stderr)
            print(f"Available specs: {', '.join(config.get('specs', {}).keys())}")
            sys.exit(2)
        if spec_config.get("requires_auth") and not api_key:
            auth_vars = spec_config.get("auth_env_vars", config.get("auth_env_vars", []))
            print(
                f"\nERROR: {' or '.join(auth_vars)} required for '{args.spec}'",
                file=sys.stderr,
            )
            sys.exit(2)
    else:
        for name, spec_config in config.get("specs", {}).items():
            if spec_config.get("requires_auth") and not api_key:
                print(f"\nWARNING: API key not set - will skip '{name}' spec")

    fetched = fetch_registered_specs(config, args.config_dir, args.spec, output_dir, api_key)

    if not args.no_discover and not args.spec:
        print("\n--- Discovery ---")
        print("Probing for new specs...")
        discovered = discover_new_specs(config)

        if discovered:
            print("\n⚠️  NEW SPECS DISCOVERED:")
            for name, url in discovered:
                print(f"  - {name}: {url}")
            print(f"\nTo add to registry, update: {args.config_dir / 'specs.json'}")
        else:
            print("No new specs found.")

    print("\n--- Summary ---")
    print(f"Fetched: {fetched} spec(s)")
    print(f"Time: {datetime.now().isoformat()}")

    if fetched > 0:
        sys.exit(0)
    sys.exit(1)


if __name__ == "__main__":
    main()
