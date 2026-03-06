from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
from collections import defaultdict
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .config import (
    AuthConfig,
    EXIT_FAILURE,
    EXIT_SUCCESS,
    EXIT_USAGE,
    DocumentationConfig,
    ManifestEntry,
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
    extract_method_body,
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
