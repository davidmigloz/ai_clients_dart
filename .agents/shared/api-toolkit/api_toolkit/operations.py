from __future__ import annotations

import ast
import inspect
import json
import os
import re
import shutil
import subprocess
import tarfile
import tempfile
from collections import defaultdict
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

from .config import (
    AuthConfig,
    EXIT_FAILURE,
    EXIT_SUCCESS,
    EXIT_USAGE,
    DocumentationConfig,
    ManifestEntry,
    ReferenceImplConfig,
    ReferenceSymbolConfig,
    SpecConfig,
    ToolkitConfig,
    ToolkitError,
    default_output_dir,
    dump_manifest,
    extract_hash_from_url,
    fetch_remote_document,
    get_api_key,
    load_toolkit_config,
    read_json_file,
    read_structured_file,
    read_structured_text,
    repo_root_from_path,
    stderr,
    validate_identifier,
    validate_output_path,
    write_json,
)
from .dart_inspect import (
    camel_case,
    contains_all_names,
    extract_class_block,
    extract_fields,
    extract_from_json_keys,
    extract_method_body,
    extract_public_methods,
    find_declared_classes,
    read_text,
    snake_case,
    to_pascal_case,
)


HTTP_METHODS = ("get", "post", "put", "patch", "delete")
UNKNOWN_ENUM_FALLBACKS = {"unknown", "unspecified"}
MAX_VERSION_HISTORY = 10
VERSION_SEGMENT_RE = re.compile(r"^v\d+")
PART_OF_RE = re.compile(r"\bpart of\b")
WORKSPACE_BLOCK_RE = re.compile(r"workspace:\n((?:\s+- .+\n)+)")
DART_EXPORT_DIRECTIVE_RE = re.compile(r"\bexport\b[\s\S]*?;")
DART_QUOTED_PATH_RE = re.compile(r"""(['"])([^'"]+\.dart)\1""")
DART_RESOURCE_GETTER_RE = re.compile(r"\b([A-Z]\w*Resource)\??\s+get\s+(\w+)\s*(?:=>|{)")


@dataclass(frozen=True, slots=True)
class OpenApiDocResource:
    resource_key: str
    access_path: str
    example_key: str


def _load_spec_payload(path: Path) -> dict[str, Any]:
    payload = read_structured_file(path)
    if not isinstance(payload, dict):
        raise ToolkitError(f"Spec payload at {path} must be an object")
    return payload


def _selected_spec_path(config: ToolkitConfig, spec_name: str, *, prefer_fetched: bool = False) -> Path:
    fetched = config.fetched_spec_path(spec_name)
    canonical = config.canonical_spec_path(spec_name)
    if prefer_fetched and fetched.exists():
        return fetched
    if canonical.exists():
        return canonical
    if fetched.exists():
        return fetched
    raise ToolkitError(f"No spec found for '{spec_name}'. Run fetch first or check {canonical}")


def _infer_openapi_kind(schema_name: str, schema: dict[str, Any]) -> str:
    if schema.get("enum"):
        return "enum"
    if schema.get("oneOf") and all("$ref" in item for item in schema.get("oneOf", [])):
        return "sealed_parent"
    return "object"


def _resource_patterns_from_spec(spec: dict[str, Any]) -> dict[str, Any]:
    categories: dict[str, Any] = {}
    for path in sorted(spec.get("paths", {})):
        parts = _trim_path_prefixes(path.strip("/").split("/"))
        if not parts:
            continue
        resource = parts[0].replace("-", "_")
        categories.setdefault(
            resource,
            {
                "patterns": sorted({resource, resource.rstrip("s"), resource.replace("_", "")}),
                "directory": resource,
            },
        )
    return categories


def _infer_category(schema_name: str, placement: dict[str, Any]) -> str:
    name_lower = schema_name.lower()
    categories = placement.get("categories", {})
    for category, details in categories.items():
        for pattern in details.get("patterns", []):
            if pattern and pattern.lower() in name_lower:
                return details.get("directory", category)
    return placement.get("default_category", "common")


def _is_path_parameter(segment: str) -> bool:
    return segment.startswith("{") and segment.endswith("}")


def _trim_path_prefixes(parts: list[str]) -> list[str]:
    trimmed = list(parts)
    while trimmed and (_is_path_parameter(trimmed[0]) or trimmed[0] == "api" or VERSION_SEGMENT_RE.match(trimmed[0])):
        trimmed = trimmed[1:]
    return trimmed


def _normalize_resource_name(name: str) -> str:
    return camel_case(name.replace("_resource", "").replace("-", "_"))


def _normalize_coverage_resource_name(name: str) -> str:
    base = re.split(r"[?#]", name, maxsplit=1)[0]
    return snake_case(base.replace("_resource", "").replace("-", "_")).replace("__", "_")


def _normalize_example_name(name: str) -> str:
    return snake_case(name).removesuffix("_example")


def _discover_openapi_doc_resources(config: ToolkitConfig) -> list[OpenApiDocResource]:
    resources_dir = config.package_root / config.package.resources_dir
    if not resources_dir.exists():
        return []

    discovered: list[OpenApiDocResource] = []
    for path in sorted(resources_dir.rglob("*_resource.dart")):
        rel_path = path.relative_to(resources_dir)
        if path.name.startswith(".") or any(part.startswith(".") for part in rel_path.parts):
            continue

        stem = path.stem.replace("_resource", "")
        resource_key = _normalize_resource_name(path.stem)
        directories = list(rel_path.parts[:-1])

        if not directories:
            access_path = resource_key
            example_key = _normalize_example_name(stem)
        else:
            parent_segments = [_normalize_resource_name(part) for part in directories]
            example_key = _normalize_example_name(directories[0])
            parent_dir = directories[-1]
            if stem == parent_dir:
                access_segments = parent_segments
            elif stem.startswith(f"{parent_dir}_"):
                access_segments = [*parent_segments, _normalize_resource_name(stem[len(parent_dir) + 1 :])]
            else:
                access_segments = [*parent_segments, _normalize_resource_name(stem)]
            access_path = ".".join(access_segments)

        discovered.append(
            OpenApiDocResource(
                resource_key=resource_key,
                access_path=access_path,
                example_key=example_key,
            )
        )

    return discovered


def _infer_file_for_schema(models_dir: str, placement: dict[str, Any], schema_name: str) -> str:
    directory = _infer_category(schema_name, placement)
    return f"{models_dir}/{directory}/{snake_case(schema_name)}.dart"


def _normalize_discriminator_mapping(mapping: dict[str, Any]) -> dict[str, str]:
    normalized: dict[str, str] = {}
    for discriminator_value, target in mapping.items():
        if not isinstance(target, str):
            continue
        normalized[target.split("/")[-1]] = discriminator_value
    return normalized


def _build_initial_manifest_from_spec(
    *,
    spec: dict[str, Any],
    package_name: str,
    spec_name: str,
    models_dir: str,
    existing_placement: dict[str, Any] | None = None,
) -> dict[str, Any]:
    placement = existing_placement or {
        "categories": _resource_patterns_from_spec(spec),
        "default_category": "common",
        "parent_model_patterns": {},
    }
    manifest: dict[str, Any] = {
        "surface": "openapi",
        "type_mappings": {},
        "placement": placement,
        "coverage": {
            "excluded_paths": [],
            "excluded_tags": [],
            "priority_resources": [],
            "notes": {},
            "expected_properties": {},
            "excluded_properties": {"global": []},
        },
        "types": {},
    }
    schemas = spec.get("components", {}).get("schemas", {})
    for schema_name, schema in sorted(schemas.items()):
        kind = _infer_openapi_kind(schema_name, schema)
        manifest["types"][schema_name] = {
            "spec": spec_name,
            "kind": kind,
            "dart_class": to_pascal_case(schema_name),
            "file": _infer_file_for_schema(models_dir, placement, schema_name),
            "schema": schema_name,
        }
        if kind == "sealed_parent":
            discriminator = schema.get("discriminator", {})
            if discriminator:
                manifest["types"][schema_name]["discriminator"] = {
                    "field": discriminator.get("propertyName"),
                    "mapping": _normalize_discriminator_mapping(discriminator.get("mapping", {})),
                }
    return manifest


def _read_git_file(repo_root: Path, git_ref: str, path: Path) -> dict[str, Any]:
    relative = path.resolve().relative_to(repo_root.resolve())
    completed = subprocess.run(
        ["git", "show", f"{git_ref}:{relative.as_posix()}"],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )
    if completed.returncode != 0:
        raise ToolkitError(f"Unable to read {relative} from git ref '{git_ref}': {completed.stderr.strip()}")
    payload = read_structured_text(completed.stdout, source=f"{relative} from git ref '{git_ref}'")
    if not isinstance(payload, dict):
        raise ToolkitError(f"Payload at {relative} from git ref '{git_ref}' must be an object")
    return payload


def _load_old_new_payloads(
    config: ToolkitConfig,
    spec_name: str,
    *,
    baseline: Path | None = None,
    git_ref: str | None = None,
) -> tuple[dict[str, Any], dict[str, Any]]:
    canonical_path = config.canonical_spec_path(spec_name)
    if git_ref:
        old_payload = _read_git_file(config.repo_root, git_ref, canonical_path)
    else:
        old_payload = _load_spec_payload(baseline or canonical_path)
    new_payload = _load_spec_payload(_selected_spec_path(config, spec_name, prefer_fetched=True))
    return old_payload, new_payload


def _extract_openapi_endpoints(spec: dict[str, Any]) -> dict[str, dict[str, Any]]:
    endpoints: dict[str, dict[str, Any]] = {}
    for path, path_payload in spec.get("paths", {}).items():
        for method in HTTP_METHODS:
            if method not in path_payload:
                continue
            operation = path_payload[method]
            key = f"{method.upper()} {path}"
            tags = operation.get("tags", [])
            endpoints[key] = {
                "path": path,
                "method": method.upper(),
                "operation_id": operation.get("operationId", ""),
                "summary": operation.get("summary", ""),
                "tags": tags,
                "request_schema": _extract_operation_schema(operation.get("requestBody")),
                "response_schema": _extract_response_schema(operation.get("responses", {})),
                "parameters": sorted(parameter.get("name", "") for parameter in operation.get("parameters", [])),
            }
    return endpoints


def _extract_operation_schema(request_body: Any) -> str | None:
    if not isinstance(request_body, dict):
        return None
    content = request_body.get("content", {})
    schema = content.get("application/json", {}).get("schema", {})
    if "$ref" in schema:
        return schema["$ref"].split("/")[-1]
    return None


def _extract_response_schema(responses: dict[str, Any]) -> str | None:
    for status, response in responses.items():
        if not status.startswith("2") and status != "default":
            continue
        content = response.get("content", {})
        schema = content.get("application/json", {}).get("schema", {})
        if "$ref" in schema:
            return schema["$ref"].split("/")[-1]
    return None


def _empty_flattened_schema() -> dict[str, Any]:
    return {
        "type": "object",
        "properties": {},
        "required": set(),
        "enum_values": set(),
        "union_members": set(),
        "description": "",
    }


def _flatten_schema(schema: dict[str, Any], all_schemas: dict[str, Any], resolving_refs: tuple[str, ...] = ()) -> dict[str, Any]:
    result = {
        "type": schema.get("type", "object"),
        "properties": {},
        "required": set(schema.get("required", [])),
        "enum_values": set(schema.get("enum", [])),
        "union_members": set(),
        "description": schema.get("description", ""),
    }

    if "$ref" in schema:
        ref_name = schema["$ref"].split("/")[-1]
        if ref_name in resolving_refs:
            return _empty_flattened_schema()
        ref_schema = all_schemas.get(ref_name, {})
        return _flatten_schema(ref_schema, all_schemas, (*resolving_refs, ref_name))

    for item in schema.get("allOf", []):
        flattened = _flatten_schema(item, all_schemas, resolving_refs)
        result["properties"].update(flattened["properties"])
        result["required"].update(flattened["required"])
        result["enum_values"].update(flattened["enum_values"])
        result["union_members"].update(flattened["union_members"])

    result["properties"].update(schema.get("properties", {}))

    for union_key in ("oneOf", "anyOf"):
        for item in schema.get(union_key, []):
            if "$ref" in item:
                result["union_members"].add(item["$ref"].split("/")[-1])
            elif "type" in item:
                result["union_members"].add(f"{union_key}:{item['type']}")

    return result


def _extract_openapi_schemas(spec: dict[str, Any]) -> dict[str, dict[str, Any]]:
    schemas = spec.get("components", {}).get("schemas", {})
    results: dict[str, dict[str, Any]] = {}
    for name, schema in schemas.items():
        flattened = _flatten_schema(schema, schemas)
        results[name] = {
            "name": name,
            "type": flattened["type"],
            "properties": flattened["properties"],
            "required": sorted(flattened["required"]),
            "enum_values": sorted(flattened["enum_values"]),
            "union_members": sorted(flattened["union_members"]),
        }
    return results


def _compare_openapi(old_spec: dict[str, Any], new_spec: dict[str, Any]) -> dict[str, Any]:
    old_endpoints = _extract_openapi_endpoints(old_spec)
    new_endpoints = _extract_openapi_endpoints(new_spec)
    old_schemas = _extract_openapi_schemas(old_spec)
    new_schemas = _extract_openapi_schemas(new_spec)

    endpoint_keys_old = set(old_endpoints)
    endpoint_keys_new = set(new_endpoints)
    schema_keys_old = set(old_schemas)
    schema_keys_new = set(new_schemas)

    modified_endpoints: list[dict[str, Any]] = []
    for key in sorted(endpoint_keys_old & endpoint_keys_new):
        old_ep = old_endpoints[key]
        new_ep = new_endpoints[key]
        changes = []
        if old_ep["request_schema"] != new_ep["request_schema"]:
            changes.append({"type": "request_schema_changed", "old": old_ep["request_schema"], "new": new_ep["request_schema"]})
        if old_ep["response_schema"] != new_ep["response_schema"]:
            changes.append({"type": "response_schema_changed", "old": old_ep["response_schema"], "new": new_ep["response_schema"]})
        old_params = set(old_ep["parameters"])
        new_params = set(new_ep["parameters"])
        for item in sorted(new_params - old_params):
            changes.append({"type": "parameter_added", "name": item})
        for item in sorted(old_params - new_params):
            changes.append({"type": "parameter_removed", "name": item, "breaking": True})
        if changes:
            modified_endpoints.append({"endpoint": new_ep, "changes": changes})

    modified_schemas: list[dict[str, Any]] = []
    for key in sorted(schema_keys_old & schema_keys_new):
        old_schema = old_schemas[key]
        new_schema = new_schemas[key]
        changes = []
        old_props = set(old_schema["properties"])
        new_props = set(new_schema["properties"])
        for prop in sorted(new_props - old_props):
            changes.append({"type": "property_added", "property": prop, "breaking": prop in new_schema["required"]})
        for prop in sorted(old_props - new_props):
            changes.append({"type": "property_removed", "property": prop, "breaking": True})
        if old_schema["enum_values"] != new_schema["enum_values"]:
            changes.append({
                "type": "enum_changed",
                "old": old_schema["enum_values"],
                "new": new_schema["enum_values"],
            })
        if old_schema["union_members"] != new_schema["union_members"]:
            changes.append({
                "type": "union_members_changed",
                "old": old_schema["union_members"],
                "new": new_schema["union_members"],
            })
        if changes:
            modified_schemas.append({"schema": new_schema, "changes": changes})

    return {
        "endpoints": {
            "added": [new_endpoints[key] for key in sorted(endpoint_keys_new - endpoint_keys_old)],
            "modified": modified_endpoints,
            "removed": [old_endpoints[key] for key in sorted(endpoint_keys_old - endpoint_keys_new)],
        },
        "schemas": {
            "added": [new_schemas[key] for key in sorted(schema_keys_new - schema_keys_old)],
            "modified": modified_schemas,
            "removed": [old_schemas[key] for key in sorted(schema_keys_old - schema_keys_new)],
        },
    }


def _extract_ws_types(schema: dict[str, Any]) -> dict[str, dict[str, Any]]:
    message_types = schema.get("message_types", {})
    config_types = schema.get("config_types", {})
    enums = schema.get("enums", {})
    return {
        "client_messages": message_types.get("client", {}),
        "server_messages": message_types.get("server", {}),
        "config_types": config_types,
        "enums": enums,
    }


def _compare_named_maps(old_map: dict[str, Any], new_map: dict[str, Any], *, field_key: str = "fields") -> dict[str, Any]:
    old_keys = set(old_map)
    new_keys = set(new_map)
    modified = []
    for key in sorted(old_keys & new_keys):
        old_item = old_map[key]
        new_item = new_map[key]
        changes = []
        if field_key == "fields":
            old_fields = set(old_item.get("fields", {}))
            new_fields = set(new_item.get("fields", {}))
            if old_fields != new_fields:
                changes.append(
                    {
                        "added_fields": sorted(new_fields - old_fields),
                        "removed_fields": sorted(old_fields - new_fields),
                    }
                )
        elif field_key == "values":
            old_values = set(old_item.get("values", []))
            new_values = set(new_item.get("values", []))
            if old_values != new_values:
                changes.append(
                    {
                        "added_values": sorted(new_values - old_values),
                        "removed_values": sorted(old_values - new_values),
                    }
                )
        if changes:
            modified.append({"name": key, "changes": changes})

    return {
        "added": sorted(new_keys - old_keys),
        "removed": sorted(old_keys - new_keys),
        "modified": modified,
    }


def _compare_websocket(old_spec: dict[str, Any], new_spec: dict[str, Any]) -> dict[str, Any]:
    old_types = _extract_ws_types(old_spec)
    new_types = _extract_ws_types(new_spec)
    return {
        "client_messages": _compare_named_maps(old_types["client_messages"], new_types["client_messages"], field_key="fields"),
        "server_messages": _compare_named_maps(old_types["server_messages"], new_types["server_messages"], field_key="fields"),
        "config_types": _compare_named_maps(old_types["config_types"], new_types["config_types"], field_key="fields"),
        "enums": _compare_named_maps(old_types["enums"], new_types["enums"], field_key="values"),
    }


def _coverage_gaps(config: ToolkitConfig, spec: dict[str, Any], *, resource_filter: set[str] | None = None) -> list[dict[str, Any]]:
    resources_dir = config.package_root / config.package.resources_dir
    if not resources_dir.exists():
        return [{"resource": "*", "reason": f"Missing resources directory: {config.package.resources_dir}"}]

    excluded_paths = config.manifest.coverage.get("excluded_paths", [])
    excluded_tags = set(config.manifest.coverage.get("excluded_tags", []))
    excluded_resources = {
        _normalize_coverage_resource_name(item)
        for item in config.manifest.coverage.get("excluded_resources", [])
    }
    resource_aliases = {
        _normalize_coverage_resource_name(resource): _normalize_coverage_resource_name(alias)
        for resource, alias in config.manifest.coverage.get("resource_aliases", {}).items()
    }
    expected_resources: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for path, path_payload in spec.get("paths", {}).items():
        if any(re.match(pattern, path) for pattern in excluded_paths):
            continue
        for method in HTTP_METHODS:
            if method not in path_payload:
                continue
            operation = path_payload[method]
            if excluded_tags and any(tag in excluded_tags for tag in operation.get("tags", [])):
                continue
            resource = _resource_name_for_path(path)
            if resource_filter is not None and resource not in resource_filter:
                continue
            if resource in excluded_resources:
                continue
            expected_resources[resource].append({"method": method.upper(), "path": path})

    implemented = {_normalize_coverage_resource_name(path.stem) for path in resources_dir.glob("**/*_resource.dart")}
    gaps = []
    for resource, endpoints in sorted(expected_resources.items()):
        implemented_name = resource_aliases.get(resource, resource)
        alternatives = {implemented_name, implemented_name.rstrip("s"), f"{implemented_name}s"}
        if not alternatives & implemented:
            gaps.append({"resource": resource, "reason": "No matching resource file", "endpoints": endpoints})
    return gaps


def _resource_name_for_path(path: str) -> str:
    parts = _trim_path_prefixes(path.strip("/").split("/"))
    return _normalize_coverage_resource_name(parts[0]) if parts else "root"


def _changed_openapi_resources(diff: dict[str, Any]) -> set[str]:
    resources: set[str] = set()
    for endpoint in diff["endpoints"]["added"]:
        resources.add(_resource_name_for_path(endpoint["path"]))
    for endpoint in diff["endpoints"]["modified"]:
        resources.add(_resource_name_for_path(endpoint["endpoint"]["path"]))
    return resources


def _entries_for_spec(config: ToolkitConfig, spec_name: str) -> list[ManifestEntry]:
    return [entry for entry in config.manifest.types.values() if entry.spec == spec_name]


def _lookup_entries(config: ToolkitConfig, name: str, spec_name: str | None) -> list[ManifestEntry]:
    if name in config.manifest.types:
        entry = config.manifest.types[name]
        if not spec_name or entry.spec == spec_name:
            return [entry]

    entries = list(config.manifest.types.values())
    if spec_name:
        entries = [entry for entry in entries if entry.spec == spec_name]

    matches = [
        entry
        for entry in entries
        if entry.schema_name == name or entry.dart_class == name
    ]
    if len(matches) > 1 and not spec_name:
        candidates = ", ".join(sorted(entry.key for entry in matches))
        raise ToolkitError(
            f"Type '{name}' is ambiguous across specs. Use --spec-name or an exact manifest key. Candidates: {candidates}"
        )
    return matches


def _resolve_entry(config: ToolkitConfig, name: str, spec_name: str | None) -> ManifestEntry:
    matches = _lookup_entries(config, name, spec_name)
    if not matches:
        raise ToolkitError(f"Unknown type '{name}'")
    if len(matches) > 1:
        candidates = ", ".join(sorted(entry.key for entry in matches))
        raise ToolkitError(f"Type '{name}' is ambiguous. Candidates: {candidates}")
    return matches[0]


def _resolve_selected_spec_name(
    config: ToolkitConfig,
    requested_spec_name: str | None,
    *,
    type_name: str | None = None,
) -> str:
    if requested_spec_name:
        return config.get_spec(requested_spec_name)[0]
    if type_name:
        return _resolve_entry(config, type_name, None).spec
    return config.get_spec(None)[0]


def _manifest_keys_for_schema(config: ToolkitConfig, schema_name: str, spec_name: str) -> list[str]:
    return [
        entry.key
        for entry in _entries_for_spec(config, spec_name)
        if entry.schema_name == schema_name or entry.key == schema_name
    ]


def _changed_type_names(config: ToolkitConfig, diff: dict[str, Any]) -> list[str]:
    if config.manifest.surface == "openapi":
        names = [item["name"] for item in diff["schemas"]["added"]]
        names.extend(item["schema"]["name"] for item in diff["schemas"]["modified"])
        names.extend(item["name"] for item in diff["schemas"]["removed"])
        return sorted(set(names))
    names = []
    for group in ("client_messages", "server_messages", "config_types", "enums"):
        names.extend(diff[group]["added"])
        names.extend(item["name"] for item in diff[group]["modified"])
        names.extend(diff[group]["removed"])
    return sorted(set(names))


def _type_issue(level: str, name: str, message: str, *, file: str | None = None) -> dict[str, Any]:
    issue = {"level": level, "name": name, "message": message}
    if file:
        issue["file"] = file
    return issue


def _openapi_property_info(schema: dict[str, Any], schema_name: str) -> dict[str, dict[str, Any]]:
    all_schemas = schema.get("components", {}).get("schemas", {})
    if schema_name not in all_schemas:
        return {}
    raw = all_schemas[schema_name]
    results: dict[str, dict[str, Any]] = {}
    required = set(raw.get("required", []))
    for name, prop in raw.get("properties", {}).items():
        results[name] = _parse_openapi_property(prop, required, name)
    for item in raw.get("allOf", []):
        if "$ref" in item:
            ref_name = item["$ref"].split("/")[-1]
            results.update(_openapi_property_info(schema, ref_name))
        for name, prop in item.get("properties", {}).items():
            results[name] = _parse_openapi_property(prop, set(item.get("required", [])), name)
    return results


def _parse_openapi_property(prop: dict[str, Any], required: set[str], name: str) -> dict[str, Any]:
    info = {
        "required": name in required,
        "type": prop.get("type"),
        "ref": None,
        "items": prop.get("items"),
    }
    if "$ref" in prop:
        info["ref"] = prop["$ref"].split("/")[-1]
        return info
    if "anyOf" in prop:
        non_null = [item for item in prop["anyOf"] if item.get("type") != "null"]
        if any(item.get("type") == "null" for item in prop["anyOf"]):
            info["required"] = False
        if non_null:
            first = non_null[0]
            if "$ref" in first:
                info["ref"] = first["$ref"].split("/")[-1]
            else:
                info["type"] = first.get("type")
                info["items"] = first.get("items")
        return info
    if "allOf" in prop:
        for item in prop["allOf"]:
            if "$ref" in item:
                info["ref"] = item["$ref"].split("/")[-1]
                break
    return info


def _websocket_property_info(schema: dict[str, Any], entry: ManifestEntry) -> dict[str, dict[str, Any]]:
    type_name = entry.schema_name
    if entry.kind == "message_client":
        raw = schema.get("message_types", {}).get("client", {}).get(type_name, {})
        return raw.get("fields", {})
    if entry.kind == "message_server":
        raw = schema.get("message_types", {}).get("server", {}).get(type_name, {})
        return raw.get("fields", {})
    raw = schema.get("config_types", {}).get(type_name, {})
    return raw.get("fields", {})


def _select_entries(config: ToolkitConfig, spec_name: str, scope: str, type_name: str | None, diff: dict[str, Any] | None = None) -> tuple[list[ManifestEntry], list[dict[str, Any]]]:
    issues: list[dict[str, Any]] = []
    entries = _entries_for_spec(config, spec_name)
    if scope == "type":
        if not type_name:
            raise ToolkitError("--type-name is required when --scope type is used")
        return [_resolve_entry(config, type_name, spec_name)], issues
    if scope == "critical":
        return [entry for entry in entries if "critical" in entry.tags], issues
    if scope == "changed":
        changed = _changed_type_names(config, diff or {})
        selected: list[ManifestEntry] = []
        for name in changed:
            mapped = [entry for entry in entries if entry.schema_name == name or entry.key == name]
            if mapped:
                selected.extend(mapped)
            else:
                issues.append(_type_issue("error", name, "Changed type is missing a manifest entry"))
        return selected, issues
    return [entry for entry in entries if entry.kind != "skip"], issues


def _constant_getter_fields(class_block: str) -> set[str]:
    return set(re.findall(r"\bget\s+(\w+)\s*=>", class_block))


def _inherited_member_fields(class_block: str) -> set[str]:
    names = set(re.findall(r"\bsuper\.(\w+)\b", class_block))
    for match in re.finditer(r"\bsuper\s*\(([^)]*)\)", class_block, re.DOTALL):
        names.update(re.findall(r"(\w+)\s*:", match.group(1)))
    return names


def _check_field_methods(entry: ManifestEntry, file_path: Path, fields: set[str], constant_fields: set[str]) -> list[dict[str, Any]]:
    content = read_text(file_path)
    class_block = extract_class_block(content, entry.dart_class)
    issues: list[dict[str, Any]] = []
    required_methods = {"fromJson", "toJson", "copyWith"}
    methods = {
        "fromJson": extract_method_body(class_block, rf"factory\s+{re.escape(entry.dart_class)}\.fromJson"),
        "toJson": extract_method_body(class_block, r"Map<String,\s*dynamic>\s+toJson"),
        "copyWith": extract_method_body(class_block, r"\bcopyWith\s*\("),
        "operator ==": extract_method_body(class_block, r"operator\s*=="),
        "hashCode": extract_method_body(class_block, r"hashCode\s*=>"),
        "toString": extract_method_body(class_block, r"toString\s*\(\)"),
    }
    effective_fields = fields - constant_fields
    json_keys = {snake_case(field) for field in effective_fields} | effective_fields
    for method_name, body in methods.items():
        if not body:
            if method_name in required_methods:
                issues.append(
                    _type_issue(
                        "error",
                        entry.key,
                        f"Missing {method_name} implementation",
                        file=entry.file,
                    )
                )
            continue
        expected = effective_fields if method_name in {"copyWith", "operator ==", "hashCode", "toString"} else json_keys
        missing = contains_all_names(body, expected)
        if missing:
            issues.append(
                _type_issue(
                    "error" if method_name in required_methods else "warning",
                    entry.key,
                    f"{method_name} does not reference all expected fields: {', '.join(sorted(missing))}",
                    file=entry.file,
                )
            )
    return issues


def _verify_extension_entry(config: ToolkitConfig, entry: ManifestEntry) -> list[dict[str, Any]]:
    file_path = config.resolve_package_path(entry.file)
    if not file_path.exists():
        return [_type_issue("error", entry.key, f"Missing Dart file: {entry.file}", file=entry.file)]

    content = read_text(file_path)
    issues: list[dict[str, Any]] = []
    if entry.dart_class not in content:
        issues.append(
            _type_issue(
                "error",
                entry.key,
                f"Extension class '{entry.dart_class}' is not referenced in {entry.file}",
                file=entry.file,
            )
        )
    parent_names = _parent_reference_names(_entries_for_spec(config, entry.spec), entry.parent)
    if entry.parent and not any(parent_name in content for parent_name in parent_names):
        issues.append(
            _type_issue(
                "error",
                entry.key,
                f"Extension parent '{entry.parent}' is not referenced in {entry.file}",
                file=entry.file,
            )
        )
    return issues


def _verify_object_entry(config: ToolkitConfig, spec_payload: dict[str, Any], entry: ManifestEntry) -> list[dict[str, Any]]:
    if entry.kind == "extension" and not entry.schema:
        return _verify_extension_entry(config, entry)

    file_path = config.resolve_package_path(entry.file)
    if not file_path.exists():
        return [_type_issue("error", entry.key, f"Missing Dart file: {entry.file}", file=entry.file)]

    if config.manifest.surface == "openapi":
        props = _openapi_property_info(spec_payload, entry.schema_name)
    else:
        props = _websocket_property_info(spec_payload, entry)

    if not props:
        return [_type_issue("error", entry.key, f"No spec fields found for '{entry.schema_name}'", file=entry.file)]

    fields = extract_fields(file_path, entry.dart_class)
    content = read_text(file_path)
    class_block = extract_class_block(content, entry.dart_class)
    constant_fields = _constant_getter_fields(class_block)
    inherited_fields = _inherited_member_fields(class_block)
    issues: list[dict[str, Any]] = []
    expected_field_names: set[str] = set()
    for name, prop in props.items():
        if name in entry.excluded_properties:
            continue
        field_name = camel_case(name)
        expected_field_names.add(field_name)
        if field_name not in fields and field_name not in constant_fields and field_name not in inherited_fields:
            issues.append(_type_issue("error", entry.key, f"Missing property '{name}'", file=entry.file))
            continue
        dart_field = fields.get(field_name)
        required = bool(prop.get("required", False))
        if dart_field is not None:
            if required and dart_field.is_nullable:
                issues.append(_type_issue("error", entry.key, f"Property '{name}' is required in spec but nullable in Dart", file=entry.file))
            if not required and not dart_field.is_nullable and config.manifest.surface == "openapi":
                issues.append(_type_issue("info", entry.key, f"Property '{name}' is optional in spec but non-nullable in Dart", file=entry.file))

    issues.extend(_check_field_methods(entry, file_path, expected_field_names, constant_fields))
    return issues


def _verify_enum_entry(config: ToolkitConfig, spec_payload: dict[str, Any], entry: ManifestEntry) -> list[dict[str, Any]]:
    file_path = config.resolve_package_path(entry.file)
    if not file_path.exists():
        return [_type_issue("error", entry.key, f"Missing Dart enum file: {entry.file}", file=entry.file)]

    content = read_text(file_path)
    if "enum " not in content:
        return [_type_issue("error", entry.key, "Expected enum declaration", file=entry.file)]

    values: list[str]
    if config.manifest.surface == "openapi":
        values = _extract_openapi_schemas(spec_payload).get(entry.schema_name, {}).get("enum_values", [])
    else:
        values = spec_payload.get("enums", {}).get(entry.schema_name, {}).get("values", [])

    issues: list[dict[str, Any]] = []
    if not values:
        issues.append(_type_issue("error", entry.key, f"No enum values found in spec for '{entry.schema_name}'", file=entry.file))
    for value in values:
        if value not in content:
            issues.append(_type_issue("error", entry.key, f"Enum string value '{value}' not found in file", file=entry.file))
    if not any(fallback in content for fallback in UNKNOWN_ENUM_FALLBACKS):
        issues.append(_type_issue("error", entry.key, "Enum fallback value ('unknown' or 'unspecified') not found", file=entry.file))
    return issues


def _discriminator_value_for_variant(mapping: dict[str, Any], variant: ManifestEntry) -> str | None:
    for key in (variant.schema_name, variant.dart_class):
        value = mapping.get(key)
        if isinstance(value, str):
            return value

    for discriminator_value, target in mapping.items():
        if not isinstance(discriminator_value, str) or not isinstance(target, str):
            continue
        target_name = target.split("/")[-1]
        if target_name in {variant.schema_name, variant.dart_class}:
            return discriminator_value

    return None


def _verify_sealed_parent(config: ToolkitConfig, entry: ManifestEntry, variants: list[ManifestEntry]) -> list[dict[str, Any]]:
    file_path = config.resolve_package_path(entry.file)
    if not file_path.exists():
        return [_type_issue("error", entry.key, f"Missing sealed parent file: {entry.file}", file=entry.file)]
    content = read_text(file_path)
    issues: list[dict[str, Any]] = []
    mapping = (entry.discriminator or {}).get("mapping", {}) if entry.discriminator else {}
    for variant in variants:
        if variant.dart_class not in content:
            issues.append(_type_issue("error", entry.key, f"Parent does not reference variant '{variant.dart_class}'", file=entry.file))
        discriminator_value = _discriminator_value_for_variant(mapping, variant)
        if discriminator_value and discriminator_value not in content:
            issues.append(_type_issue("error", entry.key, f"Parent does not reference discriminator value '{discriminator_value}'", file=entry.file))
    return issues


def _sealed_parent_reference_map(entries_for_spec: list[ManifestEntry]) -> dict[str, ManifestEntry]:
    references: dict[str, ManifestEntry] = {}
    for entry in entries_for_spec:
        if entry.kind != "sealed_parent":
            continue
        references[entry.key] = entry
        references[entry.dart_class] = entry
    return references


def _parent_reference_names(entries_for_spec: list[ManifestEntry], parent_name: str | None) -> set[str]:
    if not parent_name:
        return set()
    names = {parent_name}
    for candidate in entries_for_spec:
        if parent_name in {candidate.key, candidate.dart_class}:
            names.add(candidate.key)
            names.add(candidate.dart_class)
    return {name for name in names if name}


def _sealed_parents_to_verify(selected: list[ManifestEntry], entries_for_spec: list[ManifestEntry]) -> list[ManifestEntry]:
    parent_references = _sealed_parent_reference_map(entries_for_spec)
    parents: dict[str, ManifestEntry] = {}
    for entry in selected:
        if entry.kind == "sealed_parent":
            parents[entry.key] = entry
        elif entry.parent and entry.parent in parent_references:
            parent = parent_references[entry.parent]
            parents[parent.key] = parent
    return list(parents.values())


def _implementation_coverage_summary(entries_for_spec: list[ManifestEntry], selected: list[ManifestEntry]) -> dict[str, Any]:
    skipped_keys = sorted(entry.key for entry in entries_for_spec if entry.kind == "skip")
    return {
        "partial_coverage": bool(skipped_keys),
        "manifest_entry_count": len(entries_for_spec),
        "selected_entry_count": len(selected),
        "skipped_entry_count": len(skipped_keys),
        "skipped_keys": skipped_keys,
    }


def _verify_implementation(
    config: ToolkitConfig,
    spec_name: str,
    scope: str,
    type_name: str | None,
    baseline: Path | None,
    git_ref: str | None,
    *,
    spec_payload: dict[str, Any] | None = None,
    diff: dict[str, Any] | None = None,
) -> tuple[int, dict[str, Any]]:
    if scope == "changed":
        if diff is None or spec_payload is None:
            old_spec, new_spec = _load_old_new_payloads(config, spec_name, baseline=baseline, git_ref=git_ref)
            if diff is None:
                diff = _compare_openapi(old_spec, new_spec) if config.manifest.surface == "openapi" else _compare_websocket(old_spec, new_spec)
            if spec_payload is None:
                spec_payload = new_spec
    else:
        if spec_payload is None:
            spec_payload = _load_spec_payload(config.canonical_spec_path(spec_name))
        diff = None

    selected, selection_issues = _select_entries(config, spec_name, scope, type_name, diff)
    issues = list(selection_issues)
    entries_for_spec = _entries_for_spec(config, spec_name)
    coverage_summary = _implementation_coverage_summary(entries_for_spec, selected)
    if scope == "all" and coverage_summary["partial_coverage"]:
        issues.append(
            _type_issue(
                "warning",
                "implementation",
                f"Strict implementation verification is partial because {coverage_summary['skipped_entry_count']} manifest entries are marked as kind='skip'",
            )
        )
    parents = _sealed_parents_to_verify(selected, entries_for_spec)
    parent_references = _sealed_parent_reference_map(entries_for_spec)
    by_parent: dict[str, list[ManifestEntry]] = defaultdict(list)
    parent_keys = {parent.key for parent in parents}
    for entry in entries_for_spec:
        if not entry.parent:
            continue
        parent = parent_references.get(entry.parent)
        if parent and parent.key in parent_keys and entry.key != parent.key:
            by_parent[parent.key].append(entry)

    for entry in selected:
        if entry.kind == "skip":
            continue
        if entry.kind == "enum":
            issues.extend(_verify_enum_entry(config, spec_payload, entry))
        elif entry.kind == "sealed_parent":
            continue
        elif entry.kind == "extension" and not entry.schema:
            issues.extend(_verify_extension_entry(config, entry))
        else:
            issues.extend(_verify_object_entry(config, spec_payload, entry))

    for parent in parents:
        issues.extend(_verify_sealed_parent(config, parent, by_parent.get(parent.key, [])))

    coverage_gaps = []
    if config.manifest.surface == "openapi" and scope in {"changed", "all"}:
        resource_filter = _changed_openapi_resources(diff) if scope == "changed" else None
        coverage_gaps = _coverage_gaps(config, spec_payload, resource_filter=resource_filter)
        for gap in coverage_gaps:
            issues.append(_type_issue("error", gap["resource"], gap["reason"]))

    exit_code = EXIT_SUCCESS
    if any(issue["level"] == "error" for issue in issues):
        exit_code = EXIT_FAILURE

    payload = {
        "command": "verify",
        "check": "implementation",
        "scope": scope,
        "selected_types": [entry.key for entry in selected],
        "coverage_gaps": coverage_gaps,
        "coverage_summary": coverage_summary,
        "issues": issues,
        "summary": {
            "errors": sum(1 for issue in issues if issue["level"] == "error"),
            "warnings": sum(1 for issue in issues if issue["level"] == "warning"),
            "infos": sum(1 for issue in issues if issue["level"] == "info"),
        },
    }
    return exit_code, payload


def _discover_barrel_files(config: ToolkitConfig) -> list[Path]:
    if config.package.barrel_files:
        return [config.resolve_package_path(path) for path in config.package.barrel_files]
    lib_dir = config.package_root / "lib"
    discovered = [path for path in sorted(lib_dir.glob("*.dart")) if not path.name.startswith("_")]
    if discovered:
        return discovered
    return [config.resolve_package_path(config.package.barrel_file)]


def _parse_exports(path: Path, visited: set[Path] | None = None) -> set[Path]:
    visited = visited or set()
    resolved_path = path.resolve()
    if resolved_path in visited:
        return set()
    visited.add(resolved_path)
    content = read_text(path)
    exported: set[Path] = set()
    for match in re.finditer(r"export\s+'([^']+\.dart)'", content):
        resolved = (path.parent / match.group(1)).resolve()
        exported.add(resolved)
        if resolved.exists():
            exported.update(_parse_exports(resolved, visited))
    return exported


def _verify_exports(config: ToolkitConfig) -> tuple[int, dict[str, Any]]:
    models_dir = config.package_root / (
        config.package.live_models_dir
        if config.manifest.surface == "websocket" and config.package.live_models_dir
        else config.package.models_dir
    )
    if not models_dir.exists():
        raise ToolkitError(f"Models directory not found: {models_dir}")
    model_files = []
    skip = set(config.package.skip_files) | set(config.package.internal_barrel_files)
    for path in models_dir.glob("**/*.dart"):
        if path.name in skip or any(part.startswith(".") for part in path.parts):
            continue
        head = "\n".join(read_text(path).splitlines()[:5])
        if PART_OF_RE.search(head):
            continue
        model_files.append(path.resolve())
    barrel_files = _discover_barrel_files(config)
    exported: set[Path] = set()
    for barrel in barrel_files:
        exported.update(_parse_exports(barrel))
    missing = [str(path.relative_to(config.package_root)) for path in model_files if path.resolve() not in exported]
    exit_code = EXIT_FAILURE if missing else EXIT_SUCCESS
    return exit_code, {
        "command": "verify",
        "check": "exports",
        "barrel_files": [str(path.relative_to(config.package_root)) for path in barrel_files],
        "missing_exports": missing,
        "summary": {"missing_export_count": len(missing)},
    }


def _append_removed_api_issues(
    issues: list[dict[str, Any]],
    text: str,
    label: str,
    removed_apis: list[dict[str, Any]],
) -> None:
    for line_number, line in enumerate(text.splitlines(), 1):
        for removed in removed_apis:
            api_name = removed.get("api")
            if api_name and api_name in line:
                issues.append(_type_issue("error", api_name, f"Removed API still referenced in {label}:{line_number}"))


def _append_drift_pattern_issues(
    issues: list[dict[str, Any]],
    text: str,
    label: str,
    drift_patterns: list[dict[str, Any]],
    *,
    code_blocks_only: bool,
) -> None:
    if code_blocks_only:
        in_dart = False
        block_start = 0
        current_block: list[str] = []
        for line_number, line in enumerate(text.splitlines(), 1):
            if line.strip() == "```dart":
                in_dart = True
                block_start = line_number
                current_block = []
                continue
            if line.strip() == "```" and in_dart:
                block_text = "\n".join(current_block)
                for pattern_info in drift_patterns:
                    pattern = pattern_info.get("pattern")
                    if not pattern:
                        continue
                    for match in re.finditer(pattern, block_text):
                        issue_line = block_start + block_text[: match.start()].count("\n")
                        issues.append(
                            _type_issue(
                                pattern_info.get("severity", "warning"),
                                pattern,
                                f"{pattern_info.get('message', 'Documentation drift detected')} ({label}:{issue_line})",
                            )
                        )
                in_dart = False
                continue
            if in_dart:
                current_block.append(line)
        return

    for pattern_info in drift_patterns:
        pattern = pattern_info.get("pattern")
        if not pattern:
            continue
        for match in re.finditer(pattern, text):
            issue_line = 1 + text[: match.start()].count("\n")
            issues.append(
                _type_issue(
                    pattern_info.get("severity", "warning"),
                    pattern,
                    f"{pattern_info.get('message', 'Documentation drift detected')} ({label}:{issue_line})",
                )
            )


def _example_files(config: ToolkitConfig) -> dict[str, Path]:
    examples_dir = config.package_root / config.package.examples_dir
    if not examples_dir.exists():
        return {}
    return {
        _normalize_example_name(path.stem): path
        for path in examples_dir.glob("*_example.dart")
    }


def _verify_tool_properties(config: ToolkitConfig, readme: str) -> list[dict[str, Any]]:
    issues: list[dict[str, Any]] = []
    readme_lower = readme.lower()
    for property_name, details in sorted(config.documentation.tool_properties.items()):
        search_terms = [term.lower() for term in details.get("search_terms", []) if term]
        if not search_terms:
            search_terms = [property_name.lower()]
        if any(term in readme_lower for term in search_terms):
            continue
        description = details.get("description") or property_name
        issues.append(
            _type_issue(
                "error",
                property_name,
                f"README is missing tool documentation for {description}",
            )
        )
    return issues


def _docs_coverage_summary(config: ToolkitConfig) -> dict[str, Any]:
    discovered_resources = _discover_openapi_doc_resources(config)
    excluded_resources = sorted(set(config.documentation.excluded_resources))
    excluded_from_examples = sorted(set(config.documentation.excluded_from_examples))
    normalized_excluded_resources = {_normalize_resource_name(item) for item in excluded_resources}
    verified_resources = [
        resource for resource in discovered_resources if resource.resource_key not in normalized_excluded_resources
    ]
    return {
        "partial_coverage": bool(excluded_resources or excluded_from_examples),
        "discovered_resource_count": len(discovered_resources),
        "verified_resource_count": len(verified_resources),
        "excluded_resources": excluded_resources,
        "excluded_from_examples": excluded_from_examples,
    }


def _verify_openapi_docs(config: ToolkitConfig, readme: str) -> list[dict[str, Any]]:
    issues = _verify_tool_properties(config, readme)
    discovered_resources = _discover_openapi_doc_resources(config)
    excluded_resources = {_normalize_resource_name(item) for item in config.documentation.excluded_resources}
    excluded_from_examples = {_normalize_resource_name(item) for item in config.documentation.excluded_from_examples}
    resource_to_example = {
        _normalize_resource_name(resource): _normalize_example_name(example)
        for resource, example in config.documentation.resource_to_example.items()
    }

    implemented_resources = [
        resource
        for resource in discovered_resources
        if resource.resource_key not in excluded_resources
    ]
    implemented_resource_keys = {resource.resource_key for resource in implemented_resources}
    implemented_access_paths = {
        resource.access_path.lower()
        for resource in implemented_resources
    }
    excluded_access_paths = {
        resource.access_path.lower()
        for resource in discovered_resources
        if resource.resource_key in excluded_resources
    }
    # Include raw exclusion names so non-API references (e.g. client.close())
    # are also suppressed in the README stale-reference check.
    excluded_access_paths |= {name.lower() for name in config.documentation.excluded_resources}
    readme_lower = readme.lower()
    documented_resources = {
        resource.resource_key
        for resource in implemented_resources
        if f"client.{resource.access_path.lower()}" in readme_lower
    }
    missing_resources = sorted(implemented_resource_keys - documented_resources)
    for resource in missing_resources:
        issues.append(_type_issue("error", resource, "Implemented resource is missing from README"))

    mentioned_resources: set[str] = set()
    known_access_paths = implemented_access_paths | excluded_access_paths
    for match in re.finditer(r"client\.([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)", readme_lower):
        segments = match.group(1).split(".")
        prefixes = [".".join(segments[: index + 1]) for index in range(len(segments))]
        matched_prefix = False
        for prefix in prefixes:
            if prefix in known_access_paths:
                mentioned_resources.add(prefix)
                matched_prefix = True
        if not matched_prefix and segments:
            mentioned_resources.add(segments[0])

    stale_resources = sorted(
        mentioned_resources - implemented_access_paths - excluded_access_paths
    )
    for resource in stale_resources:
        issues.append(_type_issue("warning", resource, "README references a resource that is not implemented"))

    example_files = set(_example_files(config))
    for resource in sorted(
        (
            resource
            for resource in implemented_resources
            if resource.resource_key not in excluded_from_examples
        ),
        key=lambda item: item.resource_key,
    ):
        mapped = resource_to_example.get(resource.resource_key, resource.example_key)
        if mapped not in example_files:
            issues.append(
                _type_issue(
                    "error",
                    resource.resource_key,
                    f"Missing example file for resource '{resource.resource_key}'",
                )
            )

    return issues


def _verify_websocket_docs(config: ToolkitConfig, readme: str) -> list[dict[str, Any]]:
    issues: list[dict[str, Any]] = []
    readme_lower = readme.lower()
    example_files = _example_files(config)
    live_example_name = config.documentation.resource_to_example.get("live", "live")
    live_example_path = example_files.get(live_example_name)
    live_example_text = read_text(live_example_path).lower() if live_example_path and live_example_path.exists() else ""

    for feature_name, details in sorted(config.documentation.live_features.items()):
        search_terms = [term.lower() for term in details.get("search_terms", []) if term]
        if not search_terms:
            search_terms = [feature_name.lower()]
        if not any(term in readme_lower for term in search_terms):
            issues.append(_type_issue("error", feature_name, "Live feature is missing from README"))
        if not live_example_text:
            issues.append(_type_issue("error", feature_name, f"Missing example file for feature '{feature_name}'"))
        elif not any(term in live_example_text for term in search_terms):
            issues.append(_type_issue("error", feature_name, "Live feature is missing from websocket example"))

    return issues


def _verify_docs(config: ToolkitConfig) -> tuple[int, dict[str, Any]]:
    issues: list[dict[str, Any]] = []
    readme_path = config.package_root / "README.md"
    if not readme_path.exists():
        raise ToolkitError(f"README.md not found in {config.package_root}")
    readme = read_text(readme_path)
    coverage_summary = _docs_coverage_summary(config)
    if config.manifest.surface == "websocket":
        issues.extend(_verify_websocket_docs(config, readme))
    else:
        issues.extend(_verify_openapi_docs(config, readme))
    if coverage_summary["partial_coverage"]:
        issues.append(
            _type_issue(
                "warning",
                "documentation",
                "Documentation verification is partial because documentation.json excludes resources or example checks",
            )
        )

    _append_removed_api_issues(issues, readme, "README", config.documentation.removed_apis)
    _append_drift_pattern_issues(issues, readme, "README", config.documentation.drift_patterns, code_blocks_only=True)

    for example_name, example_path in sorted(_example_files(config).items()):
        text = read_text(example_path)
        label = str(example_path.relative_to(config.package_root))
        _append_removed_api_issues(issues, text, label, config.documentation.removed_apis)
        _append_drift_pattern_issues(issues, text, label, config.documentation.drift_patterns, code_blocks_only=False)

    exit_code = EXIT_FAILURE if any(issue["level"] == "error" for issue in issues) else EXIT_SUCCESS
    return exit_code, {
        "command": "verify",
        "check": "docs",
        "coverage_summary": coverage_summary,
        "issues": issues,
        "summary": {
            "errors": sum(1 for issue in issues if issue["level"] == "error"),
            "warnings": sum(1 for issue in issues if issue["level"] == "warning"),
        },
    }


class _ReferenceUnavailableError(RuntimeError):
    pass


def _audit_issue(check: str, level: str, name: str, message: str, *, file: str | None = None) -> dict[str, Any]:
    issue = _type_issue(level, name, message, file=file)
    issue["check"] = check
    return issue


def _iter_schema_refs(node: Any) -> set[str]:
    refs: set[str] = set()
    if isinstance(node, dict):
        ref = node.get("$ref")
        if isinstance(ref, str):
            refs.add(ref.split("/")[-1])
        discriminator = node.get("discriminator", {})
        if isinstance(discriminator, dict):
            mapping = discriminator.get("mapping", {})
            if isinstance(mapping, dict):
                for target in mapping.values():
                    if isinstance(target, str):
                        refs.add(target.split("/")[-1])
        for value in node.values():
            refs.update(_iter_schema_refs(value))
    elif isinstance(node, list):
        for item in node:
            refs.update(_iter_schema_refs(item))
    return refs


def _iter_content_schema_refs(content: Any) -> set[str]:
    refs: set[str] = set()
    if not isinstance(content, dict):
        return refs
    for media in content.values():
        if not isinstance(media, dict):
            continue
        refs.update(_iter_schema_refs(media.get("schema")))
    return refs


def _iter_request_schema_refs(request_body: Any) -> set[str]:
    if not isinstance(request_body, dict):
        return set()
    return _iter_content_schema_refs(request_body.get("content", {}))


def _iter_response_schema_refs(responses: Any) -> set[str]:
    refs: set[str] = set()
    if not isinstance(responses, dict):
        return refs
    for status, response in responses.items():
        if not str(status).startswith("2") and status != "default":
            continue
        if not isinstance(response, dict):
            continue
        refs.update(_iter_content_schema_refs(response.get("content", {})))
    return refs


def _iter_parameter_schema_refs(
    parameters: Any,
    spec_payload: dict[str, Any],
    *,
    resolving_parameters: tuple[str, ...] = (),
) -> set[str]:
    refs: set[str] = set()
    if not isinstance(parameters, list):
        return refs
    component_parameters = spec_payload.get("components", {}).get("parameters", {})
    for parameter in parameters:
        if not isinstance(parameter, dict):
            continue
        ref = parameter.get("$ref")
        if isinstance(ref, str):
            if ref.startswith("#/components/parameters/"):
                parameter_name = ref.split("/")[-1]
                if parameter_name in resolving_parameters:
                    continue
                refs.update(
                    _iter_parameter_schema_refs(
                        [component_parameters.get(parameter_name)],
                        spec_payload,
                        resolving_parameters=(*resolving_parameters, parameter_name),
                    )
                )
                continue
            refs.update(_iter_schema_refs(parameter))
            continue
        refs.update(_iter_schema_refs(parameter.get("schema")))
        refs.update(_iter_content_schema_refs(parameter.get("content", {})))
    return refs


def _included_schema_names(
    config: ToolkitConfig,
    spec_name: str,
    spec_payload: dict[str, Any],
    *,
    include_excluded: bool,
) -> list[str]:
    spec = config.specs[spec_name]
    excluded_paths = config.manifest.coverage.get("excluded_paths", [])
    excluded_tags = set(config.manifest.coverage.get("excluded_tags", []))
    root_schemas: set[str] = set()
    for path, path_payload in spec_payload.get("paths", {}).items():
        if not isinstance(path_payload, dict):
            continue
        for method in HTTP_METHODS:
            operation = path_payload.get(method)
            if not isinstance(operation, dict):
                continue
            if not include_excluded:
                if any(re.match(pattern, path) for pattern in excluded_paths):
                    continue
                if excluded_tags and any(tag in excluded_tags for tag in operation.get("tags", [])):
                    continue
            root_schemas.update(_iter_parameter_schema_refs(path_payload.get("parameters"), spec_payload))
            root_schemas.update(_iter_parameter_schema_refs(operation.get("parameters"), spec_payload))
            root_schemas.update(_iter_request_schema_refs(operation.get("requestBody")))
            root_schemas.update(_iter_response_schema_refs(operation.get("responses", {})))

    all_schemas = spec_payload.get("components", {}).get("schemas", {})
    pending = list(root_schemas)
    included: set[str] = set()
    while pending:
        current = pending.pop()
        if current in included or current not in all_schemas:
            continue
        included.add(current)
        pending.extend(sorted(_iter_schema_refs(all_schemas[current]) - included))

    excluded_schemas = set(spec.audit.excluded_schemas)
    return sorted(name for name in included if name not in excluded_schemas)


def _dart_models_root(config: ToolkitConfig) -> Path:
    return config.package_root / config.package.models_dir


def _dart_class_index(config: ToolkitConfig) -> dict[str, list[Path]]:
    models_dir = _dart_models_root(config)
    if not models_dir.exists():
        return {}
    skip_names = set(config.package.skip_files)
    index: dict[str, list[Path]] = defaultdict(list)
    for path in sorted(models_dir.rglob("*.dart")):
        if path.name in skip_names or any(part.startswith(".") for part in path.parts):
            continue
        for class_name in find_declared_classes(path):
            index[class_name].append(path)
    return {key: value for key, value in index.items()}


def _resolve_audit_class_matches(
    class_index: dict[str, list[Path]],
    class_name: str,
) -> list[tuple[str, Path]]:
    return [(class_name, path) for path in class_index.get(class_name, [])]


def _schema_manifest_match(config: ToolkitConfig, spec_name: str, schema_name: str) -> ManifestEntry | None:
    candidates = [entry for entry in _entries_for_spec(config, spec_name) if entry.schema_name == schema_name or entry.key == schema_name]
    if not candidates:
        return None
    exact_key = [entry for entry in candidates if entry.key == schema_name]
    if exact_key:
        return sorted(exact_key, key=lambda item: item.key)[0]
    exact_schema = [entry for entry in candidates if entry.schema_name == schema_name]
    if exact_schema:
        return sorted(exact_schema, key=lambda item: item.key)[0]
    return sorted(candidates, key=lambda item: item.key)[0]


def _resolve_schema_alias_match(
    config: ToolkitConfig,
    spec_name: str,
    alias_target: str,
    class_index: dict[str, list[Path]],
) -> tuple[str, ManifestEntry | None, str | None, Path | None, str | None]:
    manifest_matches = _lookup_entries(config, alias_target, spec_name)
    if len(manifest_matches) == 1:
        entry = manifest_matches[0]
        return "matched", entry, entry.dart_class, config.resolve_package_path(entry.file), "schema_alias"
    if len(manifest_matches) > 1:
        return "ambiguous", None, None, None, "schema_alias"
    class_matches = _resolve_audit_class_matches(class_index, alias_target)
    if len(class_matches) == 1:
        class_name, file_path = class_matches[0]
        return "matched", None, class_name, file_path, "schema_alias"
    if len(class_matches) > 1:
        return "ambiguous", None, None, None, "schema_alias"
    return "unmatched", None, None, None, None


def _heuristic_schema_match(
    schema_name: str,
    class_index: dict[str, list[Path]],
) -> tuple[str, str | None, Path | None, str | None]:
    candidates: list[tuple[str, str]] = [("exact_class", schema_name)]
    if schema_name.endswith("Object") and len(schema_name) > len("Object"):
        candidates.append(("strip_object_suffix", schema_name[: -len("Object")]))
    if schema_name.startswith("Create") and schema_name.endswith("Request") and len(schema_name) > len("CreateRequest"):
        candidates.append(("create_request_transform", schema_name[len("Create") :]))
    if schema_name.startswith("Create") and schema_name.endswith("Response") and len(schema_name) > len("CreateResponse"):
        candidates.append(("create_response_transform", schema_name[len("Create") :]))

    for source, class_name in candidates:
        matches = _resolve_audit_class_matches(class_index, class_name)
        if not matches:
            continue
        if len(matches) == 1:
            resolved_name, file_path = matches[0]
            return "matched", resolved_name, file_path, source
        return "ambiguous", None, None, source
    return "unmatched", None, None, None


def _schema_property_coverage(
    config: ToolkitConfig,
    file_path: Path,
    class_name: str,
    schema_name: str,
    spec_payload: dict[str, Any],
) -> dict[str, Any]:
    if not file_path.exists():
        return {
            "covered_properties": [],
            "missing_properties": sorted(_openapi_property_info(spec_payload, schema_name)),
            "from_json_keys": [],
            "declared_fields": [],
        }

    content = read_text(file_path)
    class_block = extract_class_block(content, class_name)
    fields = extract_fields(file_path, class_name)
    constant_fields = _constant_getter_fields(class_block)
    inherited_fields = _inherited_member_fields(class_block)
    from_json_keys = extract_from_json_keys(content, class_name)
    properties = _openapi_property_info(spec_payload, schema_name)
    covered: list[str] = []
    missing: list[str] = []
    for property_name in sorted(properties):
        field_name = camel_case(property_name)
        if (
            field_name in fields
            or property_name in fields
            or field_name in constant_fields
            or property_name in constant_fields
            or field_name in inherited_fields
            or property_name in inherited_fields
            or property_name in from_json_keys
        ):
            covered.append(property_name)
        else:
            missing.append(property_name)
    return {
        "covered_properties": covered,
        "missing_properties": missing,
        "from_json_keys": sorted(from_json_keys),
        "declared_fields": sorted(set(fields) | constant_fields | inherited_fields),
    }


def _normalize_audit_scope(scope: str, status: str) -> bool:
    if scope == "all":
        return True
    if scope == "matched":
        return status == "matched"
    return status != "matched"


def _python_module(path: Path) -> ast.Module:
    try:
        return ast.parse(path.read_text(), filename=str(path))
    except (OSError, UnicodeError, SyntaxError) as exc:
        raise ToolkitError(f"Failed to load Python module from path '{path}': {exc}") from exc


def _python_decorator_name(node: ast.AST) -> str | None:
    if isinstance(node, ast.Name):
        return node.id
    if isinstance(node, ast.Attribute):
        return node.attr
    if isinstance(node, ast.Call):
        return _python_decorator_name(node.func)
    return None


def _python_method_defs(node: ast.ClassDef) -> list[ast.FunctionDef | ast.AsyncFunctionDef]:
    return [
        item
        for item in node.body
        if isinstance(item, (ast.FunctionDef, ast.AsyncFunctionDef))
    ]


def _python_public_methods_from_class(node: ast.ClassDef) -> set[str]:
    methods: set[str] = set()
    for function in _python_method_defs(node):
        if function.name.startswith("_") or function.name == "__init__":
            continue
        decorator_names = {_python_decorator_name(decorator) for decorator in function.decorator_list}
        if decorator_names & {"property", "cached_property", "classmethod", "staticmethod"}:
            continue
        methods.add(function.name)
    return methods


def _python_top_level_classes(path: Path) -> dict[str, ast.ClassDef]:
    return {
        item.name: item
        for item in _python_module(path).body
        if isinstance(item, ast.ClassDef)
    }


def _python_class_index(root: Path) -> dict[str, list[Path]]:
    index: dict[str, list[Path]] = defaultdict(list)
    for path in sorted(root.rglob("*.py")):
        if any(part.startswith(".") for part in path.parts):
            continue
        try:
            classes = _python_top_level_classes(path)
        except (SyntaxError, ToolkitError):
            continue
        for class_name in classes:
            index[class_name].append(path)
    return {key: value for key, value in index.items()}


def _python_name_from_expr(node: ast.AST | None) -> str | None:
    if node is None:
        return None
    if isinstance(node, ast.Name):
        return node.id
    if isinstance(node, ast.Attribute):
        return node.attr
    if isinstance(node, ast.Constant) and isinstance(node.value, str):
        return node.value
    if isinstance(node, ast.Subscript):
        return _python_name_from_expr(node.value)
    return None


def _python_property_members(node: ast.ClassDef) -> dict[str, str | None]:
    members: dict[str, str | None] = {}
    for function in _python_method_defs(node):
        decorator_names = {_python_decorator_name(decorator) for decorator in function.decorator_list}
        if function.name.startswith("_") or not (decorator_names & {"property", "cached_property"}):
            continue
        inferred = _python_name_from_expr(function.returns)
        if inferred is None:
            for child in ast.walk(function):
                if isinstance(child, ast.Return):
                    if isinstance(child.value, ast.Call):
                        inferred = _python_name_from_expr(child.value.func)
                        break
                    inferred = _python_name_from_expr(child.value)
                    if inferred:
                        break
        members[function.name] = inferred
    return members


def _python_init_members(node: ast.ClassDef) -> dict[str, str | None]:
    members: dict[str, str | None] = {}
    init_function = next((item for item in _python_method_defs(node) if item.name == "__init__"), None)
    if init_function is None:
        return members
    for child in ast.walk(init_function):
        if not isinstance(child, ast.Assign):
            continue
        for target in child.targets:
            if isinstance(target, ast.Attribute) and isinstance(target.value, ast.Name) and target.value.id == "self":
                class_name = _python_name_from_expr(child.value.func) if isinstance(child.value, ast.Call) else _python_name_from_expr(child.value)
                members[target.attr] = class_name
    return members


def _python_member_map(node: ast.ClassDef, member_map_name: str | None) -> dict[str, str | None]:
    if not member_map_name:
        return {}
    for item in node.body:
        if not isinstance(item, ast.Assign):
            continue
        for target in item.targets:
            if isinstance(target, ast.Name) and target.id == member_map_name and isinstance(item.value, ast.Dict):
                mapping: dict[str, str | None] = {}
                for key, value in zip(item.value.keys, item.value.values):
                    key_name = _python_name_from_expr(key)
                    value_name = _python_name_from_expr(value)
                    if key_name:
                        mapping[key_name] = value_name
                return mapping
    return {}


def _download_reference_repo(repo: str, ref: str) -> tuple[Path, Path]:
    url = f"https://codeload.github.com/{repo}/tar.gz/{ref}"
    request = Request(url, headers={"User-Agent": "api-toolkit/1.0"})
    temp_root = Path(tempfile.mkdtemp(prefix="api-toolkit-audit-"))
    archive_path = temp_root / "reference.tar.gz"
    try:
        with urlopen(request, timeout=30) as response, archive_path.open("wb") as archive_file:
            shutil.copyfileobj(response, archive_file)
        with tarfile.open(archive_path, mode="r:gz") as tar:
            _extract_tar_safely(tar, temp_root)
    except _ReferenceUnavailableError:
        shutil.rmtree(temp_root, ignore_errors=True)
        raise
    except (HTTPError, URLError, OSError, tarfile.TarError) as exc:
        shutil.rmtree(temp_root, ignore_errors=True)
        raise _ReferenceUnavailableError(f"Failed to download reference implementation {repo}@{ref}: {exc}") from exc
    finally:
        archive_path.unlink(missing_ok=True)
    extracted = next((path for path in temp_root.iterdir() if path.is_dir()), temp_root)
    return extracted, temp_root


def _extract_tar_safely(tar: tarfile.TarFile, destination: Path) -> None:
    destination = destination.resolve()
    members = tar.getmembers()
    for member in members:
        member_path = (destination / member.name).resolve()
        try:
            member_path.relative_to(destination)
        except ValueError as exc:
            raise _ReferenceUnavailableError(
                f"Archive member '{member.name}' would extract outside '{destination}'"
            ) from exc
    if "filter" in inspect.signature(tar.extractall).parameters:
        tar.extractall(destination, filter="data")
    else:  # pragma: no cover - older Python fallback
        # Emulate filter="data" by excluding symlinks, hardlinks, and device files.
        safe_members = [
            m
            for m in members
            if not (m.issym() or m.islnk() or m.isdev())
        ]
        tar.extractall(destination, members=safe_members)


def _reference_symbol_path(root: Path, relative: str) -> Path:
    root_resolved = root.resolve()
    resolved = (root_resolved / relative).resolve()
    try:
        resolved.relative_to(root_resolved)
    except ValueError as exc:
        raise ToolkitError(
            f"Configured reference implementation path '{relative}' escapes "
            f"the reference root '{root_resolved}'"
        ) from exc
    return resolved


def _apply_symbol_filters(values: set[str], config: ReferenceSymbolConfig) -> set[str]:
    filtered = set(values)
    if config.include:
        filtered &= set(config.include)
    if config.exclude:
        filtered -= set(config.exclude)
    return filtered


def _apply_symbol_aliases(values: set[str], aliases: dict[str, str]) -> set[str]:
    return {aliases.get(value, value) for value in values}


def _normalize_reference_resource(name: str) -> str:
    return _normalize_coverage_resource_name(name)


def _normalize_reference_method(name: str) -> str:
    return snake_case(name)


def _reference_resource_name_from_path(base: Path, path: Path, aliases: dict[str, str]) -> str:
    relative_parts = list(path.relative_to(base).with_suffix("").parts)
    if base.name != "resources" and relative_parts and relative_parts[0] != base.name:
        relative_parts = [base.name, *relative_parts]
    collapsed_parts: list[str] = []
    for part in relative_parts:
        if collapsed_parts and collapsed_parts[-1] == part:
            continue
        collapsed_parts.append(part)
    raw_name = "_".join(collapsed_parts)
    alias_target = aliases.get(raw_name, aliases.get(path.stem, raw_name))
    return _normalize_reference_resource(alias_target)


def _reference_types_from_init_exports(root: Path, config: ReferenceSymbolConfig) -> set[str]:
    path = _reference_symbol_path(root, config.path or "")
    module = _python_module(path)
    exported = set()
    explicit_all: set[str] | None = None
    for node in module.body:
        if isinstance(node, ast.ImportFrom):
            for alias in node.names:
                if alias.name != "*" and not alias.name.startswith("_"):
                    exported.add(alias.asname or alias.name)
        elif isinstance(node, ast.Assign):
            for target in node.targets:
                if isinstance(target, ast.Name) and target.id == "__all__" and isinstance(node.value, (ast.List, ast.Tuple)):
                    explicit_all = {
                        item.value
                        for item in node.value.elts
                        if isinstance(item, ast.Constant) and isinstance(item.value, str)
                    }
    if explicit_all is not None:
        exported = (exported & explicit_all) if exported else explicit_all
    exported = _apply_symbol_filters(exported, config)
    return _apply_symbol_aliases(exported, config.aliases)


def _reference_types_from_single_file(root: Path, config: ReferenceSymbolConfig) -> set[str]:
    values: set[str] = set()
    for relative in config.all_paths:
        path = _reference_symbol_path(root, relative)
        values.update(name for name in _python_top_level_classes(path) if not name.startswith("_"))
    values = _apply_symbol_filters(values, config)
    return _apply_symbol_aliases(values, config.aliases)


def _reference_types_from_recursive_paths(root: Path, config: ReferenceSymbolConfig) -> set[str]:
    values: set[str] = set()
    for relative in config.all_paths:
        base = _reference_symbol_path(root, relative)
        for path in sorted(base.rglob("*.py")):
            if path.name == "__init__.py":
                continue
            values.update(name for name in _python_top_level_classes(path) if not name.startswith("_"))
    values = _apply_symbol_filters(values, config)
    return _apply_symbol_aliases(values, config.aliases)


def _python_methods_for_class(
    class_index: dict[str, list[Path]],
    class_name: str | None,
) -> tuple[set[str], str | None]:
    if not class_name:
        return set(), "Reference class could not be inferred"
    paths = class_index.get(class_name, [])
    if not paths:
        return set(), f"Reference class '{class_name}' was not found"
    if len(paths) > 1:
        return set(), f"Reference class '{class_name}' is ambiguous across multiple files"
    methods = _python_public_methods_from_class(_python_top_level_classes(paths[0])[class_name])
    return {_normalize_reference_method(method) for method in methods}, None


def _reference_resources_from_stainless(
    root: Path,
    config: ReferenceSymbolConfig,
) -> tuple[dict[str, set[str]], list[dict[str, Any]]]:
    resources: dict[str, set[str]] = {}
    issues: list[dict[str, Any]] = []
    base = _reference_symbol_path(root, config.path or "")
    for path in sorted(base.rglob("*.py")):
        if path.name == "__init__.py" or path.name.startswith("_"):
            continue
        classes = _python_top_level_classes(path)
        resource_methods: set[str] = set()
        for class_name, node in classes.items():
            base_names = {_python_name_from_expr(base_node) for base_node in node.bases}
            if not (base_names & {"SyncAPIResource", "AsyncAPIResource", "SyncPage", "AsyncPage"}):
                continue
            resource_methods.update(_normalize_reference_method(method) for method in _python_public_methods_from_class(node))
        if not resource_methods:
            continue
        resource_name = _reference_resource_name_from_path(base, path, config.aliases)
        if config.include and resource_name not in {_normalize_reference_resource(item) for item in config.include}:
            continue
        if resource_name in {_normalize_reference_resource(item) for item in config.exclude}:
            continue
        resources.setdefault(resource_name, set()).update(resource_methods)
    return resources, issues


def _reference_resources_from_client_members(
    root: Path,
    config: ReferenceSymbolConfig,
    class_index: dict[str, list[Path]],
) -> tuple[dict[str, set[str]], list[dict[str, Any]]]:
    path = _reference_symbol_path(root, config.path or "")
    classes = _python_top_level_classes(path)
    if not config.class_name or config.class_name not in classes:
        raise ToolkitError(f"Reference client class '{config.class_name}' not found in {path}")
    client_class = classes[config.class_name]
    members = {}
    members.update(_python_property_members(client_class))
    members.update(_python_init_members(client_class))
    members.update(_python_member_map(client_class, config.member_map_name))
    issues: list[dict[str, Any]] = []
    resources: dict[str, set[str]] = {}
    allowed_include = {_normalize_reference_resource(item) for item in config.include}
    blocked = {_normalize_reference_resource(item) for item in config.exclude}
    for member_name, class_name in sorted(members.items()):
        resource_name = _normalize_reference_resource(config.aliases.get(member_name, member_name))
        if allowed_include and resource_name not in allowed_include:
            continue
        if resource_name in blocked or member_name.startswith("_"):
            continue
        methods, error = _python_methods_for_class(class_index, class_name)
        if error:
            issues.append(_audit_issue("reference", "warning", resource_name, error))
        resources[resource_name] = methods
    return resources, issues


def _reference_global_methods_from_client(
    root: Path,
    config: ReferenceSymbolConfig,
) -> tuple[set[str], list[dict[str, Any]]]:
    path = _reference_symbol_path(root, config.path or "")
    classes = _python_top_level_classes(path)
    if not config.class_name or config.class_name not in classes:
        raise ToolkitError(f"Reference client class '{config.class_name}' not found in {path}")
    methods = _python_public_methods_from_class(classes[config.class_name])
    normalized = {_normalize_reference_method(config.aliases.get(method, method)) for method in methods}
    normalized = _apply_symbol_filters(normalized, config)
    return normalized, []


def _load_reference_resources(
    root: Path,
    reference: ReferenceImplConfig,
    class_index: dict[str, list[Path]],
) -> tuple[str, dict[str, set[str]] | set[str], list[dict[str, Any]]]:
    if reference.resources is None:
        return "none", {}, []
    config = reference.resources
    if config.adapter == "python_stainless_resources":
        resources, issues = _reference_resources_from_stainless(root, config)
        return "grouped", resources, issues
    if config.adapter == "python_client_members":
        resources, issues = _reference_resources_from_client_members(root, config, class_index)
        return "grouped", resources, issues
    if config.adapter == "python_client_methods":
        methods, issues = _reference_global_methods_from_client(root, config)
        return "global", methods, issues
    raise ToolkitError(f"Unsupported reference resources adapter '{config.adapter}'")


def _load_reference_types(root: Path, reference: ReferenceImplConfig) -> set[str]:
    if reference.types is None:
        return set()
    config = reference.types
    if config.adapter == "python_init_exports":
        return _reference_types_from_init_exports(root, config)
    if config.adapter == "python_single_file_classes":
        return _reference_types_from_single_file(root, config)
    if config.adapter == "python_recursive_classes":
        return _reference_types_from_recursive_paths(root, config)
    raise ToolkitError(f"Unsupported reference types adapter '{config.adapter}'")


def _audit_dart_export_targets(path: Path) -> set[Path]:
    targets: set[Path] = set()
    for directive in DART_EXPORT_DIRECTIVE_RE.finditer(read_text(path)):
        for _, relative_path in DART_QUOTED_PATH_RE.findall(directive.group(0)):
            target = (path.parent / relative_path).resolve()
            if target.exists():
                targets.add(target)
    return targets


def _audit_dart_resource_sources(path: Path, visited: set[Path] | None = None) -> set[Path]:
    visited = visited or set()
    resolved_path = path.resolve()
    if resolved_path in visited or not resolved_path.exists():
        return set()
    visited.add(resolved_path)
    sources = {resolved_path}
    for target in _audit_dart_export_targets(resolved_path):
        sources.update(_audit_dart_resource_sources(target, visited))
    return sources


def _dart_resource_class_details(
    class_name: str,
    class_sources: dict[str, set[Path]],
) -> tuple[set[str], list[tuple[str, str]]]:
    methods: set[str] = set()
    child_resources: set[tuple[str, str]] = set()
    for source_path in sorted(class_sources.get(class_name, set())):
        content = read_text(source_path)
        class_block = extract_class_block(content, class_name)
        if not class_block:
            continue
        methods.update(
            _normalize_reference_method(method)
            for method in extract_public_methods(source_path, class_name)
        )
        child_resources.update(
            (getter_name, child_class)
            for child_class, getter_name in DART_RESOURCE_GETTER_RE.findall(class_block)
        )
    return methods, sorted(child_resources)


def _dart_resource_inventory(config: ToolkitConfig) -> tuple[dict[str, set[str]], set[str]]:
    resources_dir = config.package_root / config.package.resources_dir
    resources: dict[str, set[str]] = {}
    global_methods: set[str] = set()
    if not resources_dir.exists():
        return resources, global_methods
    class_sources: dict[str, set[Path]] = defaultdict(set)
    root_resources: list[tuple[str, str]] = []
    for path in sorted(resources_dir.rglob("*_resource.dart")):
        resource_name = _normalize_reference_resource(path.stem)
        class_name = to_pascal_case(path.stem)
        root_resources.append((resource_name, class_name))
        for source_path in sorted(_audit_dart_resource_sources(path)):
            for declared_class in find_declared_classes(source_path):
                if declared_class.endswith("Resource"):
                    class_sources[declared_class].add(source_path)

    class_details = {
        class_name: _dart_resource_class_details(class_name, class_sources)
        for class_name in sorted(class_sources)
    }
    referenced_children = {
        child_class
        for _, children in class_details.values()
        for _, child_class in children
        if child_class in class_details
    }

    visited: set[tuple[str, str]] = set()
    for resource_name, class_name in root_resources:
        if class_name in referenced_children:
            continue
        pending = [(resource_name, class_name)]
        while pending:
            current_name, current_class = pending.pop()
            if (current_name, current_class) in visited or current_class not in class_details:
                continue
            visited.add((current_name, current_class))
            methods, child_resources = class_details[current_class]
            resources.setdefault(current_name, set()).update(methods)
            global_methods.update(methods)
            for getter_name, child_class in child_resources:
                if child_class not in class_details:
                    continue
                child_name = f"{current_name}_{_normalize_reference_resource(getter_name)}"
                pending.append((child_name, child_class))
    return resources, global_methods


def _dart_client_method_inventory(config: ToolkitConfig) -> set[str]:
    client_dir = config.package_root / "lib" / "src" / "client"
    if not client_dir.exists():
        return set()
    methods: set[str] = set()
    for path in sorted(client_dir.glob("*_client.dart")):
        for class_name in find_declared_classes(path):
            if not class_name.endswith("Client"):
                continue
            methods.update(
                _normalize_reference_method(method)
                for method in extract_public_methods(path, class_name)
            )
    return methods


def _load_optional_spec_payload(config: ToolkitConfig, spec_name: str) -> dict[str, Any] | None:
    try:
        spec_path = _selected_spec_path(config, spec_name, prefer_fetched=True)
    except ToolkitError:
        return None
    return _load_spec_payload(spec_path)


def _audit_schema_selector_candidates(config: ToolkitConfig, schema_filter: str) -> dict[str, set[str]]:
    candidates: dict[str, set[str]] = defaultdict(set)
    for entry in config.manifest.types.values():
        if entry.key == schema_filter or entry.schema_name == schema_filter or entry.dart_class == schema_filter:
            candidates[entry.spec].add(entry.key)
    for spec_name in config.specs:
        spec_payload = _load_optional_spec_payload(config, spec_name)
        if spec_payload is None:
            continue
        if schema_filter in spec_payload.get("components", {}).get("schemas", {}):
            candidates[spec_name].add(schema_filter)
    return dict(candidates)


def _format_audit_schema_selector_candidates(candidates: dict[str, set[str]]) -> str:
    return ", ".join(
        f"{spec_name}: {', '.join(sorted(values))}"
        for spec_name, values in sorted(candidates.items())
    )


def _resolve_audit_spec_name(
    config: ToolkitConfig,
    requested_spec_name: str | None,
    *,
    checks: list[str],
    schema_filter: str | None,
) -> str:
    if requested_spec_name:
        return config.get_spec(requested_spec_name)[0]
    if "schema" not in checks or not schema_filter:
        return config.get_spec(None)[0]
    candidates = _audit_schema_selector_candidates(config, schema_filter)
    if not candidates:
        raise ToolkitError(f"Unknown schema '{schema_filter}'")
    if len(candidates) > 1:
        raise ToolkitError(
            f"Schema selector '{schema_filter}' is ambiguous across specs. "
            f"Use --spec-name. Candidates: {_format_audit_schema_selector_candidates(candidates)}"
        )
    return next(iter(candidates))


def _resolve_audit_schema_filter(
    config: ToolkitConfig,
    spec_name: str,
    schema_filter: str | None,
    spec_payload: dict[str, Any],
) -> str | None:
    if not schema_filter:
        return None
    matches = _lookup_entries(config, schema_filter, spec_name)
    if len(matches) == 1:
        return matches[0].schema_name
    if len(matches) > 1:
        candidates = ", ".join(sorted(entry.key for entry in matches))
        raise ToolkitError(
            f"Schema selector '{schema_filter}' is ambiguous in spec '{spec_name}'. Candidates: {candidates}"
        )
    available_schemas = set(spec_payload.get("components", {}).get("schemas", {}))
    if schema_filter in available_schemas:
        return schema_filter
    raise ToolkitError(f"Unknown schema '{schema_filter}'")


def _run_schema_audit(
    config: ToolkitConfig,
    spec_name: str,
    spec_payload: dict[str, Any],
    *,
    scope: str,
    schema_filter: str | None,
    include_excluded: bool,
) -> dict[str, Any]:
    audit = config.specs[spec_name].audit
    class_index = _dart_class_index(config)
    included = _included_schema_names(config, spec_name, spec_payload, include_excluded=include_excluded)
    available_schemas = set(spec_payload.get("components", {}).get("schemas", {}))
    resolved_schema_filter = _resolve_audit_schema_filter(config, spec_name, schema_filter, spec_payload)
    if resolved_schema_filter and resolved_schema_filter not in included and resolved_schema_filter in available_schemas:
        included.append(resolved_schema_filter)
        included = sorted(set(included))

    issues: list[dict[str, Any]] = []
    schema_items: list[dict[str, Any]] = []
    for schema_name in included:
        if resolved_schema_filter and schema_name != resolved_schema_filter:
            continue

        manifest_entry = _schema_manifest_match(config, spec_name, schema_name)
        status = "unmatched"
        source = None
        class_name = None
        file_path: Path | None = None
        manifest_key = None

        if manifest_entry is not None:
            status = "matched"
            source = "manifest"
            class_name = manifest_entry.dart_class
            file_path = config.resolve_package_path(manifest_entry.file)
            manifest_key = manifest_entry.key
        elif schema_name in audit.schema_aliases:
            status, alias_entry, class_name, file_path, source = _resolve_schema_alias_match(
                config, spec_name, audit.schema_aliases[schema_name], class_index
            )
            if alias_entry is not None:
                manifest_key = alias_entry.key
                class_name = alias_entry.dart_class
                file_path = config.resolve_package_path(alias_entry.file)
        else:
            status, class_name, file_path, source = _heuristic_schema_match(schema_name, class_index)

        item = {
            "schema_name": schema_name,
            "status": status,
            "source": source,
            "manifest_key": manifest_key,
            "dart_class": class_name,
            "file": str(file_path.relative_to(config.package_root)) if file_path and file_path.exists() else (str(file_path) if file_path else None),
            "covered_properties": [],
            "missing_properties": [],
        }
        if status == "matched" and class_name and file_path is not None:
            coverage = _schema_property_coverage(config, file_path, class_name, schema_name, spec_payload)
            item.update(coverage)
            if coverage["missing_properties"]:
                issues.append(
                    _audit_issue(
                        "schema",
                        "warning",
                        schema_name,
                        f"Matched Dart model is missing properties: {', '.join(coverage['missing_properties'])}",
                        file=item["file"],
                    )
                )
        elif status == "ambiguous":
            issues.append(_audit_issue("schema", "warning", schema_name, f"Schema match is ambiguous after applying '{source}'"))
        else:
            issues.append(_audit_issue("schema", "warning", schema_name, "Schema has no Dart model match"))

        if _normalize_audit_scope(scope, status):
            schema_items.append(item)

    matched_count = sum(1 for item in schema_items if item["status"] == "matched")
    ambiguous_count = sum(1 for item in schema_items if item["status"] == "ambiguous")
    unmatched_count = sum(1 for item in schema_items if item["status"] == "unmatched")
    return {
        "status": "ok",
        "scope": scope,
        "schema_filter": resolved_schema_filter,
        "included_schema_count": len(included),
        "returned_schema_count": len(schema_items),
        "matched_schema_count": matched_count,
        "ambiguous_schema_count": ambiguous_count,
        "unmatched_schema_count": unmatched_count,
        "schemas": schema_items,
        "issues": issues,
    }


def _run_reference_audit(config: ToolkitConfig, spec_name: str) -> dict[str, Any]:
    reference = config.specs[spec_name].audit.reference_impl
    if reference is None:
        raise ToolkitError(f"Spec '{spec_name}' has no audit.reference_impl configuration")

    try:
        repo_root, temp_root = _download_reference_repo(reference.repo, reference.ref)
    except _ReferenceUnavailableError as exc:
        issue = _audit_issue("reference", "warning", "reference_impl", str(exc))
        return {
            "status": "unavailable",
            "repo": reference.repo,
            "ref": reference.ref,
            "issues": [issue],
        }

    try:
        python_index = _python_class_index(repo_root)
        mode, reference_resources, issues = _load_reference_resources(repo_root, reference, python_index)
        reference_types = _load_reference_types(repo_root, reference)
        dart_resources, _ = _dart_resource_inventory(config)
        dart_client_methods = _dart_client_method_inventory(config)
        dart_types = set(_dart_class_index(config))

        missing_resources: list[str] = []
        missing_methods: list[dict[str, Any]] = []
        if mode == "grouped":
            grouped = reference_resources if isinstance(reference_resources, dict) else {}
            for resource_name, methods in sorted(grouped.items()):
                if resource_name not in dart_resources:
                    missing_resources.append(resource_name)
                    issues.append(_audit_issue("reference", "warning", resource_name, "Reference resource has no Dart counterpart"))
                    continue
                gaps = sorted(methods - dart_resources[resource_name])
                if gaps:
                    missing_methods.append({"resource": resource_name, "methods": gaps})
                    issues.append(
                        _audit_issue(
                            "reference",
                            "warning",
                            resource_name,
                            f"Dart resource is missing reference methods: {', '.join(gaps)}",
                        )
                    )
        else:
            global_methods = reference_resources if isinstance(reference_resources, set) else set()
            gaps = sorted(global_methods - dart_client_methods)
            if gaps:
                missing_methods.append({"resource": "*", "methods": gaps})
                issues.append(
                    _audit_issue(
                        "reference",
                        "warning",
                        "global_methods",
                        f"Dart client is missing reference methods: {', '.join(gaps)}",
                    )
                )

        missing_types = sorted(reference_types - dart_types)
        if missing_types:
            issues.append(
                _audit_issue(
                    "reference",
                    "warning",
                    "types",
                    f"Dart models are missing reference types: {', '.join(missing_types)}",
                )
            )

        return {
            "status": "ok",
            "repo": reference.repo,
            "ref": reference.ref,
            "mode": mode,
            "reference_resource_count": len(reference_resources) if isinstance(reference_resources, dict) else 0,
            "reference_method_count": len(reference_resources) if isinstance(reference_resources, set) else 0,
            "reference_type_count": len(reference_types),
            "dart_resource_count": len(dart_resources),
            "dart_type_count": len(dart_types),
            "missing_resources": missing_resources,
            "missing_methods": missing_methods,
            "missing_types": missing_types,
            "issues": issues,
        }
    finally:
        shutil.rmtree(temp_root, ignore_errors=True)


def command_audit(args: Any) -> tuple[int, dict[str, Any]]:
    config = load_toolkit_config(args.config_dir)
    if config.manifest.surface != "openapi":
        raise ToolkitError("The audit command currently supports OpenAPI skills only")

    checks = ["schema", "reference"] if args.checks == "all" else [args.checks]
    spec_name = _resolve_audit_spec_name(config, args.spec_name, checks=checks, schema_filter=args.schema)
    spec_payload = (
        _load_spec_payload(_selected_spec_path(config, spec_name, prefer_fetched=True))
        if "schema" in checks
        else None
    )
    results: dict[str, Any] = {}
    issues: list[dict[str, Any]] = []

    for check in checks:
        if check == "schema":
            if spec_payload is None:
                raise ToolkitError(f"No spec found for '{spec_name}'")
            result = _run_schema_audit(
                config,
                spec_name,
                spec_payload,
                scope=args.scope,
                schema_filter=args.schema,
                include_excluded=args.include_excluded,
            )
        elif check == "reference":
            result = _run_reference_audit(config, spec_name)
        else:  # pragma: no cover - argparse prevents this
            raise ToolkitError(f"Unsupported audit check '{check}'")
        results[check] = result
        issues.extend(result.get("issues", []))

    return EXIT_SUCCESS, {
        "command": "audit",
        "surface": config.manifest.surface,
        "spec_name": spec_name,
        "checks": checks,
        "results": results,
        "issues": issues,
        "summary": {
            "warning_count": sum(1 for issue in issues if issue["level"] == "warning"),
            "info_count": sum(1 for issue in issues if issue["level"] == "info"),
            "checks_with_findings": [name for name, result in results.items() if result.get("issues")],
            "unavailable_checks": [name for name, result in results.items() if result.get("status") == "unavailable"],
        },
    }
def _emit_review_changelog(config: ToolkitConfig, diff: dict[str, Any]) -> str:
    lines = [f"# {config.package.changelog_title}", ""]
    if config.manifest.surface == "openapi":
        summary = [
            ("New endpoints", len(diff["endpoints"]["added"])),
            ("Modified endpoints", len(diff["endpoints"]["modified"])),
            ("Removed endpoints", len(diff["endpoints"]["removed"])),
            ("New schemas", len(diff["schemas"]["added"])),
            ("Modified schemas", len(diff["schemas"]["modified"])),
            ("Removed schemas", len(diff["schemas"]["removed"])),
        ]
        lines.append("## Summary")
        lines.append("")
        for label, count in summary:
            lines.append(f"- {label}: {count}")
        lines.append("")
    else:
        lines.append("## Summary")
        lines.append("")
        for group in ("client_messages", "server_messages", "config_types", "enums"):
            lines.append(
                f"- {group}: +{len(diff[group]['added'])} / ~{len(diff[group]['modified'])} / -{len(diff[group]['removed'])}"
            )
        lines.append("")
    return "\n".join(lines)


def _emit_review_plan(config: ToolkitConfig, actions: list[str], issues: list[dict[str, Any]]) -> str:
    lines = [f"# {config.package.changelog_title} Implementation Plan", "", "## Prioritized Actions", ""]
    for action in actions:
        lines.append(f"- [ ] {action}")
    if issues:
        lines.extend(["", "## Review Issues", ""])
        for issue in issues:
            lines.append(f"- [{issue['level']}] {issue['name']}: {issue['message']}")
    return "\n".join(lines)


def _scaffold_enum_fallback_member(seen: set[str]) -> str:
    if "unknown" not in seen:
        candidate = "unknown"
    elif "unspecified" not in seen:
        candidate = "unspecified"
    else:
        candidate = "unknownValue"
    while candidate in seen:
        candidate = f"{candidate}Value"
    return candidate


def _scaffold_enum_source(class_name: str, values: list[str]) -> str:
    members = []
    for value in values:
        member = snake_case(value).replace("_", " ").title().replace(" ", "")
        member = member[:1].lower() + member[1:] if member else "value"
        members.append((member, value))
    unique_members: list[tuple[str, str]] = []
    seen = set()
    for member, raw in members:
        while member in seen:
            member = f"{member}Value"
        seen.add(member)
        unique_members.append((member, raw))
    fallback_member = _scaffold_enum_fallback_member(seen)
    lines = [f"enum {class_name} {{"]
    for member, _ in unique_members:
        lines.append(f"  {member},")
    lines.append(f"  {fallback_member},")
    lines.append("}")
    lines.append("")
    lines.append(f"{class_name} {camel_case(class_name)}FromString(String? value) {{")
    lines.append("  return switch (value) {")
    for member, raw in unique_members:
        lines.append(f"    '{raw}' => {class_name}.{member},")
    lines.append(f"    _ => {class_name}.{fallback_member},")
    lines.append("  };")
    lines.append("}")
    lines.append("")
    lines.append(f"String {camel_case(class_name)}ToString({class_name} value) {{")
    lines.append("  return switch (value) {")
    for member, raw in unique_members:
        lines.append(f"    {class_name}.{member} => '{raw}',")
    lines.append(f"    {class_name}.{fallback_member} => 'unknown',")
    lines.append("  };")
    lines.append("}")
    return "\n".join(lines) + "\n"


def _dart_type_from_prop(type_mappings: dict[str, str], prop: dict[str, Any]) -> str:
    if prop.get("ref"):
        return prop["ref"]
    type_name = prop.get("type")
    if type_name == "array":
        items = prop.get("items", {})
        if "$ref" in items:
            return f"List<{items['$ref'].split('/')[-1]}>"
        return f"List<{type_mappings.get(items.get('type', 'dynamic'), 'dynamic')}>"
    if type_name == "object":
        return "Map<String, dynamic>"
    return type_mappings.get(type_name, type_name or "dynamic")


def _scaffold_array_from_json(field_name: str, prop: dict[str, Any], type_mappings: dict[str, str]) -> str:
    items = prop.get("items") or {}
    value = f"json['{field_name}']"
    if "$ref" in items:
        ref_type = items["$ref"].split("/")[-1]
        expression = (
            f"({value} as List<dynamic>).map((item) => "
            f"{ref_type}.fromJson(item as Map<String, dynamic>)).toList()"
        )
    else:
        item_type = items.get("type")
        if not item_type:
            return "TODO()"
        if item_type == "number":
            expression = f"({value} as List<dynamic>).map((item) => (item as num).toDouble()).toList()"
        else:
            dart_item_type = type_mappings.get(item_type, item_type or "dynamic")
            if dart_item_type == "dynamic":
                expression = f"({value} as List<dynamic>).toList()"
            else:
                expression = f"({value} as List<dynamic>).map((item) => item as {dart_item_type}).toList()"
    if prop.get("required"):
        return expression
    return f"{value} != null ? {expression} : null"


def _scaffold_from_json_expression(field_name: str, prop: dict[str, Any], type_mappings: dict[str, str]) -> str:
    dart_type = _dart_type_from_prop(type_mappings, prop)
    value = f"json['{field_name}']"
    if prop.get("type") == "array":
        return _scaffold_array_from_json(field_name, prop, type_mappings)
    if prop.get("ref"):
        if prop.get("required"):
            return f"{dart_type}.fromJson({value} as Map<String, dynamic>)"
        return f"{value} != null ? {dart_type}.fromJson({value} as Map<String, dynamic>) : null"
    if dart_type == "double":
        if prop.get("required"):
            return f"({value} as num).toDouble()"
        return f"{value} != null ? ({value} as num).toDouble() : null"
    suffix = "" if prop.get("required") else "?"
    return f"{value} as {dart_type}{suffix}"


def _scaffold_to_json_expression(field_name: str, prop: dict[str, Any], type_mappings: dict[str, str]) -> str:
    field = camel_case(field_name)
    if prop.get("type") == "array":
        items = prop.get("items") or {}
        if "$ref" in items:
            return f"{field}.map((item) => item.toJson()).toList()"
        if items.get("type"):
            return field
        return "TODO()"
    if prop.get("ref"):
        return f"{field}.toJson()"
    return field


def _scaffold_nullable_to_json_expression(field_name: str, json_value: str) -> str:
    field = camel_case(field_name)
    if json_value == "TODO()":
        return json_value
    if json_value == field:
        return f"{field}!"
    prefix = f"{field}."
    if json_value.startswith(prefix):
        return f"{field}!{json_value[len(field):]}"
    return json_value


def _scaffold_class_source(class_name: str, props: dict[str, dict[str, Any]], type_mappings: dict[str, str]) -> str:
    lines = [
        "const Object _unsetCopyWithValue = _UnsetCopyWithSentinel();",
        "",
        "class _UnsetCopyWithSentinel {",
        "  const _UnsetCopyWithSentinel();",
        "}",
        "",
        f"class {class_name} {{",
    ]
    for name, prop in props.items():
        dart_type = _dart_type_from_prop(type_mappings, prop)
        suffix = "" if prop.get("required") else "?"
        lines.append(f"  final {dart_type}{suffix} {camel_case(name)};")
    lines.append("")
    lines.append(f"  const {class_name}({{")
    for name, prop in props.items():
        qualifier = "required " if prop.get("required") else ""
        lines.append(f"    {qualifier}this.{camel_case(name)},")
    lines.append("  });")
    lines.append("")
    lines.append(f"  factory {class_name}.fromJson(Map<String, dynamic> json) {{")
    lines.append(f"    return {class_name}(")
    for name, prop in props.items():
        field = camel_case(name)
        lines.append(f"      {field}: {_scaffold_from_json_expression(name, prop, type_mappings)},")
    lines.append("    );")
    lines.append("  }")
    lines.append("")
    lines.append("  Map<String, dynamic> toJson() => {")
    for name, prop in props.items():
        field = camel_case(name)
        json_value = _scaffold_to_json_expression(name, prop, type_mappings)
        if prop.get("required"):
            lines.append(f"    '{name}': {json_value},")
        else:
            nullable_value = _scaffold_nullable_to_json_expression(name, json_value)
            lines.append(f"    if ({field} != null) '{name}': {nullable_value},")
    lines.append("  };")
    lines.append("")
    lines.append(f"  {class_name} copyWith({{")
    for name, prop in props.items():
        lines.append(f"    Object? {camel_case(name)} = _unsetCopyWithValue,")
    lines.append("  }) {")
    lines.append(f"    return {class_name}(")
    for name, prop in props.items():
        field = camel_case(name)
        dart_type = _dart_type_from_prop(type_mappings, prop)
        if prop.get("required"):
            lines.append(
                f"      {field}: {field} == _unsetCopyWithValue ? this.{field} : {field}! as {dart_type},"
            )
        else:
            lines.append(
                f"      {field}: {field} == _unsetCopyWithValue ? this.{field} : {field} as {dart_type}?,"
            )
    lines.append("    );")
    lines.append("  }")
    lines.append("")
    lines.append("  @override")
    lines.append("  String toString() =>")
    lines.append(f"      '{class_name}(" + ", ".join(f"{camel_case(name)}: ${camel_case(name)}" for name in props) + ")';")
    lines.append("}")
    return "\n".join(lines) + "\n"


def _render_scaffold(config: ToolkitConfig, target: str, spec_name: str, name: str) -> tuple[str, str]:
    spec_payload = _load_spec_payload(_selected_spec_path(config, spec_name, prefer_fetched=True))
    entry = None
    try:
        entry = _resolve_entry(config, name, spec_name)
    except ToolkitError:
        entry = None
    schema_name = entry.schema_name if entry else name
    if config.manifest.surface == "openapi":
        schema = spec_payload.get("components", {}).get("schemas", {}).get(schema_name)
        if target == "enum":
            if not schema or not schema.get("enum"):
                raise ToolkitError(f"Schema '{schema_name}' is not an enum")
            class_name = entry.dart_class if entry else ManifestEntry(schema_name, spec_name, "enum", schema_name, "").dart_class
            return _scaffold_enum_source(class_name, list(schema.get("enum", []))), class_name
        if target == "schema":
            if not schema:
                raise ToolkitError(f"Unknown schema '{schema_name}'")
            props = _openapi_property_info(spec_payload, schema_name)
            class_name = entry.dart_class if entry else ManifestEntry(schema_name, spec_name, "object", schema_name, "").dart_class
            return _scaffold_class_source(class_name, props, config.manifest.type_mappings), class_name
    else:
        if target == "enum":
            enum_values = spec_payload.get("enums", {}).get(schema_name, {}).get("values")
            if not enum_values:
                raise ToolkitError(f"Unknown websocket enum '{schema_name}'")
            class_name = entry.dart_class if entry else schema_name
            return _scaffold_enum_source(class_name, list(enum_values)), class_name
        if target in {"message", "config"}:
            if target == "message":
                raw = spec_payload.get("message_types", {}).get("client", {}).get(schema_name) or spec_payload.get("message_types", {}).get("server", {}).get(schema_name)
            else:
                raw = spec_payload.get("config_types", {}).get(schema_name)
            if not raw:
                raise ToolkitError(f"Unknown websocket {target} '{schema_name}'")
            props = {field_name: {**field_spec, "required": field_spec.get("required", False)} for field_name, field_spec in raw.get("fields", {}).items()}
            class_name = entry.dart_class if entry else schema_name
            return _scaffold_class_source(class_name, props, config.manifest.type_mappings), class_name
    raise ToolkitError(f"Unsupported scaffold target '{target}' for surface '{config.manifest.surface}'")


def _render_barrel(config: ToolkitConfig, name: str) -> str:
    relative = Path(name)
    if relative.suffix != ".dart":
        relative = relative / f"{relative.name}.dart"
    target_dir = config.package_root / relative.parent
    if not target_dir.exists():
        raise ToolkitError(f"Target directory does not exist for barrel scaffold: {target_dir}")
    exports = []
    for file_path in sorted(target_dir.glob("*.dart")):
        if file_path.name == relative.name or file_path.name.startswith("_"):
            continue
        exports.append(f"export '{file_path.name}';")
    return "\n".join(exports) + ("\n" if exports else "")


def _workspace_pubspec_update(pubspec: Path, package_path: str) -> str:
    content = pubspec.read_text()
    workspace_match = WORKSPACE_BLOCK_RE.search(content)
    if not workspace_match:
        raise ToolkitError("Workspace list not found in root pubspec.yaml")
    entries = [line.strip()[2:] for line in workspace_match.group(1).splitlines() if line.strip().startswith("- ")]
    if package_path not in entries:
        entries.append(package_path)
    entries = sorted(entries)
    replacement = "workspace:\n" + "".join(f"  - {entry}\n" for entry in entries)
    return content[: workspace_match.start()] + replacement + content[workspace_match.end() :]


def _default_skill_yaml(skill_name: str, product_display_name: str, surface_label: str) -> str:
    display_name = f"{product_display_name} {surface_label}"
    return (
        "interface:\n"
        f'  display_name: "{display_name}"\n'
        f'  short_description: "Manage {display_name} workflow"\n'
        f'  default_prompt: "Use ${skill_name} to review API changes, scaffold updates, and verify the client package."\n'
    )


def _render_skill_markdown(package_name: str, display_name: str, shortname: str, auth_env_vars: list[str], spec_names: list[str], refs: list[str], surface: str = "openapi") -> str:
    auth_line = ", ".join(f"`{value}`" for value in auth_env_vars) if auth_env_vars else "No auth env vars required"
    spec_table = "\n".join(f"| `{spec_name}` | Canonical {surface} spec |" for spec_name in spec_names)
    ref_lines = "\n".join(f"- [{ref}]({ref})" for ref in refs)
    return f"""---
name: {surface}-{shortname}
description: Update {package_name} from {display_name} {surface} changes. Use for spec refresh, change review, scaffolding, and verification.
---

# {display_name} {surface.title()} Workflow

## Prerequisites

- Auth: {auth_line}
- Existing-package commands: run the repo-relative examples from the repository root. If you run them elsewhere, invoke the script via an absolute path and pass an absolute `--config-dir`.

## Workflow

1. Fetch:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch \\
  --config-dir packages/{package_name}/.agents/skills/{surface}-{shortname}/config
```
Fetch writes the candidate spec to the configured `output_dir` as `latest-<spec>.json`.
2. Review:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review \\
  --config-dir packages/{package_name}/.agents/skills/{surface}-{shortname}/config
```
3. Implement with `scaffold` plus the package references, then promote the reviewed candidate from `output_dir/latest-<spec>.json` into `packages/{package_name}/specs/` before final verification.
4. Verify:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify \\
  --config-dir packages/{package_name}/.agents/skills/{surface}-{shortname}/config \\
  --checks all --scope all
```

## Specs

| Spec | Description |
| --- | --- |
{spec_table}

## Package References

{ref_lines}

## Separate Dart Quality Steps

- `dart analyze --fatal-infos`
- `dart format --set-exit-if-changed .`
- `dart test test/unit/`
"""


def _render_review_checklist(config_dir: str, package_name: str) -> str:
    return f"""# Review Checklist

## Workflow

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch --config-dir {config_dir}
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review --config-dir {config_dir}
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir {config_dir} --checks all --scope all
```

## Package Quality

```bash
cd packages/{package_name}
dart analyze --fatal-infos
dart format --set-exit-if-changed .
dart test test/unit/
```
"""


def _render_package_guide(package_name: str, shortname: str) -> str:
    config_dir = f"packages/{package_name}/.agents/skills/openapi-{shortname}/config"
    return f"""# {package_name} OpenAPI Package Guide

## Core Paths

- Package root: `packages/{package_name}`
- Skill config: `{config_dir}`
- Canonical specs: `packages/{package_name}/specs/`

## Toolkit Commands

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py describe --config-dir {config_dir}
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py scaffold --config-dir {config_dir} --target schema --name ExampleSchema --dry-run
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir {config_dir} --checks exports --scope all
```

Run the repo-relative examples from the repository root. If you run them elsewhere, invoke the script via an absolute path and pass an absolute `--config-dir`.
"""


def _render_impl_patterns(package_name: str) -> str:
    return f"""# Implementation Patterns

- Extend the shared core patterns in [implementation-patterns-core.md](../../../../../../.agents/shared/api-toolkit/references/implementation-patterns-core.md).
- Keep model serialization manual and deterministic.
- Keep package-specific naming and layering consistent with `packages/{package_name}/lib/src/`.
"""


def _render_core_impl_patterns() -> str:
    return """# Core Implementation Patterns

- Prefer low-freedom workflows: fetch, review, scaffold, verify.
- Keep specs checked in under package `specs/`.
- Keep model serialization handwritten and predictable.
- Use null-omitting `toJson` and explicit `fromJson` parsing.
"""


def _render_core_review_checklist() -> str:
    return """# Core Review Checklist

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch --config-dir <config-dir>
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review --config-dir <config-dir>
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir <config-dir> --checks all --scope all
```
"""


def _write_file(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)


def _creation_plan(package_name: str, display_name: str, shortname: str, manifest: dict[str, Any]) -> str:
    schema_names = [key for key, entry in manifest["types"].items() if entry["kind"] != "skip"]
    enums = [key for key, entry in manifest["types"].items() if entry["kind"] == "enum"]
    objects = [key for key, entry in manifest["types"].items() if entry["kind"] != "enum"]
    lines = [
        f"# {display_name} Creation Plan",
        "",
        f"- Package: `{package_name}`",
        f"- Total tracked types: {len(schema_names)}",
        f"- Enums: {len(enums)}",
        f"- Objects/parents: {len(objects)}",
        "",
        "## First Steps",
        "",
        "- Run `review` after the first fetch to confirm the baseline is stable.",
        "- Use `scaffold --target enum` for enums before object models.",
        "- Fill in resources after core models are in place.",
        "- Promote the reviewed candidate from `output_dir/latest-main.json` into `specs/openapi.json` before final verification.",
        "- Run the repo-relative examples from the repository root. If you run them elsewhere, invoke the script via an absolute path and pass an absolute `--config-dir`.",
        "",
        "## Suggested Scaffold Commands",
        "",
    ]
    for name in schema_names[:10]:
        entry = manifest["types"][name]
        target = "enum" if entry["kind"] == "enum" else "schema"
        lines.append(
            f"- `python3 .agents/shared/api-toolkit/scripts/api_toolkit.py scaffold --config-dir packages/{package_name}/.agents/skills/openapi-{shortname}/config --spec-name main --target {target} --name {name} --dry-run`"
        )
    return "\n".join(lines) + "\n"


def _metadata_path(config: ToolkitConfig) -> Path:
    return config.specs_dir / "spec_metadata.json"


def _load_spec_metadata(config: ToolkitConfig) -> dict[str, Any]:
    return read_json_file(_metadata_path(config), {"specs": {}})


def _write_spec_metadata(
    config: ToolkitConfig,
    spec_name: str,
    spec_payload: dict[str, Any],
    source_url: str,
) -> None:
    metadata = _load_spec_metadata(config)
    specs = metadata.setdefault("specs", {})
    current = specs.get(spec_name, {})
    current_version = spec_payload.get("info", {}).get("version", "unknown")
    previous_version = current.get("current_version")
    history = list(current.get("version_history", []))
    if previous_version and previous_version != current_version:
        history.insert(
            0,
            {
                "version": previous_version,
                "fetched_at": current.get("last_fetched"),
            },
        )
        history = history[:MAX_VERSION_HISTORY]

    specs[spec_name] = {
        "title": spec_payload.get("info", {}).get("title", "Unknown"),
        "current_version": current_version,
        "last_fetched": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "source_url": source_url,
        "version_history": history,
    }
    write_json(_metadata_path(config), metadata)


def _parse_stats_field(content: str, field: str) -> str | None:
    pattern = rf"^\s*{re.escape(field)}\s*:\s*['\"]?([^'\"\n]+)['\"]?\s*$"
    match = re.search(pattern, content, re.MULTILINE)
    return match.group(1).strip() if match else None


def _preflight_payload(config: ToolkitConfig, spec_name: str, spec: SpecConfig) -> dict[str, Any]:
    payload: dict[str, Any] = {
        "configured": False,
        "online": False,
        "latest_url": None,
        "latest_hash": None,
        "pinned_url": spec.url,
        "pinned_hash": None,
        "current_source_url": None,
        "current_version": None,
        "outdated": None,
    }

    metadata = _load_spec_metadata(config)
    current = metadata.get("specs", {}).get(spec_name, {})
    payload["current_source_url"] = current.get("source_url")
    payload["current_version"] = current.get("current_version")
    payload["pinned_hash"] = extract_hash_from_url(spec.url)

    stats_url = config.preflight.get("stats_url")
    if not stats_url:
        payload["status"] = "not_configured"
        return payload

    payload["configured"] = True
    payload["pinned_hash"] = extract_hash_from_url(spec.url)
    stats_field = config.preflight.get("stats_field", "openapi_spec_url")
    stats_text, error = fetch_remote_document(stats_url, None, None)
    if stats_text is None:
        payload["status"] = "offline"
        payload["error"] = error
        return payload

    payload["online"] = True
    latest_url = _parse_stats_field(stats_text, stats_field)
    if not latest_url:
        payload["status"] = "unparsed"
        payload["stats_field"] = stats_field
        return payload

    payload["status"] = "ok"
    payload["latest_url"] = latest_url
    payload["latest_hash"] = extract_hash_from_url(latest_url)
    if spec.url:
        payload["outdated"] = latest_url != spec.url
    return payload


def command_create(args: Any) -> tuple[int, dict[str, Any]]:
    validate_identifier(args.package_name, "package name")
    if bool(args.spec_url) == bool(args.spec_file):
        raise ToolkitError("Provide exactly one of --spec-url or --spec-file")

    if getattr(args, "repo_root", None):
        repo_root = Path(args.repo_root).resolve()
        if not (repo_root / "pubspec.yaml").exists():
            raise ToolkitError(f"Repo root does not contain pubspec.yaml: {repo_root}")
    else:
        repo_root = repo_root_from_path(Path.cwd())
    shortname = args.shortname or args.package_name.removesuffix("_dart")
    validate_identifier(shortname, "shortname")
    package_root = (repo_root / args.output_root / args.package_name).resolve()
    validate_output_path(package_root, [repo_root])
    requires_auth = bool(args.auth_env_var)
    bootstrap_api_key = next(
        (value for env_var in args.auth_env_var if (value := os.environ.get(env_var))),
        None,
    )

    if args.spec_file:
        spec_payload = _load_spec_payload(args.spec_file.resolve())
    else:
        document, error = fetch_remote_document(
            args.spec_url,
            bootstrap_api_key,
            AuthConfig(location="header", name="Authorization", prefix="Bearer ") if requires_auth else None,
        )
        if error:
            raise ToolkitError(f"Failed to fetch spec from {args.spec_url}: {error}")
        spec_payload = read_structured_text(document or "", source=args.spec_url or "remote spec")
        if not isinstance(spec_payload, dict):
            raise ToolkitError("Fetched spec must parse to an object")

    manifest = _build_initial_manifest_from_spec(
        spec=spec_payload,
        package_name=args.package_name,
        spec_name="main",
        models_dir="lib/src/models",
    )

    skill_name = f"openapi-{shortname}"
    config_dir = package_root / ".agents" / "skills" / skill_name / "config"
    skill_dir = config_dir.parent
    specs_dir = package_root / "specs"
    creation_plan_path = skill_dir / "creation-plan.md"

    package_json = {
        "name": args.package_name,
        "display_name": args.display_name,
        "barrel_file": f"lib/{args.package_name}.dart",
        "models_dir": "lib/src/models",
        "resources_dir": "lib/src/resources",
        "tests_dir": "test/unit/models",
        "examples_dir": "example",
        "skip_files": ["copy_with_sentinel.dart", "common.dart"],
        "internal_barrel_files": [],
        "pr_title_prefix": f"feat({args.package_name})",
        "changelog_title": f"{args.display_name} API Changelog",
    }
    specs_json = {
        "specs": {
            "main": {
                "name": args.display_name,
                "local_file": "openapi.json",
                "fetch_mode": "remote" if args.spec_url else "local_file",
                "url": args.spec_url,
                "requires_auth": requires_auth,
                "auth_env_vars": args.auth_env_var,
                "auth": {
                    "location": "header",
                    "name": "Authorization",
                    "prefix": "Bearer ",
                }
                if requires_auth
                else None,
                "description": f"{args.display_name} API",
                "source_file": "specs/openapi.source.json" if args.spec_file else None,
                "audit": {
                    "excluded_schemas": [],
                    "schema_aliases": {},
                },
            }
        },
        "specs_dir": f"packages/{args.package_name}/specs",
        "output_dir": str(default_output_dir(args.package_name)),
        "preflight": {},
    }
    if not args.spec_file:
        specs_json["specs"]["main"].pop("source_file")
    if not requires_auth:
        specs_json["specs"]["main"].pop("auth")
    documentation_json = {
        "removed_apis": [],
        "tool_properties": {},
        "excluded_resources": ["base_resource"],
        "resource_to_example": {},
        "excluded_from_examples": [],
        "drift_patterns": [],
    }

    root_pubspec = repo_root / "pubspec.yaml"
    updated_workspace = _workspace_pubspec_update(root_pubspec, f"packages/{args.package_name}")
    spec_source_path = specs_dir / ("openapi.source.json" if args.spec_file else "openapi.json")
    canonical_spec_path = specs_dir / "openapi.json"
    license_content = "" if args.dry_run else (repo_root / "LICENSE").read_text()

    writes = {
        package_root / "pubspec.yaml": (
            f"name: {args.package_name}\n"
            f"description: Dart client for the {args.display_name} API.\n"
            "version: 0.1.0\n"
            f"repository: https://github.com/davidmigloz/ai_clients_dart/tree/main/packages/{args.package_name}\n"
            f"issue_tracker: https://github.com/davidmigloz/ai_clients_dart/issues?q=label:p:{args.package_name}\n"
            "homepage: https://github.com/davidmigloz/ai_clients_dart\n\n"
            "environment:\n"
            '  sdk: ">=3.9.0 <4.0.0"\n'
            "resolution: workspace\n\n"
            "dependencies:\n"
            "  http: ^1.6.0\n"
            "  logging: ^1.3.0\n"
            "  meta: ^1.16.0\n\n"
            "dev_dependencies:\n"
            "  test: ^1.26.2\n"
            "  mocktail: ^1.0.4\n"
            "  coverage: ^1.15.0\n"
        ),
        package_root / "README.md": f"# {args.display_name} Dart Client\n\nDart client for the {args.display_name} API.\n",
        package_root / "CHANGELOG.md": "## 0.1.0\n\n- Initial bootstrap.\n",
        package_root / "dart_test.yaml": "tags:\n  integration:\n    description: >\n      Register the integration tag to suppress warnings. Integration tests\n      require API keys. Run with: dart test --tags integration\n",
        package_root / "lib" / f"{args.package_name}.dart": "library;\n",
        config_dir / "package.json": json.dumps(package_json, indent=2) + "\n",
        config_dir / "specs.json": json.dumps(specs_json, indent=2) + "\n",
        config_dir / "manifest.json": json.dumps(manifest, indent=2) + "\n",
        config_dir / "documentation.json": json.dumps(documentation_json, indent=2) + "\n",
        skill_dir / "SKILL.md": _render_skill_markdown(
            args.package_name,
            args.display_name,
            shortname,
            args.auth_env_var,
            ["main"],
            ["references/package-guide.md", "references/implementation-patterns.md", "references/REVIEW_CHECKLIST.md"],
        ),
        skill_dir / "references" / "package-guide.md": _render_package_guide(args.package_name, shortname),
        skill_dir / "references" / "implementation-patterns.md": _render_impl_patterns(args.package_name),
        skill_dir / "references" / "REVIEW_CHECKLIST.md": _render_review_checklist(
            f"packages/{args.package_name}/.agents/skills/{skill_name}/config",
            args.package_name,
        ),
        skill_dir / "agents" / "openai.yaml": _default_skill_yaml(skill_name, args.display_name, "OpenAPI"),
        creation_plan_path: _creation_plan(args.package_name, args.display_name, shortname, manifest),
        package_root / "LICENSE": license_content,
    }
    if args.spec_file:
        writes[spec_source_path] = json.dumps(spec_payload, indent=2) + "\n"
        writes[canonical_spec_path] = json.dumps(spec_payload, indent=2) + "\n"
    else:
        writes[canonical_spec_path] = json.dumps(spec_payload, indent=2) + "\n"

    directories = [
        package_root / "lib" / "src" / "client",
        package_root / "lib" / "src" / "models",
        package_root / "lib" / "src" / "resources",
        package_root / "lib" / "src" / "auth",
        package_root / "lib" / "src" / "interceptors",
        package_root / "lib" / "src" / "errors",
        package_root / "lib" / "src" / "extensions",
        package_root / "lib" / "src" / "utils",
        package_root / "test" / "unit",
        package_root / "test" / "integration",
        package_root / "example",
        specs_dir,
    ]

    if not args.dry_run:
        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
        for path, content in writes.items():
            _write_file(path, content)
        root_pubspec.write_text(updated_workspace)

    return EXIT_SUCCESS, {
        "command": "create",
        "package": args.package_name,
        "display_name": args.display_name,
        "package_root": str(package_root),
        "skill_dir": str(skill_dir),
        "creation_plan": str(creation_plan_path),
        "repo_root": str(repo_root),
        "dry_run": args.dry_run,
        "files": [str(path.relative_to(repo_root)) for path in sorted(writes)],
        "directories": [str(path.relative_to(repo_root)) for path in directories],
        "workspace_updated": True,
        "summary": {
            "type_count": len(manifest["types"]),
            "enum_count": sum(1 for entry in manifest["types"].values() if entry["kind"] == "enum"),
        },
    }


def command_fetch(args: Any) -> tuple[int, dict[str, Any]]:
    config = load_toolkit_config(args.config_dir)
    spec_name, spec = config.get_spec(args.spec_name)
    target = config.fetched_spec_path(spec_name)

    payload: dict[str, Any] = {
        "command": "fetch",
        "surface": config.manifest.surface,
        "spec_name": spec_name,
        "fetch_mode": spec.fetch_mode,
        "output": str(target),
        "dry_run": args.dry_run,
    }

    if args.preflight_only:
        payload["preflight"] = _preflight_payload(config, spec_name, spec)
        return EXIT_SUCCESS, payload

    if spec.fetch_mode == "remote":
        urls = [spec.url, *spec.fallback_urls]
        last_error = None
        document = None
        for url in [candidate for candidate in urls if candidate]:
            document, last_error = fetch_remote_document(url, get_api_key(spec), spec.resolved_auth)
            if document:
                payload["source_url"] = url
                break
        if not document:
            raise ToolkitError(f"Failed to fetch spec '{spec_name}': {last_error}")
        spec_payload = read_structured_text(
            document,
            source=payload.get("source_url") or spec.url or f"spec '{spec_name}'",
        )
        if not isinstance(spec_payload, dict):
            raise ToolkitError(f"Spec '{spec_name}' must parse to an object")
        if not args.dry_run:
            target.parent.mkdir(parents=True, exist_ok=True)
            write_json(target, spec_payload)
            if payload.get("source_url"):
                _write_spec_metadata(config, spec_name, spec_payload, payload["source_url"])
    elif spec.fetch_mode == "local_file":
        if not spec.source_file:
            raise ToolkitError(f"Spec '{spec_name}' uses fetch_mode=local_file but no source_file is configured")
        source = config.resolve_package_path(spec.source_file)
        spec_payload = _load_spec_payload(source)
        payload["source_file"] = str(source)
        if not args.dry_run:
            target.parent.mkdir(parents=True, exist_ok=True)
            write_json(target, spec_payload)
    else:
        raise ToolkitError(f"Unsupported fetch_mode '{spec.fetch_mode}'")

    if "spec_payload" not in locals():
        spec_payload = _load_spec_payload(target)
    payload["summary"] = _summarize_surface_payload(config.manifest.surface, spec_payload)
    return EXIT_SUCCESS, payload


def _summarize_surface_payload(surface: str, payload: dict[str, Any]) -> dict[str, Any]:
    if surface == "openapi":
        return {
            "endpoint_count": len(_extract_openapi_endpoints(payload)),
            "schema_count": len(payload.get("components", {}).get("schemas", {})),
            "version": payload.get("info", {}).get("version"),
            "title": payload.get("info", {}).get("title"),
        }
    message_types = payload.get("message_types", {})
    return {
        "client_message_count": len(message_types.get("client", {})),
        "server_message_count": len(message_types.get("server", {})),
        "config_type_count": len(payload.get("config_types", {})),
        "enum_count": len(payload.get("enums", {})),
        "version": payload.get("info", {}).get("version"),
        "title": payload.get("info", {}).get("title"),
    }


def command_describe(args: Any) -> tuple[int, dict[str, Any]]:
    config = load_toolkit_config(args.config_dir)
    selected_spec_name = _resolve_selected_spec_name(config, args.spec_name, type_name=args.type_name)
    spec_name, spec = config.get_spec(selected_spec_name)
    payload: dict[str, Any] = {
        "command": "describe",
        "surface": config.manifest.surface,
        "package": {
            "name": config.package.name,
            "display_name": config.package.display_name,
            "package_root": str(config.package_root),
            "config_dir": str(config.config_dir),
        },
        "roots": {
            "repo_root": str(config.repo_root),
            "package_root": str(config.package_root),
            "specs_dir": str(config.specs_dir),
            "output_dir": str(config.output_dir),
        },
        "specs": {
            name: {
                "name": item.name,
                "fetch_mode": item.fetch_mode,
                "local_file": item.local_file,
                "canonical_path": str(config.canonical_spec_path(name)),
                "fetched_path": str(config.fetched_spec_path(name)),
                "requires_auth": item.requires_auth,
                "auth_env_vars": item.auth_env_vars,
                "auth": asdict(item.auth) if item.auth else None,
                "audit": asdict(item.audit),
                "experimental": item.experimental,
                "websocket_endpoints": item.websocket_endpoints,
            }
            for name, item in config.specs.items()
        },
        "preflight": config.preflight,
        "placement": config.manifest.placement,
        "coverage": config.manifest.coverage,
        "types": {},
    }
    if args.type_name:
        entry = _resolve_entry(config, args.type_name, args.spec_name)
        payload["types"][entry.key] = asdict(entry)
    else:
        payload["types"] = {
            entry.key: asdict(entry)
            for entry in sorted(_entries_for_spec(config, spec_name), key=lambda item: item.key)
        }
    payload["selected_spec"] = {
        "name": spec_name,
        "description": spec.description,
        "fetch_mode": spec.fetch_mode,
        "experimental": spec.experimental,
        "websocket_endpoints": spec.websocket_endpoints,
    }
    return EXIT_SUCCESS, payload


def command_review(args: Any) -> tuple[int, dict[str, Any]]:
    config = load_toolkit_config(args.config_dir)
    spec_name, _ = config.get_spec(args.spec_name)
    old_payload, new_payload = _load_old_new_payloads(config, spec_name, baseline=args.baseline, git_ref=args.git_ref)
    new_schemas: dict[str, dict[str, Any]] = {}
    if config.manifest.surface == "openapi":
        diff = _compare_openapi(old_payload, new_payload)
        new_schemas = _extract_openapi_schemas(new_payload)
    else:
        diff = _compare_websocket(old_payload, new_payload)
    changed_names = _changed_type_names(config, diff)
    missing_manifest = [name for name in changed_names if not _manifest_keys_for_schema(config, name, spec_name)]
    actions = []
    for name in missing_manifest:
        schema_info = new_schemas.get(name)
        target = "enum" if (config.manifest.surface == "openapi" and schema_info and schema_info["enum_values"]) else "schema"
        if config.manifest.surface == "websocket":
            if name in new_payload.get("enums", {}):
                target = "enum"
            elif name in new_payload.get("config_types", {}):
                target = "config"
            else:
                target = "message"
        actions.append(
            f"Add manifest entry for `{name}` and scaffold it with `python3 .agents/shared/api-toolkit/scripts/api_toolkit.py scaffold --config-dir {config.config_dir.relative_to(config.repo_root)} --spec-name {spec_name} --target {target} --name {name}`"
        )

    verify_exit, verify_payload = _verify_implementation(
        config,
        spec_name,
        "changed",
        None,
        args.baseline,
        args.git_ref,
        spec_payload=new_payload,
        diff=diff,
    )
    issues = list(verify_payload["issues"])
    coverage_gaps = verify_payload.get("coverage_gaps", [])
    for name in missing_manifest:
        issues.append(_type_issue("error", name, "Changed type has no manifest entry"))
    if coverage_gaps:
        actions.append("Address resource coverage gaps before final verification.")
    if verify_exit == EXIT_FAILURE:
        actions.append("Fix implementation verification errors for changed types.")

    changelog_text = _emit_review_changelog(config, diff)
    plan_text = _emit_review_plan(config, actions, issues)
    if args.changelog_out:
        path = validate_output_path(args.changelog_out, config.allowed_output_roots())
        _write_file(path, changelog_text)
    if args.plan_out:
        path = validate_output_path(args.plan_out, config.allowed_output_roots())
        _write_file(path, plan_text)

    payload = {
        "command": "review",
        "surface": config.manifest.surface,
        "spec_name": spec_name,
        "diff": diff,
        "changed_types": changed_names,
        "missing_manifest_entries": missing_manifest,
        "coverage_gaps": coverage_gaps,
        "issues": issues,
        "actions": actions,
        "summary": {
            "changed_type_count": len(changed_names),
            "missing_manifest_count": len(missing_manifest),
            "error_count": sum(1 for issue in issues if issue["level"] == "error"),
            "warning_count": sum(1 for issue in issues if issue["level"] == "warning"),
        },
    }
    exit_code = EXIT_FAILURE if any(issue["level"] == "error" for issue in issues) else EXIT_SUCCESS
    return exit_code, payload


def command_scaffold(args: Any) -> tuple[int, dict[str, Any]]:
    config = load_toolkit_config(args.config_dir)
    spec_name = _resolve_selected_spec_name(
        config,
        args.spec_name,
        type_name=None if args.target == "barrel" else args.name,
    )
    if args.target == "barrel":
        source = _render_barrel(config, args.name)
        class_name = args.name
    else:
        source, class_name = _render_scaffold(config, args.target, spec_name, args.name)
    output_path = args.output
    if not output_path:
        entry = None
        if args.target != "barrel":
            matches = _lookup_entries(config, args.name, args.spec_name or spec_name)
            entry = matches[0] if matches else None
        if entry and entry.file:
            output_path = config.resolve_package_path(entry.file)
        elif args.target == "barrel":
            output_path = config.resolve_package_path(args.name)
        else:
            output_path = config.package_root / config.package.models_dir / "common" / f"{snake_case(class_name)}.dart"
    else:
        output_path = validate_output_path(output_path, config.allowed_output_roots())
    if not args.dry_run:
        _write_file(output_path, source)
    return EXIT_SUCCESS, {
        "command": "scaffold",
        "target": args.target,
        "name": args.name,
        "output": str(output_path),
        "dry_run": args.dry_run,
        "preview": source,
    }


def command_verify(args: Any) -> tuple[int, dict[str, Any]]:
    config = load_toolkit_config(args.config_dir)
    type_name = args.type_name if args.scope == "type" else None
    spec_name = _resolve_selected_spec_name(config, args.spec_name, type_name=type_name)
    checks = ["implementation", "exports", "docs"] if args.checks == "all" else [args.checks]

    results = {}
    exit_code = EXIT_SUCCESS
    for check in checks:
        if check == "implementation":
            result_exit, payload = _verify_implementation(
                config,
                spec_name,
                args.scope,
                args.type_name,
                args.baseline,
                args.git_ref,
            )
        elif check == "exports":
            result_exit, payload = _verify_exports(config)
        elif check == "docs":
            result_exit, payload = _verify_docs(config)
        else:  # pragma: no cover - argparse prevents this
            raise ToolkitError(f"Unsupported check '{check}'")
        results[check] = payload
        exit_code = max(exit_code, result_exit)

    payload = {
        "command": "verify",
        "checks": checks,
        "scope": args.scope,
        "results": results,
        "summary": {
            "warning_checks": [
                name
                for name, result in results.items()
                if any(issue.get("level") == "warning" for issue in result.get("issues", []))
            ],
            "failing_checks": [
                name
                for name, result in results.items()
                if any(
                    issue.get("level") == "error"
                    for issue in result.get("issues", [])
                ) or result.get("missing_exports")
            ]
        },
    }
    return exit_code, payload
