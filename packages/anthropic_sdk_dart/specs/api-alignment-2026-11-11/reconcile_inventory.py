#!/usr/bin/env python3
"""Reconcile the November Claude inventory against a specific Git commit."""
import argparse
from collections import Counter, defaultdict
import hashlib
import io
import posixpath
import json
from pathlib import Path
import re
import subprocess
from functools import lru_cache

PACKAGE = "packages/anthropic_sdk_dart/"
INVENTORY = "specs/api-alignment-2026-11-11/inventory.json"
SPEC = "specs/openapi.yaml"
MANIFEST = ".agents/skills/openapi-anthropic/config/manifest.json"
METHODS = {"delete", "get", "head", "options", "patch", "post", "put", "trace"}
REPO_URL = "https://github.com/davidmigloz/ai_clients_dart"
DECLARATION = re.compile(r"\b(?:class|enum|mixin|extension|typedef) ([A-Z][A-Za-z0-9_]*)\b")
SIGNATURE = re.compile(r"^ {2}(?:static )?(?:Future|Stream)<([^;{}]*?)>\s+(\w+)\(", re.M)
ERROR_CARRIER = "lib/src/errors/exceptions.dart"
WEBHOOK = "lib/src/models/managed_agents/webhooks/webhook_event.dart"
LEGACY = {
    "BetaInputMessage": ("InputMessage", "lib/src/models/messages/input_message.dart",
                         "The beta input schema is a role-specific union in the candidate. Dart retains the public role-aware InputMessage carrier."),
    "InputMessage": ("InputMessage", "lib/src/models/messages/input_message.dart",
                     "The candidate uses a role-specific union. Dart retains InputMessage and validates its wire shape against the effective API version."),
    "CompletionRequest": ("CompletionRequest", "lib/src/models/completions/completion.dart",
                          "The deprecated endpoint is removed from the candidate. The public Dart DTO stays available."),
    "CompletionResponse": ("CompletionResponse", "lib/src/models/completions/completion.dart",
                           "The deprecated endpoint is removed from the candidate. The public Dart DTO stays available."),
    "CreateMessageParamsWithoutStream": ("MessageCreateRequest", "lib/src/models/messages/message_create_request.dart",
                                         "The upstream alias was removed. Dart keeps one request model for buffered and streamed Messages."),
}


class GitTree:
    def __init__(self, repo, commit):
        self.repo = repo
        self.repo = Path(self.git("rev-parse", "--show-toplevel").decode().strip())
        self.commit = self.git("rev-parse", "--verify", f"{commit}^{{commit}}").decode().strip()
        self.paths = {}
        for line in self.git("ls-tree", "-r", self.commit, "--", PACKAGE).decode().splitlines():
            entry, path = line.split("\t", 1)
            self.paths[path.removeprefix(PACKAGE)] = entry.split()[2]
        self.cache = {}

    def git(self, *args, input=None):
        return subprocess.run(
            ["git", "-C", str(self.repo), *args], input=input, stdout=subprocess.PIPE, check=True,
        ).stdout

    def read(self, path):
        if path not in self.cache:
            self.cache[path] = self.git("show", f"{self.commit}:{PACKAGE}{path}")
        return self.cache[path]

    def preload_sources(self):
        paths = [path for path in self.paths if path.startswith("lib/") and path.endswith(".dart")]
        data = self.git("cat-file", "--batch", input="".join(f"{self.paths[p]}\n" for p in paths).encode())
        reader = io.BytesIO(data)
        for path in paths:
            oid, kind, size = reader.readline().decode().split()
            if kind != "blob":
                raise ValueError((path, oid, kind))
            self.cache[path] = reader.read(int(size))
            if reader.read(1) != b"\n":
                raise ValueError(f"Unexpected git blob separator for {path}")

    @lru_cache(maxsize=None)
    def source_with_imports(self, path, depth=2):
        source = self.read(path).decode()
        if not depth:
            return source
        imports = [
            posixpath.normpath(posixpath.join(posixpath.dirname(path), name))
            for name in re.findall(r"^import '([^']+)'", source, re.M) if ":" not in name
        ]
        return "\n".join([
            source,
            *(self.source_with_imports(name, depth - 1) for name in imports if name in self.paths),
        ])

    def round_prs(self, baseline):
        by_number = {}
        by_file = defaultdict(set)
        raw = self.git(
            "log", "--first-parent", "--name-only", "--format=%x1e%H%x09%s",
            f"{baseline}..{self.commit}", "--", PACKAGE,
        ).decode()
        for entry in raw.split("\x1e"):
            lines = [line for line in entry.strip().splitlines() if line]
            if not lines:
                continue
            sha, title = lines[0].split("\t", 1)
            match = re.search(r"\(#(\d+)\)$", title)
            if not match:
                continue
            number = int(match[1])
            by_number[number] = {"commit": sha, "title": title, "url": f"{REPO_URL}/pull/{number}"}
            for path in lines[1:]:
                by_file[path.removeprefix(PACKAGE)].add(number)
        return by_number, by_file


def json_file(path):
    return json.loads(path.read_bytes())


def refs(value):
    if isinstance(value, dict):
        for child in value.values():
            yield from refs(child)
    elif isinstance(value, list):
        for child in value:
            yield from refs(child)
    elif isinstance(value, str) and value.startswith("#/components/schemas/"):
        yield value.rsplit("/", 1)[-1]


def operations(spec):
    return {
        (method.upper(), path): operation
        for path, methods in spec["paths"].items()
        for method, operation in methods.items() if method in METHODS
    }


def assert_fixed_inventory(inventory, spec, baseline):
    rows = inventory["operations"]
    expected = {(row["method"], row["path"]): (row["operation_id"], row["delta"]) for row in rows}
    candidate_operations = operations(spec)
    baseline_operations = operations(baseline)
    actual = {
        key: (operation["operationId"],
              "added" if key not in baseline_operations else
              "modified" if operation != baseline_operations[key] else "unchanged")
        for key, operation in candidate_operations.items()
    }
    actual.update({
        key: (baseline_operations[key]["operationId"], "removed")
        for key in baseline_operations.keys() - candidate_operations.keys()
    })
    if expected != actual or len(rows) != len(actual):
        raise ValueError("Candidate operation keys, operationId values or deltas differ from the planning inventory")
    old_schemas, new_schemas = baseline["components"]["schemas"], spec["components"]["schemas"]
    changed = {
        name: "added" if name not in old_schemas else "removed" if name not in new_schemas else "modified"
        for name in old_schemas.keys() | new_schemas.keys() if old_schemas.get(name) != new_schemas.get(name)
    }
    if changed != {row["schema"]: row["delta"] for row in inventory["schemas"]} or len(changed) != len(inventory["schemas"]):
        raise ValueError("Candidate changed schema keys differ from the planning inventory")
    old_webhooks, new_webhooks = baseline["webhooks"], spec["webhooks"]
    webhook_deltas = {
        name: "added" if name not in old_webhooks else "removed" if name not in new_webhooks else
        "modified" if old_webhooks[name] != new_webhooks[name] else "unchanged"
        for name in old_webhooks.keys() | new_webhooks.keys()
    }
    if webhook_deltas != {row["name"]: row["delta"] for row in inventory["webhooks"]} or len(webhook_deltas) != len(inventory["webhooks"]):
        raise ValueError("Candidate webhook keys or deltas differ from the planning inventory")
    http = {(row["method"], row["path"]) for row in inventory["http_only"]}
    if len(http) != 40 or len(inventory["http_only"]) != 40 or http & actual.keys():
        raise ValueError("HTTP-only inventory must contain 40 distinct operations outside the candidate")


def declarations(tree):
    result = defaultdict(list)
    for path, content in tree.cache.items():
        if not path.startswith("lib/"):
            continue
        source = content.decode()
        for match in DECLARATION.finditer(source):
            if source[source.rfind("\n", 0, match.start()) + 1:match.start()].lstrip().startswith("//"):
                continue
            result[match[1]].append({"file": path, "line": source.count("\n", 0, match.start()) + 1})
    return result


def member_signatures(tree, file, name, owner=None):
    if file not in tree.paths:
        return []
    source = tree.read(file).decode()
    classes = list(re.finditer(r"^(?:(?:final|sealed|abstract|base) )?class (\w+)\b", source, re.M))
    result = []
    for match in SIGNATURE.finditer(source):
        if match[2] != name:
            continue
        declaring_class = next((klass[1] for klass in reversed(classes) if klass.start() < match.start()), None)
        if owner and owner != declaring_class:
            continue
        result.append({
            "file": file, "line": source.count("\n", 0, match.start()) + 1,
            "symbol": name, "owner": declaring_class, "return_type": " ".join(match[1].split()),
        })
    return result


def class_line(tree, file, name):
    if not file or file not in tree.paths:
        return None
    source = tree.read(file).decode()
    match = re.search(rf"^[ \t]*(?:(?:final|sealed|abstract|base|interface)\s+)?(?:class|enum|mixin|extension|typedef)\s+{re.escape(name)}\b", source, re.M)
    return source.count("\n", 0, match.start()) + 1 if match else None


def props(schema, schemas, visited=frozenset()):
    result = dict(schema.get("properties", {}))
    for part in schema.get("allOf", []):
        ref = part.get("$ref", "").rsplit("/", 1)[-1]
        if ref and ref not in visited:
            result.update(props(schemas.get(ref, {}), schemas, visited | {ref}))
        else:
            result.update(part.get("properties", {}))
    return result


def merged_evidence(related, paths, prs, changed):
    evidenced = set(related)
    for path in paths:
        evidenced.update(changed.get(path, ()))
    return sorted(evidenced & prs.keys())


def http_only_wire_evidence(tree, declaration, fixtures, method, path):
    file = declaration["file"]
    symbol = declaration["symbol"]
    source = tree.read(file).decode()
    called_by_fixture = any(
        re.search(rf"\.{re.escape(symbol)}\s*\(", tree.read(fixture).decode())
        for fixture in fixtures
    )
    if not called_by_fixture:
        return False
    if path == "/v1/oauth/token":
        return (
            file == "lib/src/auth/workload_identity.dart"
            and symbol == "exchange" and method == "POST"
            and re.search(r"\}\) => _exchangeJwt\(", source) is not None
            and "http.AbortableRequest('POST', _url," in source
            and "path: '$prefix/v1/oauth/token'" in source
        )
    if not path.startswith("/v1/compliance/"):
        return False
    # The Compliance resource methods dispatch directly to shared HTTP helpers
    # with an explicit route literal. Match that literal within this method.
    source_from_method = "\n".join(source.splitlines()[declaration["line"] - 1:])
    member = re.split(r"\n {2}///|\n {2}(?:Future|Stream)<", source_from_method, maxsplit=1)[0]
    dispatch = re.search(
        r"\}\) => (?:_resource\.)?(_getPage|_get|_retrieve|_listTranscript|_download|_delete)"
        r"\(\s*((?:'[^']+'\s*)+),",
        member,
    )
    if not dispatch:
        return False
    actual_method = "DELETE" if dispatch[1] == "_delete" else "GET"
    literal = "".join(re.findall(r"'([^']+)'", dispatch[2]))
    actual_path = re.sub(r"\$\{_segment\(\w+\)\}", "{}", literal)
    expected_path = re.sub(r"\{[^{}]+\}", "{}", path.removeprefix("/v1/compliance/"))
    return actual_method == method and actual_path == expected_path


def route_result(row, plan, tree, prs, changed):
    method, path = row["method"], row.get("wire_path", row["path"])
    result = {
        "issue": row["issue"], "method": method, "path": path,
        **({"candidate_path": row["path"], "operation_id": row["operation_id"],
            "delta": row["delta"]} if "operation_id" in row else {}),
        "beta_required": row.get("beta_required", []),
    }
    if not plan:
        return {**result, "state": "needs_route_evidence"}
    file = plan["file"]
    fixtures = [p for p in plan.get("fixtures", []) if p in tree.paths]
    result.update(
        file=file, fixtures=fixtures,
        merged_prs=merged_evidence(plan.get("related_prs", []), [file, *fixtures], prs, changed),
    )
    if "source" in row:
        result["source"] = row["source"]
    for field in ("source", "note", "successor", "beta_required"):
        if field in plan:
            result[field] = plan[field]
    if plan.get("disposition"):
        return {**result, "state": plan["disposition"]}
    symbol = plan["symbol"]
    owner = plan.get("beta_owner", plan.get("owner")) if row["path"].endswith("?beta=true") else plan.get("owner")
    signatures = member_signatures(tree, file, symbol, owner)
    result["symbol"] = symbol
    if owner:
        result["owner"] = owner
    if len(signatures) == 1 and fixtures:
        if "operation_id" not in row:
            if not http_only_wire_evidence(tree, signatures[0], fixtures, method, path):
                return {
                    **result, "state": "needs_route_evidence",
                    "reason": "HTTP-only route does not match the public declaration and fixture call.",
                    "matching_declarations": signatures,
                }
            result["wire_evidence"] = "HTTP method, source route and public fixture call"
        return {**result, "state": "implemented", "declarations": signatures}
    if plan.get("pending_work") and (file not in tree.paths or not signatures or not fixtures):
        return {**result, "state": "pending_integration", "unblock": plan["pending_work"]}
    return {
        **result, "state": "needs_route_evidence",
        "reason": "Expected one public method declaration and an existing fixture in the selected commit.",
        "matching_declarations": signatures,
    }


def webhook_result(row, tree, prs, changed):
    name = row["name"]
    result = {"name": name, "issue": row["issue"], "delta": row["delta"], "file": WEBHOOK}
    source = tree.read(WEBHOOK).decode()
    dispatch = re.finditer(r"((?:'[^']+'\s*(?:\|\|\s*)?)+)=>\s*(\w+)\.fromJson\(", source)
    match = next((entry for entry in dispatch if f"'{name}'" in entry[1]), None)
    if not match:
        if name.startswith("user_profile."):
            return {
                **result, "state": "pending_integration",
                "unblock": "Merge the typed Organization webhook receiver and User Profiles event dispatch.",
            }
        return {**result, "state": "needs_webhook_evidence"}
    model = match[2]
    fixtures = [
        name for name in (
            "test/unit/models/webhook_event_test.dart",
            "test/unit/models/managed_agents/webhook_verification_test.dart",
            "test/unit/resources/organization_webhooks_test.dart",
        ) if name in tree.paths
    ]
    return {
        **result, "state": "implemented", "symbol": model,
        "line": source.count("\n", 0, match.start()) + 1,
        "fixtures": fixtures, "merged_prs": merged_evidence([], [WEBHOOK, *fixtures], prs, changed),
    }


def mapping_carrier(entries, tree, changed):
    carriers = []
    for key, entry in entries:
        file, model = entry.get("file"), entry.get("dart_class")
        if not file or not model or file not in tree.paths:
            continue
        line = class_line(tree, file, model)
        if line is None:
            continue
        carrier = {
            "mapping": key, "kind": entry["kind"], "file": file,
            "symbol": model, "line": line, "merged_prs": sorted(changed.get(file, [])),
        }
        if entry.get("note"):
            carrier["note"] = entry["note"]
        carriers.append(carrier)
    return carriers


def linked_schema_routes(spec):
    all_reachable = set()
    request_routes = defaultdict(list)
    response_routes = defaultdict(list)
    schemas = spec["components"]["schemas"]
    pending = []
    for (method, candidate_path), operation in operations(spec).items():
        key = f"{method} {candidate_path}"
        pending.extend(refs(operation))
        body = operation.get("requestBody", {}).get("content", {})
        for content in body.values():
            schema = content.get("schema", {})
            if "$ref" in schema:
                request_routes[schema["$ref"].rsplit("/", 1)[-1]].append(key)
        for status, response in operation.get("responses", {}).items():
            if not status.startswith("2"):
                continue
            for content in response.get("content", {}).values():
                schema = content.get("schema", {})
                if "$ref" in schema:
                    response_routes[schema["$ref"].rsplit("/", 1)[-1]].append(key)
    pending.extend(refs(spec.get("webhooks", {})))
    while pending:
        name = pending.pop()
        if name in all_reachable:
            continue
        all_reachable.add(name)
        pending.extend(refs(schemas.get(name, {})))
    return all_reachable, request_routes, response_routes


def absent_wire_fields(tree, files, fields):
    sources = "\n".join(tree.source_with_imports(file) for file in files)
    return sorted(name for name in fields if f"'{name}'" not in sources and f'"{name}"' not in sources)


def schema_result(row, tree, ctx):
    name = row["schema"]
    result = {"schema": name, "issue": row["issue"], "delta": row["delta"], "toolkit_delta": row["toolkit_delta"]}
    if row["delta"] == "removed":
        model, file, note = LEGACY[name]
        line = class_line(tree, file, model)
        state = "removed_schema_compatibility" if line else "needs_schema_evidence"
        return {**result, "state": state, "symbol": model, "file": file, "line": line, "note": note}
    schema = ctx["schemas"][name]
    if name in ctx["explicit"]:
        evidence = ctx["explicit"][name]
        file, model = evidence.get("file"), evidence.get("symbol")
        marker = evidence.get("source_marker")
        if file and (file not in tree.paths or (model and class_line(tree, file, model) is None)):
            state = "pending_integration" if evidence.get("unblock") else "needs_schema_evidence"
            return {**result, **evidence, "state": state}
        if marker and marker not in tree.read(file).decode():
            return {**result, **evidence, "state": "pending_integration"}
        if file:
            return {
                **result, **evidence,
                **({"line": class_line(tree, file, model)} if model else {}),
                "merged_prs": sorted(ctx["changed"].get(file, [])),
            }
        return {**result, **evidence}
    entries = ctx["mappings"].get(name, [])
    carriers = mapping_carrier(entries, tree, ctx["changed"])
    if carriers:
        return {**result, "state": "manifest_carrier", "carriers": carriers}
    prop_names = set(props(schema, ctx["schemas"]))
    if (name.endswith("ErrorDetails") and "error_code" in prop_names or name.endswith("ErrorResponse") and prop_names <= {"type", "error", "request_id"}) and ERROR_CARRIER in tree.paths:
        return {
            **result, "state": "shared_error_carrier", "file": ERROR_CARRIER, "symbol": "ApiException",
            "note": "Provider request IDs, code and diagnostic fields use the shared error parser and structured errorDetails.",
            "merged_prs": sorted(ctx["changed"].get(ERROR_CARRIER, [])),
        }
    short = name.removeprefix("Beta")
    if short != name or name.startswith("BetaManagedAgents"):
        alias = short
        alias_row = ctx["rows"].get(alias)
        if alias_row and alias_row.get("contract_sha256") == row.get("contract_sha256"):
            alias_carriers = mapping_carrier(ctx["mappings"].get(alias, []), tree, ctx["changed"])
            if alias_carriers:
                return {**result, "state": "verified_contract_alias", "schema_alias": alias, "carriers": alias_carriers}
    request_routes = sorted(set(ctx["requests"].get(name, [])))
    response_routes = sorted(set(ctx["responses"].get(name, [])))
    route_keys = sorted(set(request_routes + response_routes))
    eligible = [key for key in route_keys if ctx["routes"][key]["state"] == "implemented"]
    missing_fields = []
    if response_routes and all(key in eligible for key in response_routes):
        response_types = {
            re.match(r"[A-Za-z0-9]+", declaration["return_type"])[0]
            for key in response_routes for declaration in ctx["routes"][key].get("declarations", [])
        }
        if len(response_types) == 1:
            response_type = response_types.pop()
            if response_type in ctx["declarations"] and len(ctx["declarations"][response_type]) == 1:
                declaration = ctx["declarations"][response_type][0]
                missing_fields = absent_wire_fields(tree, [declaration["file"]], prop_names)
                if not missing_fields:
                    return {
                        **result, "state": "public_response_carrier", "symbol": response_type,
                        **declaration, "routes": response_routes, "wire_fields": sorted(prop_names),
                    }
    if request_routes and not response_routes and all(key in eligible for key in request_routes):
        files = {ctx["routes"][key]["file"] for key in request_routes}
        missing_fields = absent_wire_fields(tree, files, prop_names)
        if not missing_fields:
            return {
                **result, "state": "public_request_carrier", "routes": request_routes,
                "wire_fields": sorted(prop_names),
                "note": "The listed public arguments or typed request object carry the named wire body fields.",
            }
    if any(ctx["routes"][key]["state"] == "pending_integration" for key in route_keys):
        return {**result, "state": "pending_integration", "routes": route_keys}
    if entries and all(entry.get("file") and entry["file"] not in tree.paths for _, entry in entries):
        return {
            **result, "state": "pending_integration",
            "expected_files": sorted({entry["file"] for _, entry in entries}),
        }
    return {
        **result, "state": "needs_schema_evidence",
        "referenced_by": row.get("referenced_by", []), "reachable": name in ctx["reachable"],
        "routes": route_keys, "properties": sorted(prop_names),
        "unverified_mappings": [key for key, _ in entries],
        "unverified_wire_fields": missing_fields,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", type=Path, default=Path.cwd())
    parser.add_argument("--commit", default="origin/main")
    parser.add_argument("--integration-ref", default="origin/main", help="Integration history used to classify the selected commit.")
    parser.add_argument("--allow-prepared", action="store_true", help="Allow a scratch commit outside integration history and label its report accordingly.")
    parser.add_argument("--candidate", type=Path, help="Fixed candidate before promotion. Otherwise read the selected commit's canonical spec.")
    parser.add_argument("--manifest", type=Path, help="Prepared final manifest before its commit.")
    parser.add_argument("--overlay", type=Path, action="append", default=[], help="Additional manifest types dictionary; applies in order.")
    parser.add_argument("--evidence", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--require-complete", action="store_true", help="Fail if evidence or integration is outstanding.")
    args = parser.parse_args()

    tree = GitTree(args.repo, args.commit)
    integration_commit = tree.git("rev-parse", "--verify", f"{args.integration_ref}^{{commit}}").decode().strip()
    ancestry = subprocess.run(
        ["git", "-C", str(tree.repo), "merge-base", "--is-ancestor", tree.commit, integration_commit],
        check=False,
    )
    if ancestry.returncode not in (0, 1):
        ancestry.check_returncode()
    source_merged = ancestry.returncode == 0
    if not source_merged and not args.allow_prepared:
        parser.error("The selected commit is outside integration history. Pass --allow-prepared for a scratch report.")
    inventory = json.loads(tree.read(INVENTORY))
    raw_spec = args.candidate.read_bytes() if args.candidate else tree.read(SPEC)
    expected_sha = inventory["candidate_unpacked_sha256"]
    if hashlib.sha256(raw_spec).hexdigest() != expected_sha:
        raise ValueError("The candidate digest does not match the planned November source")
    spec = json.loads(raw_spec)
    baseline = inventory["repository_baseline"]
    old_spec = json.loads(tree.git("show", f"{baseline}:{PACKAGE}{SPEC}"))
    assert_fixed_inventory(inventory, spec, old_spec)
    manifest = json_file(args.manifest) if args.manifest else json.loads(tree.read(MANIFEST))
    for overlay in args.overlay:
        manifest["types"].update(json_file(overlay))
    evidence = json_file(args.evidence)
    tree.preload_sources()
    prs, changed = tree.round_prs(baseline)
    route_rows = inventory["operations"] + inventory["http_only"]
    routes_by_row = []
    for row in route_rows:
        wire_key = f'{row["method"]} {row.get("wire_path", row["path"])}'
        candidate_key = f'{row["method"]} {row["path"]}'
        plan = evidence["route_evidence"].get(wire_key, {})
        override = evidence.get("candidate_route_evidence", {}).get(candidate_key, {})
        routes_by_row.append(route_result(row, {**plan, **override}, tree, prs, changed))
    routes = {f'{row["method"]} {row.get("candidate_path", row["path"])}': row for row in routes_by_row}
    mappings = defaultdict(list)
    for key, entry in manifest["types"].items():
        mappings[entry.get("schema")].append((key, entry))
    reachable, requests, responses = linked_schema_routes(spec)
    context = {
        "schemas": spec["components"]["schemas"], "mappings": mappings, "routes": routes,
        "reachable": reachable, "requests": requests, "responses": responses,
        "declarations": declarations(tree), "changed": changed,
        "explicit": evidence.get("schema_evidence", {}),
        "rows": {row["schema"]: row for row in inventory["schemas"]},
    }
    result = {
        "source_commit": tree.commit, "integration_commit": integration_commit,
        "source_merged": source_merged, "candidate_sha256": expected_sha,
        "candidate_in_source_commit": args.candidate is None,
        "manifest_in_source_commit": args.manifest is None and not args.overlay,
        "effective_manifest_sha256": hashlib.sha256(json.dumps(manifest, sort_keys=True).encode()).hexdigest(),
        "audit_evidence_sha256": hashlib.sha256(args.evidence.read_bytes()).hexdigest(),
        "manifest_overlays": [path.name for path in args.overlay],
        "merged_pr_evidence": prs,
        "operations": routes_by_row[:len(inventory["operations"])],
        "schemas": [schema_result(row, tree, context) for row in inventory["schemas"]],
        "webhooks": [webhook_result(row, tree, prs, changed) for row in inventory["webhooks"]],
        "http_only": routes_by_row[len(inventory["operations"]):],
    }
    result["summary"] = {
        key: dict(Counter(row["state"] for row in result[key]))
        for key in ("operations", "schemas", "webhooks", "http_only")
    }
    args.output.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n")
    print(json.dumps(result["summary"], indent=2))
    if args.require_complete and any(
        key.startswith("needs_") or key == "pending_integration"
        for counts in result["summary"].values() for key in counts
    ):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
