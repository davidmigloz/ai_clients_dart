from __future__ import annotations

import io
import json
import os
import tarfile
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in os.sys.path:
    os.sys.path.insert(0, str(ROOT))

from api_toolkit.config import ReferenceImplConfig, ReferenceSymbolConfig, ToolkitError
from api_toolkit.operations import (
    _ReferenceUnavailableError,
    _download_reference_repo,
    _extract_tar_safely,
    _load_reference_resources,
    _load_reference_types,
    _python_module,
    _reference_symbol_path,
    command_audit,
)


class AuditCommandTests(unittest.TestCase):
    def _create_openapi_config(self, root: Path, *, package_name: str = "sample_dart") -> tuple[Path, Path]:
        (root / "pubspec.yaml").write_text("name: workspace\nworkspace:\n  - packages/sample_dart\n")
        package_root = root / "packages" / package_name
        config_dir = package_root / ".agents" / "skills" / "openapi-sample" / "config"
        config_dir.mkdir(parents=True)
        (package_root / "pubspec.yaml").write_text(f"name: {package_name}\n")
        (package_root / "README.md").write_text("# Sample\n")
        (package_root / "example").mkdir(parents=True)
        (package_root / "specs").mkdir(parents=True)
        (package_root / "lib" / "src" / "models").mkdir(parents=True)
        (package_root / "lib" / "src" / "resources").mkdir(parents=True)
        (package_root / "lib" / f"{package_name}.dart").parent.mkdir(parents=True, exist_ok=True)
        (package_root / "lib" / f"{package_name}.dart").write_text("library;\n")
        (config_dir / "package.json").write_text(
            json.dumps(
                {
                    "name": package_name,
                    "display_name": "Sample",
                    "barrel_file": f"lib/{package_name}.dart",
                    "models_dir": "lib/src/models",
                    "resources_dir": "lib/src/resources",
                    "tests_dir": "test/unit/models",
                    "examples_dir": "example",
                    "skip_files": ["copy_with_sentinel.dart"],
                    "internal_barrel_files": [],
                    "pr_title_prefix": f"feat({package_name})",
                    "changelog_title": "Sample API Changelog",
                },
                indent=2,
            )
        )
        (config_dir / "documentation.json").write_text(
            json.dumps(
                {
                    "removed_apis": [],
                    "tool_properties": {},
                    "excluded_resources": [],
                    "resource_to_example": {},
                    "excluded_from_examples": [],
                    "drift_patterns": [],
                    "live_features": {},
                },
                indent=2,
            )
        )
        return package_root, config_dir

    def _write_config(
        self,
        config_dir: Path,
        spec_payload: dict[str, object],
        *,
        manifest_types: dict[str, object] | None = None,
        coverage: dict[str, object] | None = None,
        audit: dict[str, object] | None = None,
    ) -> None:
        specs_json = {
            "specs": {
                "main": {
                    "name": "Sample API",
                    "local_file": "openapi.json",
                    "fetch_mode": "local_file",
                    "source_file": "specs/openapi.json",
                    "audit": audit or {"excluded_schemas": [], "schema_aliases": {}},
                }
            },
            "specs_dir": "packages/sample_dart/specs",
            "output_dir": str(config_dir.parents[4] / "tmp" / "audit"),
        }
        (config_dir / "specs.json").write_text(json.dumps(specs_json, indent=2))
        (config_dir / "manifest.json").write_text(
            json.dumps(
                {
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": coverage or {},
                    "types": manifest_types or {},
                },
                indent=2,
            )
        )
        package_root = config_dir.parents[3]
        (package_root / "specs" / "openapi.json").write_text(json.dumps(spec_payload, indent=2))

    def _write_model(self, package_root: Path, relative_path: str, content: str) -> None:
        path = package_root / relative_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)

    def _write_resource(self, package_root: Path, relative_path: str, content: str) -> None:
        path = package_root / relative_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)

    def _create_reference_repo(self, root: Path) -> Path:
        (root / "src" / "openai" / "resources" / "responses").mkdir(parents=True)
        (root / "src" / "openai" / "types").mkdir(parents=True)
        (root / "google" / "genai" / "_interactions" / "types").mkdir(parents=True)
        (root / "google" / "genai").mkdir(parents=True, exist_ok=True)
        (root / "src" / "mistralai" / "client" / "models").mkdir(parents=True)
        (root / "ollama").mkdir(parents=True)
        (root / "chromadb" / "api" / "models").mkdir(parents=True)

        (root / "src" / "openai" / "resources" / "widgets.py").write_text(
            "class WidgetsResource(SyncAPIResource):\n"
            "    def create(self):\n"
            "        pass\n"
            "    def list(self):\n"
            "        pass\n"
            "\n"
            "class AsyncWidgetsResource(AsyncAPIResource):\n"
            "    def stream(self):\n"
            "        pass\n"
        )
        (root / "src" / "openai" / "resources" / "responses" / "responses.py").write_text(
            "class ResponsesResource(SyncAPIResource):\n"
            "    def create(self):\n"
            "        pass\n"
        )
        (root / "src" / "openai" / "types" / "__init__.py").write_text(
            "from .models import Widget, Gadget\n"
            "__all__ = ['Widget', 'Gadget']\n"
        )
        (root / "src" / "openai" / "types" / "responses" / "__init__.py").parent.mkdir(parents=True, exist_ok=True)
        (root / "src" / "openai" / "types" / "responses" / "__init__.py").write_text(
            "from .response import Response\n"
            "__all__ = ['Response']\n"
        )
        (root / "src" / "openai" / "types" / "models.py").write_text(
            "class Widget:\n"
            "    pass\n"
            "class Gadget:\n"
            "    pass\n"
        )
        (root / "src" / "openai" / "types" / "responses" / "response.py").write_text("class Response:\n    pass\n")

        (root / "client.py").write_text(
            "class Client:\n"
            "    _sub_sdk_map = {'chat': ChatSDK}\n"
            "\n"
            "    @property\n"
            "    def widgets(self) -> WidgetsClient:\n"
            "        return WidgetsClient(self)\n"
            "\n"
            "    def __init__(self):\n"
            "        self.files = FilesClient(self)\n"
            "\n"
            "    def generate(self):\n"
            "        pass\n"
            "\n"
            "class WidgetsClient:\n"
            "    def create(self):\n"
            "        pass\n"
            "    def list(self):\n"
            "        pass\n"
            "\n"
            "class FilesClient:\n"
            "    def upload(self):\n"
            "        pass\n"
            "\n"
            "class ChatSDK:\n"
            "    def complete(self):\n"
            "        pass\n"
        )
        (root / "types.py").write_text(
            "class Widget:\n"
            "    pass\n"
            "class _Internal:\n"
            "    pass\n"
        )
        (root / "models" / "top.py").parent.mkdir(parents=True, exist_ok=True)
        (root / "models" / "top.py").write_text("class TopLevel:\n    pass\n")
        (root / "models" / "nested" / "thing.py").parent.mkdir(parents=True, exist_ok=True)
        (root / "models" / "nested" / "thing.py").write_text("class NestedThing:\n    pass\n")
        return root

    def _audit_args(self, config_dir: Path, **overrides: object) -> SimpleNamespace:
        payload = {
            "config_dir": config_dir,
            "spec_name": None,
            "checks": "all",
            "scope": "all",
            "schema": None,
            "include_excluded": False,
            "format": "json",
            "fields": None,
        }
        payload.update(overrides)
        return SimpleNamespace(**payload)

    def test_schema_audit_matches_manifest_skip_and_from_json_keys(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_config(
                config_dir,
                {
                    "openapi": "3.1.0",
                    "info": {"title": "Sample", "version": "1"},
                    "paths": {
                        "/items": {
                            "get": {
                                "responses": {
                                    "200": {
                                        "description": "ok",
                                        "content": {"application/json": {"schema": {"$ref": "#/components/schemas/SkippedSchema"}}},
                                    }
                                }
                            }
                        }
                    },
                    "components": {
                        "schemas": {
                            "SkippedSchema": {
                                "type": "object",
                                "properties": {"display_name": {"type": "string"}},
                            }
                        }
                    },
                },
                manifest_types={
                    "SkippedSchema": {
                        "spec": "main",
                        "kind": "skip",
                        "dart_class": "SkippedModel",
                        "file": "lib/src/models/common/skipped_model.dart",
                        "schema": "SkippedSchema",
                    }
                },
            )
            self._write_model(
                package_root,
                "lib/src/models/common/skipped_model.dart",
                "class SkippedModel {\n"
                "  final String? displayName;\n"
                "  const SkippedModel({this.displayName});\n"
                "  factory SkippedModel.fromJson(Map<String, dynamic> json) => SkippedModel(\n"
                "    displayName: json['display_name'] as String?,\n"
                "  );\n"
                "}\n",
            )

            exit_code, payload = command_audit(self._audit_args(config_dir, checks="schema"))

            self.assertEqual(exit_code, 0)
            item = payload["results"]["schema"]["schemas"][0]
            self.assertEqual(item["status"], "matched")
            self.assertEqual(item["source"], "manifest")
            self.assertEqual(item["dart_class"], "SkippedModel")
            self.assertEqual(item["missing_properties"], [])

    def test_schema_audit_includes_nested_request_and_response_refs(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            _, config_dir = self._create_openapi_config(root)
            self._write_config(
                config_dir,
                {
                    "openapi": "3.1.0",
                    "info": {"title": "Sample", "version": "1"},
                    "paths": {
                        "/widgets": {
                            "post": {
                                "requestBody": {
                                    "content": {
                                        "application/json": {
                                            "schema": {
                                                "type": "object",
                                                "properties": {
                                                    "widget": {"$ref": "#/components/schemas/Widget"},
                                                },
                                            }
                                        }
                                    }
                                },
                                "responses": {
                                    "200": {
                                        "description": "ok",
                                        "content": {
                                            "application/json": {
                                                "schema": {
                                                    "oneOf": [
                                                        {"$ref": "#/components/schemas/ResultEnvelope"},
                                                        {
                                                            "type": "array",
                                                            "items": {"$ref": "#/components/schemas/Gadget"},
                                                        },
                                                    ]
                                                }
                                            }
                                        },
                                    }
                                },
                            }
                        }
                    },
                    "components": {
                        "schemas": {
                            "Widget": {"type": "object", "properties": {"id": {"type": "string"}}},
                            "Gadget": {"type": "object", "properties": {"id": {"type": "string"}}},
                            "ResultEnvelope": {"type": "object", "properties": {"id": {"type": "string"}}},
                        }
                    },
                },
            )

            exit_code, payload = command_audit(self._audit_args(config_dir, checks="schema"))

            self.assertEqual(exit_code, 0)
            self.assertEqual(
                {item["schema_name"] for item in payload["results"]["schema"]["schemas"]},
                {"Gadget", "ResultEnvelope", "Widget"},
            )

    def test_schema_audit_includes_parameter_only_schema_refs(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            _, config_dir = self._create_openapi_config(root)
            self._write_config(
                config_dir,
                {
                    "openapi": "3.1.0",
                    "info": {"title": "Sample", "version": "1"},
                    "paths": {
                        "/videos/{video_id}": {
                            "parameters": [
                                {"$ref": "#/components/parameters/VideoVariant"},
                            ],
                            "get": {
                                "parameters": [
                                    {
                                        "name": "order",
                                        "in": "query",
                                        "required": False,
                                        "schema": {"$ref": "#/components/schemas/OrderEnum"},
                                    },
                                ],
                                "responses": {"204": {"description": "ok"}},
                            },
                        }
                    },
                    "components": {
                        "parameters": {
                            "VideoVariant": {
                                "name": "variant",
                                "in": "query",
                                "required": False,
                                "schema": {"$ref": "#/components/schemas/VideoContentVariant"},
                            }
                        },
                        "schemas": {
                            "OrderEnum": {"type": "string", "enum": ["asc", "desc"]},
                            "VideoContentVariant": {"type": "string", "enum": ["mp4", "gif"]},
                        },
                    },
                },
            )

            exit_code, payload = command_audit(self._audit_args(config_dir, checks="schema"))

            self.assertEqual(exit_code, 0)
            self.assertEqual(
                {item["schema_name"] for item in payload["results"]["schema"]["schemas"]},
                {"OrderEnum", "VideoContentVariant"},
            )

    def test_schema_audit_applies_aliases_and_heuristics_and_marks_ambiguous_matches(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            package_root, config_dir = self._create_openapi_config(root)
            schema_names = ["AliasSchema", "SessionObject", "CreateWidgetRequest", "CreateWidgetResponse", "AmbiguousObject"]
            paths = {}
            for name in schema_names:
                paths[f"/{name.lower()}"] = {
                    "get": {
                        "responses": {
                            "200": {
                                "description": "ok",
                                "content": {"application/json": {"schema": {"$ref": f"#/components/schemas/{name}"}}},
                            }
                        }
                    }
                }
            self._write_config(
                config_dir,
                {
                    "openapi": "3.1.0",
                    "info": {"title": "Sample", "version": "1"},
                    "paths": paths,
                    "components": {
                        "schemas": {name: {"type": "object", "properties": {"id": {"type": "string"}}} for name in schema_names}
                    },
                },
                audit={"excluded_schemas": [], "schema_aliases": {"AliasSchema": "AliasedModel"}},
            )
            self._write_model(package_root, "lib/src/models/common/aliased_model.dart", "class AliasedModel { final String? id; const AliasedModel({this.id}); }\n")
            self._write_model(package_root, "lib/src/models/common/session.dart", "class Session { final String? id; const Session({this.id}); }\n")
            self._write_model(package_root, "lib/src/models/common/widget_request.dart", "class WidgetRequest { final String? id; const WidgetRequest({this.id}); }\n")
            self._write_model(package_root, "lib/src/models/common/widget_response.dart", "class WidgetResponse { final String? id; const WidgetResponse({this.id}); }\n")
            self._write_model(package_root, "lib/src/models/common/ambiguous_a.dart", "class Ambiguous { const Ambiguous(); }\n")
            self._write_model(package_root, "lib/src/models/other/ambiguous_b.dart", "class Ambiguous { const Ambiguous(); }\n")

            exit_code, payload = command_audit(self._audit_args(config_dir, checks="schema"))

            self.assertEqual(exit_code, 0)
            by_schema = {item["schema_name"]: item for item in payload["results"]["schema"]["schemas"]}
            self.assertEqual(by_schema["AliasSchema"]["source"], "schema_alias")
            self.assertEqual(by_schema["SessionObject"]["source"], "strip_object_suffix")
            self.assertEqual(by_schema["CreateWidgetRequest"]["source"], "create_request_transform")
            self.assertEqual(by_schema["CreateWidgetResponse"]["source"], "create_response_transform")
            self.assertEqual(by_schema["AmbiguousObject"]["status"], "ambiguous")

    def test_schema_audit_schema_filter_resolves_manifest_key_and_dart_class(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_config(
                config_dir,
                {
                    "openapi": "3.1.0",
                    "info": {"title": "Sample", "version": "1"},
                    "paths": {
                        "/objects": {
                            "get": {
                                "responses": {
                                    "200": {
                                        "description": "ok",
                                        "content": {"application/json": {"schema": {"$ref": "#/components/schemas/ActualSchema"}}},
                                    }
                                }
                            }
                        }
                    },
                    "components": {"schemas": {"ActualSchema": {"type": "object", "properties": {"id": {"type": "string"}}}}},
                },
                manifest_types={
                    "ManifestAlias": {
                        "spec": "main",
                        "kind": "object",
                        "dart_class": "ActualModel",
                        "file": "lib/src/models/common/actual_model.dart",
                        "schema": "ActualSchema",
                    }
                },
            )
            self._write_model(package_root, "lib/src/models/common/actual_model.dart", "class ActualModel { final String? id; const ActualModel({this.id}); }\n")

            for selector in ("ManifestAlias", "ActualModel"):
                exit_code, payload = command_audit(self._audit_args(config_dir, checks="schema", schema=selector))
                self.assertEqual(exit_code, 0)
                self.assertEqual(payload["results"]["schema"]["schema_filter"], "ActualSchema")
                self.assertEqual(len(payload["results"]["schema"]["schemas"]), 1)

    def test_schema_audit_skips_excluded_endpoint_only_schemas_unless_requested(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            _, config_dir = self._create_openapi_config(root)
            self._write_config(
                config_dir,
                {
                    "openapi": "3.1.0",
                    "info": {"title": "Sample", "version": "1"},
                    "paths": {
                        "/public": {
                            "get": {
                                "responses": {
                                    "200": {
                                        "description": "ok",
                                        "content": {"application/json": {"schema": {"$ref": "#/components/schemas/PublicSchema"}}},
                                    }
                                }
                            }
                        },
                        "/admin/private": {
                            "get": {
                                "responses": {
                                    "200": {
                                        "description": "ok",
                                        "content": {"application/json": {"schema": {"$ref": "#/components/schemas/SecretSchema"}}},
                                    }
                                }
                            }
                        },
                    },
                    "components": {
                        "schemas": {
                            "PublicSchema": {"type": "object", "properties": {"id": {"type": "string"}}},
                            "SecretSchema": {"type": "object", "properties": {"id": {"type": "string"}}},
                        }
                    },
                },
                coverage={"excluded_paths": ["^/admin"], "excluded_tags": []},
            )

            _, payload = command_audit(self._audit_args(config_dir, checks="schema"))
            self.assertEqual({item["schema_name"] for item in payload["results"]["schema"]["schemas"]}, {"PublicSchema"})

            _, payload = command_audit(self._audit_args(config_dir, checks="schema", include_excluded=True))
            self.assertEqual(
                {item["schema_name"] for item in payload["results"]["schema"]["schemas"]},
                {"PublicSchema", "SecretSchema"},
            )

    def test_reference_audit_reports_missing_methods_and_types(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            package_root, config_dir = self._create_openapi_config(root)
            reference_root = self._create_reference_repo(root / "reference")
            self._write_config(
                config_dir,
                {
                    "openapi": "3.1.0",
                    "info": {"title": "Sample", "version": "1"},
                    "paths": {},
                    "components": {"schemas": {}},
                },
                audit={
                    "excluded_schemas": [],
                    "schema_aliases": {},
                    "reference_impl": {
                        "repo": "openai/openai-python",
                        "ref": "main",
                        "resources": {"adapter": "python_stainless_resources", "path": "src/openai/resources"},
                        "types": {"adapter": "python_init_exports", "path": "src/openai/types/__init__.py"},
                    },
                },
            )
            self._write_resource(
                package_root,
                "lib/src/resources/widgets_resource.dart",
                "class WidgetsResource {\n"
                "  Future<void> create() async {}\n"
                "}\n",
            )
            self._write_model(package_root, "lib/src/models/common/widget.dart", "class Widget { const Widget(); }\n")

            with patch("api_toolkit.operations._download_reference_repo", return_value=(reference_root, reference_root)):
                exit_code, payload = command_audit(self._audit_args(config_dir, checks="reference"))

            self.assertEqual(exit_code, 0)
            result = payload["results"]["reference"]
            self.assertEqual(result["status"], "ok")
            self.assertIn("widgets", result["missing_methods"][0]["resource"])
            self.assertIn("list", result["missing_methods"][0]["methods"])
            self.assertIn("Gadget", result["missing_types"])

    def test_reference_audit_returns_unavailable_when_reference_repo_cannot_be_downloaded(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            _, config_dir = self._create_openapi_config(root)
            self._write_config(
                config_dir,
                {
                    "openapi": "3.1.0",
                    "info": {"title": "Sample", "version": "1"},
                    "paths": {},
                    "components": {"schemas": {}},
                },
                audit={
                    "excluded_schemas": [],
                    "schema_aliases": {},
                    "reference_impl": {
                        "repo": "openai/openai-python",
                        "ref": "main",
                        "resources": {"adapter": "python_stainless_resources", "path": "src/openai/resources"},
                    },
                },
            )

            with patch("api_toolkit.operations._download_reference_repo", side_effect=_ReferenceUnavailableError("offline")):
                exit_code, payload = command_audit(self._audit_args(config_dir, checks="reference"))

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["reference"]["status"], "unavailable")
            self.assertEqual(payload["summary"]["warning_count"], 1)

    def test_reference_audit_follows_conditional_export_resource_wrappers(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            package_root, config_dir = self._create_openapi_config(root)
            reference_root = self._create_reference_repo(root / "reference")
            self._write_config(
                config_dir,
                {
                    "openapi": "3.1.0",
                    "info": {"title": "Sample", "version": "1"},
                    "paths": {},
                    "components": {"schemas": {}},
                },
                audit={
                    "excluded_schemas": [],
                    "schema_aliases": {},
                    "reference_impl": {
                        "repo": "owner/repo",
                        "ref": "main",
                        "resources": {
                            "adapter": "python_client_members",
                            "path": "client.py",
                            "class_name": "Client",
                            "include": ["files"],
                        },
                    },
                },
            )
            self._write_resource(
                package_root,
                "lib/src/resources/files/files_resource.dart",
                "export 'files_resource_stub.dart' if (dart.library.io) 'files_resource_io.dart';\n",
            )
            self._write_resource(
                package_root,
                "lib/src/resources/files/files_resource_stub.dart",
                "class FilesResource {}\n",
            )
            self._write_resource(
                package_root,
                "lib/src/resources/files/files_resource_io.dart",
                "class FilesResource {\n"
                "  Future<void> upload() async {}\n"
                "}\n",
            )

            with patch("api_toolkit.operations._download_reference_repo", return_value=(reference_root, reference_root)):
                exit_code, payload = command_audit(self._audit_args(config_dir, checks="reference"))

            self.assertEqual(exit_code, 0)
            result = payload["results"]["reference"]
            self.assertEqual(result["missing_resources"], [])
            self.assertEqual(result["missing_methods"], [])

    def test_reference_stainless_adapter_preserves_scope_for_nested_resource_roots(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            reference_root = Path(tmp_dir) / "reference"
            base = reference_root / "src" / "openai" / "resources" / "responses"
            base.mkdir(parents=True)
            (base / "responses.py").write_text(
                "class ResponsesResource(SyncAPIResource):\n"
                "    def create(self):\n"
                "        pass\n"
            )
            (base / "input_items.py").write_text(
                "class InputItemsResource(SyncAPIResource):\n"
                "    def list(self):\n"
                "        pass\n"
            )

            mode, resources, _ = _load_reference_resources(
                reference_root,
                ReferenceImplConfig(
                    repo="owner/repo",
                    ref="main",
                    resources=ReferenceSymbolConfig(
                        adapter="python_stainless_resources",
                        path="src/openai/resources/responses",
                    ),
                ),
                {},
            )

            self.assertEqual(mode, "grouped")
            self.assertEqual(resources["responses"], {"create"})
            self.assertEqual(resources["responses_input_items"], {"list"})

    def test_reference_audit_tracks_hierarchical_resources_across_files(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            package_root, config_dir = self._create_openapi_config(root)
            reference_root = root / "reference"
            resources_root = reference_root / "src" / "openai" / "resources"
            (resources_root / "vector_stores").mkdir(parents=True)
            (resources_root / "beta" / "threads" / "runs").mkdir(parents=True)
            (resources_root / "files.py").write_text(
                "class FilesResource(SyncAPIResource):\n"
                "    def list(self):\n"
                "        pass\n"
            )
            (resources_root / "vector_stores.py").write_text(
                "class VectorStoresResource(SyncAPIResource):\n"
                "    def list(self):\n"
                "        pass\n"
            )
            (resources_root / "vector_stores" / "files.py").write_text(
                "class VectorStoreFilesResource(SyncAPIResource):\n"
                "    def retrieve(self):\n"
                "        pass\n"
            )
            (resources_root / "beta" / "threads" / "threads.py").write_text(
                "class ThreadsResource(SyncAPIResource):\n"
                "    def list(self):\n"
                "        pass\n"
            )
            (resources_root / "beta" / "threads" / "runs" / "runs.py").write_text(
                "class RunsResource(SyncAPIResource):\n"
                "    def create(self):\n"
                "        pass\n"
            )
            self._write_config(
                config_dir,
                {
                    "openapi": "3.1.0",
                    "info": {"title": "Sample", "version": "1"},
                    "paths": {},
                    "components": {"schemas": {}},
                },
                audit={
                    "excluded_schemas": [],
                    "schema_aliases": {},
                    "reference_impl": {
                        "repo": "openai/openai-python",
                        "ref": "main",
                        "resources": {"adapter": "python_stainless_resources", "path": "src/openai/resources"},
                    },
                },
            )
            self._write_resource(
                package_root,
                "lib/src/resources/files_resource.dart",
                "class FilesResource {\n"
                "  Future<void> list() async {}\n"
                "}\n",
            )
            self._write_resource(
                package_root,
                "lib/src/resources/vector_stores_resource.dart",
                "class VectorStoresResource {\n"
                "  VectorStoreFilesResource get files => VectorStoreFilesResource();\n"
                "  Future<void> list() async {}\n"
                "}\n"
                "\n"
                "class VectorStoreFilesResource {\n"
                "  Future<void> retrieve() async {}\n"
                "}\n",
            )
            self._write_resource(
                package_root,
                "lib/src/resources/beta_resource.dart",
                "class BetaResource {\n"
                "  ThreadsResource get threads => ThreadsResource();\n"
                "}\n",
            )
            self._write_resource(
                package_root,
                "lib/src/resources/threads_resource.dart",
                "class ThreadsResource {\n"
                "  RunsResource get runs => RunsResource();\n"
                "  Future<void> list() async {}\n"
                "}\n",
            )
            self._write_resource(
                package_root,
                "lib/src/resources/runs_resource.dart",
                "class RunsResource {\n"
                "  Future<void> create() async {}\n"
                "}\n",
            )

            with patch("api_toolkit.operations._download_reference_repo", return_value=(reference_root, reference_root)):
                exit_code, payload = command_audit(self._audit_args(config_dir, checks="reference"))

            self.assertEqual(exit_code, 0)
            result = payload["results"]["reference"]
            self.assertEqual(result["missing_resources"], [])
            self.assertEqual(result["missing_methods"], [])

    def test_reference_audit_does_not_require_local_spec_file(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_config(
                config_dir,
                {
                    "openapi": "3.1.0",
                    "info": {"title": "Sample", "version": "1"},
                    "paths": {},
                    "components": {"schemas": {}},
                },
                audit={
                    "excluded_schemas": [],
                    "schema_aliases": {},
                    "reference_impl": {
                        "repo": "openai/openai-python",
                        "ref": "main",
                        "resources": {"adapter": "python_stainless_resources", "path": "src/openai/resources"},
                    },
                },
            )
            (package_root / "specs" / "openapi.json").unlink()

            with patch("api_toolkit.operations._download_reference_repo", side_effect=_ReferenceUnavailableError("offline")):
                exit_code, payload = command_audit(self._audit_args(config_dir, checks="reference"))

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["reference"]["status"], "unavailable")

    def test_reference_audit_global_mode_includes_root_client_methods(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            package_root, config_dir = self._create_openapi_config(root)
            reference_root = root / "reference"
            reference_root.mkdir(parents=True)
            (reference_root / "client.py").write_text(
                "class Client:\n"
                "    def get_or_create_collection(self):\n"
                "        pass\n"
                "    def create_collection(self):\n"
                "        pass\n"
                "    def list_collections(self):\n"
                "        pass\n"
            )
            self._write_config(
                config_dir,
                {
                    "openapi": "3.1.0",
                    "info": {"title": "Sample", "version": "1"},
                    "paths": {},
                    "components": {"schemas": {}},
                },
                audit={
                    "excluded_schemas": [],
                    "schema_aliases": {},
                    "reference_impl": {
                        "repo": "owner/repo",
                        "ref": "main",
                        "resources": {
                            "adapter": "python_client_methods",
                            "path": "client.py",
                            "class_name": "Client",
                        },
                    },
                },
            )
            self._write_resource(
                package_root,
                "lib/src/client/sample_client.dart",
                "class SampleClient {\n"
                "  Future<void> getOrCreateCollection() async {}\n"
                "  Future<void> createCollection() async {}\n"
                "  Future<void> listCollections() async {}\n"
                "}\n",
            )

            with patch("api_toolkit.operations._download_reference_repo", return_value=(reference_root, reference_root)):
                exit_code, payload = command_audit(self._audit_args(config_dir, checks="reference"))

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["reference"]["missing_methods"], [])

    def test_reference_audit_global_mode_does_not_count_resource_methods_as_client_methods(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            package_root, config_dir = self._create_openapi_config(root)
            reference_root = root / "reference"
            reference_root.mkdir(parents=True)
            (reference_root / "client.py").write_text(
                "class Client:\n"
                "    def generate(self):\n"
                "        pass\n"
            )
            self._write_config(
                config_dir,
                {
                    "openapi": "3.1.0",
                    "info": {"title": "Sample", "version": "1"},
                    "paths": {},
                    "components": {"schemas": {}},
                },
                audit={
                    "excluded_schemas": [],
                    "schema_aliases": {},
                    "reference_impl": {
                        "repo": "owner/repo",
                        "ref": "main",
                        "resources": {
                            "adapter": "python_client_methods",
                            "path": "client.py",
                            "class_name": "Client",
                        },
                    },
                },
            )
            self._write_resource(
                package_root,
                "lib/src/resources/models_resource.dart",
                "class ModelsResource {\n"
                "  Future<void> generate() async {}\n"
                "}\n",
            )

            with patch("api_toolkit.operations._download_reference_repo", return_value=(reference_root, reference_root)):
                exit_code, payload = command_audit(self._audit_args(config_dir, checks="reference"))

            self.assertEqual(exit_code, 0)
            self.assertEqual(
                payload["results"]["reference"]["missing_methods"],
                [{"resource": "*", "methods": ["generate"]}],
            )

    def test_reference_adapters_cover_client_members_methods_and_type_collectors(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            reference_root = self._create_reference_repo(Path(tmp_dir) / "reference")
            from api_toolkit.operations import _python_class_index  # local import to avoid growing top-level imports

            class_index = _python_class_index(reference_root)
            mode, resources, _ = _load_reference_resources(
                reference_root,
                ReferenceImplConfig(
                    repo="owner/repo",
                    ref="main",
                    resources=ReferenceSymbolConfig(
                        adapter="python_client_members",
                        path="client.py",
                        class_name="Client",
                        member_map_name="_sub_sdk_map",
                    ),
                ),
                class_index,
            )
            self.assertEqual(mode, "grouped")
            self.assertIn("widgets", resources)
            self.assertIn("create", resources["widgets"])
            self.assertIn("chat", resources)
            self.assertIn("complete", resources["chat"])

            mode, global_methods, _ = _load_reference_resources(
                reference_root,
                ReferenceImplConfig(
                    repo="owner/repo",
                    ref="main",
                    resources=ReferenceSymbolConfig(
                        adapter="python_client_methods",
                        path="client.py",
                        class_name="Client",
                    ),
                ),
                class_index,
            )
            self.assertEqual(mode, "global")
            self.assertIn("generate", global_methods)

            exports = _load_reference_types(
                reference_root,
                ReferenceImplConfig(
                    repo="owner/repo",
                    ref="main",
                    types=ReferenceSymbolConfig(adapter="python_init_exports", path="src/openai/types/__init__.py"),
                ),
            )
            self.assertEqual(exports, {"Widget", "Gadget"})

            single_file = _load_reference_types(
                reference_root,
                ReferenceImplConfig(
                    repo="owner/repo",
                    ref="main",
                    types=ReferenceSymbolConfig(adapter="python_single_file_classes", path="types.py"),
                ),
            )
            self.assertEqual(single_file, {"Widget"})

            recursive = _load_reference_types(
                reference_root,
                ReferenceImplConfig(
                    repo="owner/repo",
                    ref="main",
                    types=ReferenceSymbolConfig(adapter="python_recursive_classes", path="models"),
                ),
            )
            self.assertEqual(recursive, {"TopLevel", "NestedThing"})

    def test_command_audit_all_returns_both_subchecks(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            package_root, config_dir = self._create_openapi_config(root)
            reference_root = self._create_reference_repo(root / "reference")
            self._write_config(
                config_dir,
                {
                    "openapi": "3.1.0",
                    "info": {"title": "Sample", "version": "1"},
                    "paths": {
                        "/widgets": {
                            "get": {
                                "responses": {
                                    "200": {
                                        "description": "ok",
                                        "content": {"application/json": {"schema": {"$ref": "#/components/schemas/Widget"}}},
                                    }
                                }
                            }
                        }
                    },
                    "components": {"schemas": {"Widget": {"type": "object", "properties": {"id": {"type": "string"}}}}},
                },
                audit={
                    "excluded_schemas": [],
                    "schema_aliases": {},
                    "reference_impl": {
                        "repo": "openai/openai-python",
                        "ref": "main",
                        "resources": {"adapter": "python_stainless_resources", "path": "src/openai/resources"},
                        "types": {"adapter": "python_init_exports", "path": "src/openai/types/__init__.py"},
                    },
                },
            )
            self._write_model(package_root, "lib/src/models/common/widget.dart", "class Widget { final String? id; const Widget({this.id}); }\n")
            self._write_resource(package_root, "lib/src/resources/widgets_resource.dart", "class WidgetsResource { Future<void> create() async {} }\n")

            with patch("api_toolkit.operations._download_reference_repo", return_value=(reference_root, reference_root)):
                exit_code, payload = command_audit(self._audit_args(config_dir, checks="all"))

            self.assertEqual(exit_code, 0)
            self.assertEqual(set(payload["results"]), {"schema", "reference"})

    def test_schema_audit_requires_spec_name_for_cross_spec_duplicates(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            package_root, config_dir = self._create_openapi_config(root)
            specs_json = {
                "specs": {
                    "main": {
                        "name": "Main API",
                        "local_file": "openapi.json",
                        "fetch_mode": "local_file",
                        "source_file": "specs/openapi.json",
                        "audit": {"excluded_schemas": [], "schema_aliases": {}},
                    },
                    "interactions": {
                        "name": "Interactions API",
                        "local_file": "interactions_openapi.json",
                        "fetch_mode": "local_file",
                        "source_file": "specs/interactions_openapi.json",
                        "audit": {"excluded_schemas": [], "schema_aliases": {}},
                    },
                },
                "specs_dir": "packages/sample_dart/specs",
                "output_dir": str(config_dir.parents[4] / "tmp" / "audit"),
            }
            (config_dir / "specs.json").write_text(json.dumps(specs_json, indent=2))
            (config_dir / "manifest.json").write_text(
                json.dumps(
                    {
                        "surface": "openapi",
                        "type_mappings": {},
                        "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                        "coverage": {},
                        "types": {
                            "Tool": {
                                "spec": "main",
                                "kind": "object",
                                "dart_class": "Tool",
                                "file": "lib/src/models/common/tool.dart",
                                "schema": "Tool",
                            },
                            "interactions:Tool": {
                                "spec": "interactions",
                                "kind": "object",
                                "dart_class": "InteractionTool",
                                "file": "lib/src/models/interactions/interaction_tool.dart",
                                "schema": "Tool",
                            },
                        },
                    },
                    indent=2,
                )
            )
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Main", "version": "1"},
                        "paths": {
                            "/tools": {
                                "get": {
                                    "responses": {
                                        "200": {
                                            "description": "ok",
                                            "content": {"application/json": {"schema": {"$ref": "#/components/schemas/Tool"}}},
                                        }
                                    }
                                }
                            }
                        },
                        "components": {"schemas": {"Tool": {"type": "object", "properties": {"id": {"type": "string"}}}}},
                    },
                    indent=2,
                )
            )
            (package_root / "specs" / "interactions_openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Interactions", "version": "1"},
                        "paths": {
                            "/interactions/tools": {
                                "get": {
                                    "responses": {
                                        "200": {
                                            "description": "ok",
                                            "content": {"application/json": {"schema": {"$ref": "#/components/schemas/Tool"}}},
                                        }
                                    }
                                }
                            }
                        },
                        "components": {"schemas": {"Tool": {"type": "object", "properties": {"id": {"type": "string"}}}}},
                    },
                    indent=2,
                )
            )
            self._write_model(package_root, "lib/src/models/common/tool.dart", "class Tool { final String? id; const Tool({this.id}); }\n")
            self._write_model(
                package_root,
                "lib/src/models/interactions/interaction_tool.dart",
                "class InteractionTool { final String? id; const InteractionTool({this.id}); }\n",
            )

            with self.assertRaisesRegex(ToolkitError, "ambiguous across specs"):
                command_audit(self._audit_args(config_dir, checks="schema", schema="Tool"))

            exit_code, payload = command_audit(
                self._audit_args(config_dir, checks="schema", spec_name="interactions", schema="Tool")
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["spec_name"], "interactions")
            self.assertEqual(payload["results"]["schema"]["schemas"][0]["dart_class"], "InteractionTool")

    def test_reference_types_from_init_exports_uses_all_when_named_imports_are_absent(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            reference_root = Path(tmp_dir) / "reference"
            types_dir = reference_root / "src" / "openai" / "types"
            types_dir.mkdir(parents=True)
            (types_dir / "__init__.py").write_text("__all__ = ['Widget', 'Gadget']\n")

            exports = _load_reference_types(
                reference_root,
                ReferenceImplConfig(
                    repo="owner/repo",
                    ref="main",
                    types=ReferenceSymbolConfig(adapter="python_init_exports", path="src/openai/types/__init__.py"),
                ),
            )

            self.assertEqual(exports, {"Widget", "Gadget"})

    def test_extract_tar_safely_rejects_path_traversal_members(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            archive_path = Path(tmp_dir) / "archive.tar.gz"
            with tarfile.open(archive_path, mode="w:gz") as tar:
                payload = b"owned"
                info = tarfile.TarInfo("../escape.txt")
                info.size = len(payload)
                tar.addfile(info, io.BytesIO(payload))

            with tempfile.TemporaryDirectory() as extract_dir:
                with tarfile.open(archive_path, mode="r:gz") as tar:
                    with self.assertRaises(_ReferenceUnavailableError):
                        _extract_tar_safely(tar, Path(extract_dir))

    def test_download_reference_repo_cleans_temp_root_when_safe_extract_fails(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            temp_root = Path(tmp_dir) / "download-root"
            temp_root.mkdir()
            archive = io.BytesIO()
            with tarfile.open(fileobj=archive, mode="w:gz") as tar:
                payload = b"ok"
                info = tarfile.TarInfo("reference-main/file.txt")
                info.size = len(payload)
                tar.addfile(info, io.BytesIO(payload))

            class _FakeResponse(io.BytesIO):
                def __enter__(self) -> "_FakeResponse":
                    return self

                def __exit__(self, exc_type, exc, tb) -> bool:
                    self.close()
                    return False

            with patch("api_toolkit.operations.tempfile.mkdtemp", return_value=str(temp_root)):
                with patch("api_toolkit.operations.urlopen", return_value=_FakeResponse(archive.getvalue())):
                    with patch("api_toolkit.operations._extract_tar_safely", side_effect=_ReferenceUnavailableError("blocked")):
                        with self.assertRaisesRegex(_ReferenceUnavailableError, "blocked"):
                            _download_reference_repo("owner/repo", "main")

            self.assertFalse(temp_root.exists())

    def test_extract_tar_safely_rejects_symlinks_in_fallback(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            archive_path = Path(tmp_dir) / "archive.tar.gz"
            with tarfile.open(archive_path, mode="w:gz") as tar:
                # Add a symlink member
                info = tarfile.TarInfo("link")
                info.type = tarfile.SYMTYPE
                info.linkname = "/etc/passwd"
                tar.addfile(info)
                # Add a regular file
                payload = b"safe"
                info = tarfile.TarInfo("safe.txt")
                info.size = len(payload)
                tar.addfile(info, io.BytesIO(payload))

            with tempfile.TemporaryDirectory() as extract_dir:
                extract_path = Path(extract_dir)
                with tarfile.open(archive_path, mode="r:gz") as tar:
                    # Simulate old Python without filter parameter
                    with patch.object(type(tar), "extractall", wraps=tar.extractall) as mock_extract:
                        # Remove 'filter' from signature to trigger fallback
                        import inspect
                        orig_sig = inspect.signature(tar.extractall)
                        fake_params = {k: v for k, v in orig_sig.parameters.items() if k != "filter"}
                        fake_sig = orig_sig.replace(parameters=fake_params.values())
                        with patch("api_toolkit.operations.inspect.signature", return_value=fake_sig):
                            _extract_tar_safely(tar, extract_path)
                    # Symlink should not have been extracted
                    self.assertFalse((extract_path / "link").exists())
                    # Regular file should have been extracted
                    self.assertTrue((extract_path / "safe.txt").exists())

    def test_reference_symbol_path_rejects_traversal(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            with self.assertRaises(ToolkitError):
                _reference_symbol_path(root, "../../etc/passwd")

    def test_reference_symbol_path_allows_valid_path(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            sub = root / "sub"
            sub.mkdir()
            result = _reference_symbol_path(root, "sub")
            self.assertEqual(result, sub.resolve())

    def test_python_module_wraps_file_errors(self) -> None:
        with self.assertRaises(ToolkitError):
            _python_module(Path("/nonexistent/path/module.py"))

    def test_python_module_wraps_syntax_errors(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            bad_file = Path(tmp_dir) / "bad.py"
            bad_file.write_text("def broken(:\n")
            with self.assertRaises(ToolkitError):
                _python_module(bad_file)


if __name__ == "__main__":
    unittest.main()
