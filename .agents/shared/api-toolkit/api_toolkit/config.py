from __future__ import annotations

import json
import os
import re
import sys
import tempfile
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import parse_qsl, unquote, urlencode, urlsplit, urlunsplit
from urllib.request import Request, urlopen

try:
    import yaml

    HAS_YAML = True
except ImportError:  # pragma: no cover - depends on environment
    yaml = None
    HAS_YAML = False


EXIT_SUCCESS = 0
EXIT_FAILURE = 1
EXIT_USAGE = 2

ALLOWED_FORMATS = {"json", "text"}
AUTH_LOCATIONS = {"header", "query"}
HASHED_SPEC_URL_RE = re.compile(r"([a-f0-9]{10,})\.(?:json|ya?ml)")

DEFAULT_TYPE_MAPPINGS = {
    "string": "String",
    "integer": "int",
    "number": "double",
    "boolean": "bool",
    "array": "List",
    "object": "Map<String, dynamic>",
}


class ToolkitError(RuntimeError):
    """Base error for toolkit failures."""

    def __init__(self, message: str, *, exit_code: int = EXIT_USAGE) -> None:
        super().__init__(message)
        self.exit_code = exit_code


@dataclass(slots=True)
class PackageConfig:
    name: str
    display_name: str
    barrel_file: str
    barrel_files: list[str]
    models_dir: str
    live_models_dir: str | None
    resources_dir: str
    tests_dir: str
    examples_dir: str
    skip_files: list[str]
    internal_barrel_files: list[str]
    pr_title_prefix: str
    changelog_title: str


@dataclass(slots=True)
class SpecConfig:
    name: str
    local_file: str
    fetch_mode: str
    url: str | None = None
    fallback_urls: list[str] = field(default_factory=list)
    requires_auth: bool = False
    auth_env_vars: list[str] = field(default_factory=list)
    auth: "AuthConfig | None" = None
    description: str = ""
    source_file: str | None = None
    experimental: bool = False
    websocket_endpoints: dict[str, Any] = field(default_factory=dict)
    audit: "AuditConfig" = field(default_factory=lambda: AuditConfig())

    @property
    def resolved_auth(self) -> "AuthConfig | None":
        if not self.requires_auth:
            return None
        return self.auth or AuthConfig(location="query", name="key", prefix="")


@dataclass(slots=True, frozen=True)
class AuthConfig:
    location: str
    name: str
    prefix: str = ""


@dataclass(slots=True, frozen=True)
class ReferenceSymbolConfig:
    adapter: str
    path: str | None = None
    paths: list[str] = field(default_factory=list)
    class_name: str | None = None
    member_map_name: str | None = None
    include: list[str] = field(default_factory=list)
    exclude: list[str] = field(default_factory=list)
    aliases: dict[str, str] = field(default_factory=dict)

    @property
    def all_paths(self) -> list[str]:
        combined: list[str] = []
        if self.path:
            combined.append(self.path)
        combined.extend(self.paths)
        deduped: list[str] = []
        for item in combined:
            if item not in deduped:
                deduped.append(item)
        return deduped


@dataclass(slots=True, frozen=True)
class ReferenceImplConfig:
    repo: str
    ref: str
    resources: ReferenceSymbolConfig | None = None
    types: ReferenceSymbolConfig | None = None


@dataclass(slots=True, frozen=True)
class AuditConfig:
    excluded_schemas: list[str] = field(default_factory=list)
    schema_aliases: dict[str, str] = field(default_factory=dict)
    reference_impl: ReferenceImplConfig | None = None


@dataclass(slots=True)
class ManifestEntry:
    key: str
    spec: str
    kind: str
    dart_class: str
    file: str
    schema: str | None = None
    parent: str | None = None
    discriminator: dict[str, Any] | None = None
    tags: list[str] = field(default_factory=list)
    excluded_properties: list[str] = field(default_factory=list)
    enum_values: list[str] = field(default_factory=list)
    note: str | None = None

    @property
    def schema_name(self) -> str:
        return self.schema or self.key


@dataclass(slots=True)
class ManifestConfig:
    surface: str
    type_mappings: dict[str, str]
    placement: dict[str, Any]
    coverage: dict[str, Any]
    types: dict[str, ManifestEntry]


@dataclass(slots=True)
class DocumentationConfig:
    removed_apis: list[dict[str, Any]]
    tool_properties: dict[str, Any]
    excluded_resources: list[str]
    resource_to_example: dict[str, str]
    excluded_from_examples: list[str]
    drift_patterns: list[dict[str, Any]]
    live_features: dict[str, Any]


@dataclass(slots=True)
class ToolkitConfig:
    config_dir: Path
    repo_root: Path
    package_root: Path
    package: PackageConfig
    specs_dir: Path
    output_dir: Path
    specs: dict[str, SpecConfig]
    preflight: dict[str, Any]
    manifest: ManifestConfig
    documentation: DocumentationConfig

    def get_spec(self, spec_name: str | None) -> tuple[str, SpecConfig]:
        if spec_name:
            if spec_name not in self.specs:
                raise ToolkitError(
                    f"Unknown spec '{spec_name}'. Available: {', '.join(sorted(self.specs))}",
                )
            return spec_name, self.specs[spec_name]
        if not self.specs:
            raise ToolkitError("No specs configured")
        first = next(iter(self.specs.items()))
        return first

    def canonical_spec_path(self, spec_name: str) -> Path:
        spec = self.specs[spec_name]
        return (self.specs_dir / spec.local_file).resolve()

    def fetched_spec_path(self, spec_name: str) -> Path:
        return (self.output_dir / f"latest-{spec_name}.json").resolve()

    def resolve_package_path(self, relative_path: str) -> Path:
        return ensure_within_root(
            (self.package_root / relative_path).resolve(),
            self.package_root,
        )

    def allowed_output_roots(self) -> list[Path]:
        roots = [self.repo_root, self.package_root, self.output_dir, self.specs_dir]
        deduped: list[Path] = []
        for root in roots:
            if root not in deduped:
                deduped.append(root)
        return deduped


def stderr(message: str) -> None:
    print(message, file=sys.stderr)


def is_tty_stdout() -> bool:
    return sys.stdout.isatty()


def choose_format(explicit_format: str | None) -> str:
    if explicit_format:
        if explicit_format not in ALLOWED_FORMATS:
            raise ToolkitError(
                f"Unsupported --format '{explicit_format}'. Expected one of: {', '.join(sorted(ALLOWED_FORMATS))}"
            )
        return explicit_format
    return "text" if is_tty_stdout() else "json"


def validate_identifier(value: str, label: str) -> str:
    if not value:
        raise ToolkitError(f"{label} must not be empty")
    if any(ord(char) < 32 for char in value):
        raise ToolkitError(f"{label} contains control characters")
    lowered = value.lower()
    if ".." in value or "/" in value or "\\" in value:
        raise ToolkitError(f"{label} must not contain path separators or traversal")
    if "?" in value or "#" in value or "&" in value:
        raise ToolkitError(f"{label} must not contain URL/query fragments")
    if "%2e" in lowered or "%2f" in lowered or "%5c" in lowered:
        raise ToolkitError(f"{label} must not contain encoded traversal sequences")
    return value


def ensure_within_root(path: Path, root: Path) -> Path:
    try:
        path.relative_to(root.resolve())
    except ValueError as exc:  # pragma: no cover - trivial
        raise ToolkitError(f"Path '{path}' escapes allowed root '{root}'") from exc
    return path


def validate_output_path(path: Path, allowed_roots: list[Path]) -> Path:
    resolved = path.resolve()
    for root in allowed_roots:
        try:
            resolved.relative_to(root.resolve())
            return resolved
        except ValueError:
            continue
    raise ToolkitError(
        f"Refusing to write outside allowed roots: {resolved}",
    )


def repo_root_from_path(path: Path) -> Path:
    current = path.resolve()
    for candidate in [current, *current.parents]:
        pubspec = candidate / "pubspec.yaml"
        if pubspec.exists():
            try:
                content = pubspec.read_text()
            except OSError:
                continue
            if "workspace:" in content or candidate == current:
                return candidate
    raise ToolkitError(f"Could not locate repo root from {path}")


def package_root_from_config_dir(config_dir: Path) -> Path:
    current = config_dir.resolve()
    for candidate in current.parents:
        if (candidate / "pubspec.yaml").exists():
            return candidate
    raise ToolkitError(f"Could not locate package root from {config_dir}")


def read_json_file(path: Path, default: Any | None = None) -> Any:
    if not path.exists():
        return default
    try:
        return json.loads(path.read_text())
    except json.JSONDecodeError as exc:
        raise ToolkitError(f"Invalid JSON in {path}: {exc}") from exc


def read_structured_file(path: Path) -> Any:
    content = path.read_text()
    return read_structured_text(content, source=path)


def read_structured_text(content: str, *, source: str | Path = "<input>") -> Any:
    try:
        return json.loads(content)
    except json.JSONDecodeError:
        pass
    if HAS_YAML:
        try:
            return yaml.safe_load(content)
        except yaml.YAMLError as exc:
            raise ToolkitError(f"Failed to parse {source}: {exc}") from exc
    raise ToolkitError(
        f"Failed to parse {source}. Install PyYAML with `{sys.executable} -m pip install pyyaml --user`"
    )


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(f"{json.dumps(payload, indent=2, sort_keys=True)}\n")


def default_output_dir(package_name: str) -> Path:
    return (Path(tempfile.gettempdir()) / f"{package_name}-api-toolkit").resolve()


def _parse_auth_config(raw: Any, *, source: str) -> AuthConfig | None:
    if raw is None:
        return None
    if not isinstance(raw, dict):
        raise ToolkitError(f"{source} auth config must be an object")
    location = raw.get("location", "query")
    if location not in AUTH_LOCATIONS:
        raise ToolkitError(f"{source} auth location must be one of: {', '.join(sorted(AUTH_LOCATIONS))}")
    default_name = "Authorization" if location == "header" else "key"
    name = raw.get("name", default_name)
    if not isinstance(name, str) or not name:
        raise ToolkitError(f"{source} auth name must be a non-empty string")
    prefix = raw.get("prefix", "")
    if not isinstance(prefix, str):
        raise ToolkitError(f"{source} auth prefix must be a string")
    return AuthConfig(location=location, name=name, prefix=prefix)


def _parse_reference_symbol_config(raw: Any, *, source: str) -> ReferenceSymbolConfig | None:
    if raw is None:
        return None
    if not isinstance(raw, dict):
        raise ToolkitError(f"{source} must be an object")
    adapter = raw.get("adapter")
    if not isinstance(adapter, str) or not adapter:
        raise ToolkitError(f"{source}.adapter must be a non-empty string")
    path = raw.get("path")
    if path is not None and not isinstance(path, str):
        raise ToolkitError(f"{source}.path must be a string")
    paths = raw.get("paths", [])
    if not isinstance(paths, list) or any(not isinstance(item, str) for item in paths):
        raise ToolkitError(f"{source}.paths must be a list of strings")
    class_name = raw.get("class_name")
    if class_name is not None and not isinstance(class_name, str):
        raise ToolkitError(f"{source}.class_name must be a string")
    member_map_name = raw.get("member_map_name")
    if member_map_name is not None and not isinstance(member_map_name, str):
        raise ToolkitError(f"{source}.member_map_name must be a string")
    include = raw.get("include", [])
    if not isinstance(include, list) or any(not isinstance(item, str) for item in include):
        raise ToolkitError(f"{source}.include must be a list of strings")
    exclude = raw.get("exclude", [])
    if not isinstance(exclude, list) or any(not isinstance(item, str) for item in exclude):
        raise ToolkitError(f"{source}.exclude must be a list of strings")
    aliases = raw.get("aliases", {})
    if not isinstance(aliases, dict) or any(
        not isinstance(key, str) or not isinstance(value, str) for key, value in aliases.items()
    ):
        raise ToolkitError(f"{source}.aliases must be an object of string-to-string mappings")
    return ReferenceSymbolConfig(
        adapter=adapter,
        path=path,
        paths=paths,
        class_name=class_name,
        member_map_name=member_map_name,
        include=include,
        exclude=exclude,
        aliases=aliases,
    )


def _parse_reference_impl_config(raw: Any, *, source: str) -> ReferenceImplConfig | None:
    if raw is None:
        return None
    if not isinstance(raw, dict):
        raise ToolkitError(f"{source} must be an object")
    repo = raw.get("repo")
    ref = raw.get("ref", "main")
    if not isinstance(repo, str) or not repo:
        raise ToolkitError(f"{source}.repo must be a non-empty string")
    if not isinstance(ref, str) or not ref:
        raise ToolkitError(f"{source}.ref must be a non-empty string")
    return ReferenceImplConfig(
        repo=repo,
        ref=ref,
        resources=_parse_reference_symbol_config(raw.get("resources"), source=f"{source}.resources"),
        types=_parse_reference_symbol_config(raw.get("types"), source=f"{source}.types"),
    )


def _parse_audit_config(raw: Any, *, source: str) -> AuditConfig:
    if raw is None:
        return AuditConfig()
    if not isinstance(raw, dict):
        raise ToolkitError(f"{source} must be an object")
    excluded_schemas = raw.get("excluded_schemas", [])
    if not isinstance(excluded_schemas, list) or any(not isinstance(item, str) for item in excluded_schemas):
        raise ToolkitError(f"{source}.excluded_schemas must be a list of strings")
    schema_aliases = raw.get("schema_aliases", {})
    if not isinstance(schema_aliases, dict) or any(
        not isinstance(key, str) or not isinstance(value, str) for key, value in schema_aliases.items()
    ):
        raise ToolkitError(f"{source}.schema_aliases must be an object of string-to-string mappings")
    return AuditConfig(
        excluded_schemas=excluded_schemas,
        schema_aliases=schema_aliases,
        reference_impl=_parse_reference_impl_config(raw.get("reference_impl"), source=f"{source}.reference_impl"),
    )


def load_toolkit_config(config_dir: Path) -> ToolkitConfig:
    config_dir = config_dir.resolve()
    if not config_dir.exists():
        raise ToolkitError(f"Config directory not found: {config_dir}")

    repo_root = repo_root_from_path(config_dir)
    package_root = package_root_from_config_dir(config_dir)

    package_json = read_json_file(config_dir / "package.json", {})
    package = PackageConfig(
        name=package_json.get("name", package_root.name),
        display_name=package_json.get("display_name", package_root.name),
        barrel_file=package_json.get("barrel_file", f"lib/{package_root.name}.dart"),
        barrel_files=package_json.get("barrel_files", []),
        models_dir=package_json.get("models_dir", "lib/src/models"),
        live_models_dir=package_json.get("live_models_dir"),
        resources_dir=package_json.get("resources_dir", "lib/src/resources"),
        tests_dir=package_json.get("tests_dir", "test/unit/models"),
        examples_dir=package_json.get("examples_dir", "example"),
        skip_files=package_json.get("skip_files", ["copy_with_sentinel.dart"]),
        internal_barrel_files=package_json.get("internal_barrel_files", []),
        pr_title_prefix=package_json.get("pr_title_prefix", f"feat({package_root.name})"),
        changelog_title=package_json.get("changelog_title", f"{package_root.name} API Changelog"),
    )

    specs_json = read_json_file(config_dir / "specs.json", {})
    specs_dir_raw = specs_json.get("specs_dir", f"packages/{package_root.name}/specs")
    specs_dir = ensure_within_root(
        (repo_root / specs_dir_raw if not Path(specs_dir_raw).is_absolute() else Path(specs_dir_raw)).resolve(),
        repo_root,
    )
    output_dir_raw = specs_json.get("output_dir", str(default_output_dir(package_root.name)))
    output_dir = Path(output_dir_raw).resolve()
    preflight = specs_json.get("preflight", {})
    specs: dict[str, SpecConfig] = {}
    for name, raw in specs_json.get("specs", {}).items():
        validate_identifier(name, "spec name")
        specs[name] = SpecConfig(
            name=raw.get("name", name),
            local_file=raw.get("local_file", "openapi.json"),
            fetch_mode=raw.get("fetch_mode", "remote"),
            url=raw.get("url"),
            fallback_urls=raw.get("fallback_urls", []),
            requires_auth=raw.get("requires_auth", False),
            auth_env_vars=raw.get("auth_env_vars", []),
            auth=_parse_auth_config(raw.get("auth"), source=f"specs.{name}"),
            description=raw.get("description", ""),
            source_file=raw.get("source_file"),
            experimental=raw.get("experimental", False),
            websocket_endpoints=raw.get("websocket_endpoints", {}),
            audit=_parse_audit_config(raw.get("audit"), source=f"specs.{name}.audit"),
        )

    manifest_json = read_json_file(config_dir / "manifest.json", {})
    manifest_surface = manifest_json.get("surface", "openapi")
    manifest_types: dict[str, ManifestEntry] = {}
    for key, raw in manifest_json.get("types", {}).items():
        manifest_types[key] = ManifestEntry(
            key=key,
            spec=raw.get("spec", next(iter(specs.keys()), "main")),
            kind=raw.get("kind", "object"),
            dart_class=raw.get("dart_class", key),
            file=raw.get("file", ""),
            schema=raw.get("schema"),
            parent=raw.get("parent"),
            discriminator=raw.get("discriminator"),
            tags=raw.get("tags", []),
            excluded_properties=raw.get("excluded_properties", []),
            enum_values=raw.get("enum_values", []),
            note=raw.get("note"),
        )

    manifest = ManifestConfig(
        surface=manifest_surface,
        type_mappings={**DEFAULT_TYPE_MAPPINGS, **manifest_json.get("type_mappings", {})},
        placement=manifest_json.get("placement", {}),
        coverage=manifest_json.get("coverage", {}),
        types=manifest_types,
    )

    documentation_json = read_json_file(config_dir / "documentation.json", {})
    documentation = DocumentationConfig(
        removed_apis=documentation_json.get("removed_apis", []),
        tool_properties=documentation_json.get("tool_properties", {}),
        excluded_resources=documentation_json.get("excluded_resources", []),
        resource_to_example=documentation_json.get("resource_to_example", {}),
        excluded_from_examples=documentation_json.get("excluded_from_examples", []),
        drift_patterns=documentation_json.get("drift_patterns", []),
        live_features=documentation_json.get("live_features", {}),
    )

    return ToolkitConfig(
        config_dir=config_dir,
        repo_root=repo_root,
        package_root=package_root,
        package=package,
        specs_dir=specs_dir,
        output_dir=output_dir,
        specs=specs,
        preflight=preflight,
        manifest=manifest,
        documentation=documentation,
    )


def dump_manifest(config: ToolkitConfig) -> dict[str, Any]:
    payload: dict[str, Any] = {
        "surface": config.manifest.surface,
        "type_mappings": config.manifest.type_mappings,
        "placement": config.manifest.placement,
        "coverage": config.manifest.coverage,
        "types": {},
    }
    for key, entry in sorted(config.manifest.types.items()):
        payload["types"][key] = {
            "spec": entry.spec,
            "kind": entry.kind,
            "dart_class": entry.dart_class,
            "file": entry.file,
        }
        if entry.schema:
            payload["types"][key]["schema"] = entry.schema
        if entry.parent:
            payload["types"][key]["parent"] = entry.parent
        if entry.discriminator:
            payload["types"][key]["discriminator"] = entry.discriminator
        if entry.tags:
            payload["types"][key]["tags"] = entry.tags
        if entry.excluded_properties:
            payload["types"][key]["excluded_properties"] = entry.excluded_properties
        if entry.enum_values:
            payload["types"][key]["enum_values"] = entry.enum_values
        if entry.note:
            payload["types"][key]["note"] = entry.note
    return payload


def get_api_key(spec: SpecConfig) -> str | None:
    for env_var in spec.auth_env_vars:
        value = os.environ.get(env_var)
        if value:
            return value
    return None


def _authenticated_request(url: str, api_key: str | None, auth: AuthConfig | None) -> Request:
    if auth is None:
        return Request(url, headers={"User-Agent": "api-toolkit/1.0"})
    if not api_key:
        raise ToolkitError("API key required but not configured")
    value = f"{auth.prefix}{api_key}"
    if auth.location == "header":
        return Request(url, headers={"User-Agent": "api-toolkit/1.0", auth.name: value})
    split = urlsplit(url)
    query = parse_qsl(split.query, keep_blank_values=True)
    query.append((auth.name, value))
    target_url = urlunsplit((split.scheme, split.netloc, split.path, urlencode(query), split.fragment))
    return Request(target_url, headers={"User-Agent": "api-toolkit/1.0"})


def fetch_remote_document(url: str, api_key: str | None, auth: AuthConfig | None = None) -> tuple[str | None, str | None]:
    try:
        request = _authenticated_request(url, api_key, auth)
        with urlopen(request, timeout=30) as response:
            return response.read().decode("utf-8"), None
    except ToolkitError as exc:
        return None, str(exc)
    except HTTPError as exc:  # pragma: no cover - network dependent
        return None, f"HTTP {exc.code}: {exc.reason}"
    except URLError as exc:  # pragma: no cover - network dependent
        return None, f"Network error: {exc.reason}"


def extract_hash_from_url(url: str | None) -> str | None:
    if not url:
        return None
    decoded = unquote(url)
    match = HASHED_SPEC_URL_RE.search(decoded)
    if match:
        return match.group(1)
    return None
