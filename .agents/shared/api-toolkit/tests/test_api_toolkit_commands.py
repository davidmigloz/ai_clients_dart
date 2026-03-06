from __future__ import annotations

import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in os.sys.path:
    os.sys.path.insert(0, str(ROOT))

import api_toolkit.config as toolkit_config
import api_toolkit.operations as toolkit_operations
from api_toolkit.config import ToolkitError, load_toolkit_config
from api_toolkit.operations import (
    _verify_sealed_parent,
    command_create,
    command_describe,
    command_fetch,
    command_review,
    command_scaffold,
    command_verify,
)


class ApiToolkitCommandTests(unittest.TestCase):
    def _write_repo_license(self, root: Path) -> None:
        (root / "LICENSE").write_text("MIT License\n")

    def _write_workspace(self, root: Path) -> None:
        (root / "pubspec.yaml").write_text(
            "name: workspace\n"
            "workspace:\n"
            "  - packages/existing\n"
        )

    def _create_openapi_config(self, root: Path, *, package_name: str = "sample_dart") -> tuple[Path, Path]:
        package_root = root / "packages" / package_name
        config_dir = package_root / ".agents" / "skills" / "openapi-sample" / "config"
        config_dir.mkdir(parents=True)
        (package_root / "pubspec.yaml").write_text(f"name: {package_name}\n")
        (package_root / "lib").mkdir(exist_ok=True)
        (package_root / "lib" / f"{package_name}.dart").write_text("export 'src/models/common/example.dart';\n")
        (package_root / "lib" / "src" / "models" / "common").mkdir(parents=True)
        (package_root / "README.md").write_text("# Sample\n")
        (package_root / "example").mkdir()
        (package_root / "specs").mkdir()
        (package_root / "lib" / "src" / "resources").mkdir(parents=True)

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

    def _create_websocket_config(self, root: Path) -> tuple[Path, Path]:
        package_root = root / "packages" / "sample_ws_dart"
        config_dir = package_root / ".agents" / "skills" / "websocket-sample" / "config"
        config_dir.mkdir(parents=True)
        (package_root / "pubspec.yaml").write_text("name: sample_ws_dart\n")
        (package_root / "lib").mkdir(exist_ok=True)
        (package_root / "lib" / "sample_ws_dart.dart").write_text("export 'src/models/live/messages/client/client_message.dart';\n")
        (package_root / "lib" / "src" / "models" / "live" / "messages" / "client").mkdir(parents=True)
        (package_root / "lib" / "src" / "models" / "live" / "messages" / "server").mkdir(parents=True)
        (package_root / "lib" / "src" / "models" / "common").mkdir(parents=True)
        (package_root / "README.md").write_text("# Live Sample\n")
        (package_root / "example").mkdir()
        (package_root / "specs").mkdir()
        (package_root / "lib" / "src" / "resources").mkdir(parents=True)

        (config_dir / "package.json").write_text(
            json.dumps(
                {
                    "name": "sample_ws_dart",
                    "display_name": "Sample Live",
                    "barrel_file": "lib/sample_ws_dart.dart",
                    "models_dir": "lib/src/models",
                    "live_models_dir": "lib/src/models/live",
                    "resources_dir": "lib/src/resources",
                    "tests_dir": "test/unit/models",
                    "examples_dir": "example",
                    "skip_files": ["copy_with_sentinel.dart"],
                    "internal_barrel_files": [],
                    "pr_title_prefix": "feat(sample_ws_dart)",
                    "changelog_title": "Sample Live Changelog",
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
                    "resource_to_example": {"live": "live"},
                    "excluded_from_examples": [],
                    "drift_patterns": [
                        {"pattern": "session\\.text\\b", "message": "Use session.sendText() instead", "severity": "error"}
                    ],
                    "live_features": {
                        "liveClient": {"search_terms": ["live client", "liveclient", "websocket"]},
                        "toolCalling": {"search_terms": ["tool calling", "function calling"]},
                    },
                },
                indent=2,
            )
        )
        return package_root, config_dir

    def _write_specs_and_manifest(
        self,
        config_dir: Path,
        *,
        specs_payload: dict,
        manifest_payload: dict | None = None,
    ) -> None:
        (config_dir / "specs.json").write_text(json.dumps(specs_payload, indent=2))
        (config_dir / "manifest.json").write_text(
            json.dumps(
                manifest_payload
                or {
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {},
                },
                indent=2,
            )
        )

    def _write_model(
        self,
        path: Path,
        class_name: str,
        *,
        fields: list[tuple[str, str, bool]],
        include_copy_with: bool = True,
    ) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        lines = [f"class {class_name} {{"]
        for field_name, dart_type, nullable in fields:
            suffix = "?" if nullable else ""
            lines.append(f"  final {dart_type}{suffix} {field_name};")
        lines.append("")
        lines.append(f"  const {class_name}({{")
        for field_name, _, nullable in fields:
            qualifier = "" if nullable else "required "
            lines.append(f"    {qualifier}this.{field_name},")
        lines.append("  });")
        lines.append("")
        lines.append(f"  factory {class_name}.fromJson(Map<String, dynamic> json) => {class_name}(")
        for field_name, dart_type, nullable in fields:
            suffix = "?" if nullable else ""
            json_key = field_name
            lines.append(f"    {field_name}: json['{json_key}'] as {dart_type}{suffix},")
        lines.append("  );")
        lines.append("")
        lines.append("  Map<String, dynamic> toJson() => {")
        for field_name, _, nullable in fields:
            if nullable:
                lines.append(f"    if ({field_name} != null) '{field_name}': {field_name},")
            else:
                lines.append(f"    '{field_name}': {field_name},")
        lines.append("  };")
        if include_copy_with:
            lines.append("")
            lines.append(f"  {class_name} copyWith({{")
            for field_name, dart_type, _ in fields:
                lines.append(f"    {dart_type}? {field_name},")
            lines.append("  }) =>")
            lines.append(f"      {class_name}(")
            for field_name, _, _ in fields:
                lines.append(f"        {field_name}: {field_name} ?? this.{field_name},")
            lines.append("      );")
        lines.append("")
        lines.append("  @override")
        lines.append("  bool operator ==(Object other) =>")
        equality = " && ".join(
            [f"other is {class_name}", *(f"other.{field_name} == {field_name}" for field_name, _, _ in fields)]
        )
        lines.append(f"      identical(this, other) || ({equality});")
        lines.append("")
        lines.append("  @override")
        lines.append(f"  int get hashCode => Object.hash({', '.join(field_name for field_name, _, _ in fields)});")
        lines.append("")
        lines.append("  @override")
        joined = ", ".join(f"{field_name}: ${field_name}" for field_name, _, _ in fields)
        lines.append(f"  String toString() => '{class_name}({joined})';")
        lines.append("}")
        path.write_text("\n".join(lines) + "\n")

    def _create_multi_spec_config(self, root: Path) -> tuple[Path, Path, Path]:
        package_root, config_dir = self._create_openapi_config(root, package_name="multi_dart")
        output_dir = root / "tmp" / "multi"
        (package_root / "lib" / "src" / "models" / "interactions").mkdir(parents=True)
        (package_root / "specs" / "openapi.json").write_text(
            json.dumps(
                {
                    "openapi": "3.1.0",
                    "info": {"title": "Main", "version": "1"},
                    "paths": {},
                    "components": {
                        "schemas": {
                            "Tool": {
                                "type": "object",
                                "properties": {"id": {"type": "string"}},
                                "required": ["id"],
                            }
                        }
                    },
                }
            )
        )
        (package_root / "specs" / "openapi-interactions.json").write_text(
            json.dumps(
                {
                    "openapi": "3.1.0",
                    "info": {"title": "Interactions", "version": "1"},
                    "paths": {},
                    "components": {
                        "schemas": {
                            "Tool": {
                                "type": "object",
                                "properties": {"description": {"type": "string"}},
                                "required": ["description"],
                            }
                        }
                    },
                }
            )
        )
        self._write_specs_and_manifest(
            config_dir,
            specs_payload={
                "specs": {
                    "main": {"name": "Main", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"},
                    "interactions": {
                        "name": "Interactions",
                        "local_file": "openapi-interactions.json",
                        "fetch_mode": "local_file",
                        "source_file": "specs/openapi-interactions.json",
                        "experimental": True,
                    },
                },
                "specs_dir": "packages/multi_dart/specs",
                "output_dir": str(output_dir),
                "preflight": {"stats_url": "https://example.com/stats.yml", "stats_field": "openapi_spec_url"},
            },
            manifest_payload={
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
                        "file": "lib/src/models/interactions/tool.dart",
                        "schema": "Tool",
                    },
                },
            },
        )
        self._write_model(
            package_root / "lib" / "src" / "models" / "common" / "tool.dart",
            "Tool",
            fields=[("id", "String", False)],
        )
        self._write_model(
            package_root / "lib" / "src" / "models" / "interactions" / "tool.dart",
            "InteractionTool",
            fields=[("description", "String", False)],
        )
        return package_root, config_dir, output_dir

    def test_load_toolkit_config_resolves_roots_and_top_level_preflight(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {
                        "main": {
                            "name": "Sample API",
                            "local_file": "openapi.json",
                            "fetch_mode": "local_file",
                            "source_file": "specs/openapi.source.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                    "preflight": {"stats_url": "https://example.com/stats.yml", "stats_field": "openapi_spec_url"},
                },
            )

            config = load_toolkit_config(config_dir)
            self.assertEqual(config.repo_root.resolve(), root.resolve())
            self.assertEqual(config.package_root.resolve(), package_root.resolve())
            self.assertEqual(config.specs_dir.resolve(), (package_root / "specs").resolve())
            self.assertEqual(config.preflight["stats_url"], "https://example.com/stats.yml")

    def test_fetch_local_file_copies_source_to_output(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            source_spec = package_root / "specs" / "openapi.source.json"
            source_spec.write_text(json.dumps({"openapi": "3.1.0", "info": {"title": "Sample", "version": "1"}, "paths": {}, "components": {"schemas": {}}}))
            output_dir = root / "tmp" / "sample"
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {
                        "main": {
                            "name": "Sample API",
                            "local_file": "openapi.json",
                            "fetch_mode": "local_file",
                            "source_file": "specs/openapi.source.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
            )

            exit_code, payload = command_fetch(
                SimpleNamespace(config_dir=config_dir, spec_name=None, dry_run=False, preflight_only=False)
            )

            self.assertEqual(exit_code, 0)
            target = output_dir / "latest-main.json"
            self.assertTrue(target.exists())
            self.assertEqual(payload["summary"]["title"], "Sample")

    def test_fetch_preflight_reports_drift_without_writing_snapshot(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            specs_dir = package_root / "specs"
            (specs_dir / "spec_metadata.json").write_text(
                json.dumps(
                    {
                        "specs": {
                            "main": {
                                "title": "Sample",
                                "current_version": "1.2.3",
                                "last_fetched": "2026-03-01T00:00:00Z",
                                "source_url": "https://storage.example.com/openapi-oldhash123456.json",
                                "version_history": [],
                            }
                        }
                    }
                )
            )
            output_dir = root / "tmp" / "sample"
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {
                        "main": {
                            "name": "Sample API",
                            "local_file": "openapi.json",
                            "fetch_mode": "remote",
                            "url": "https://storage.example.com/openapi-pinnedabc123456.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                    "preflight": {"stats_url": "https://example.com/stats.yml", "stats_field": "openapi_spec_url"},
                },
            )

            with patch(
                "api_toolkit.operations.fetch_remote_document",
                return_value=("openapi_spec_url: https://storage.example.com/openapi-latestdef654321.json\n", None),
            ):
                exit_code, payload = command_fetch(
                    SimpleNamespace(config_dir=config_dir, spec_name=None, dry_run=False, preflight_only=True)
                )

            self.assertEqual(exit_code, 0)
            self.assertFalse(output_dir.exists())
            self.assertEqual(payload["preflight"]["status"], "ok")
            self.assertTrue(payload["preflight"]["configured"])
            self.assertTrue(payload["preflight"]["online"])
            self.assertTrue(payload["preflight"]["outdated"])
            self.assertEqual(payload["preflight"]["current_version"], "1.2.3")
            self.assertEqual(
                payload["preflight"]["current_source_url"],
                "https://storage.example.com/openapi-oldhash123456.json",
            )
            self.assertFalse((output_dir / "latest-main.json").exists())

    def test_fetch_preflight_stats_request_does_not_require_auth(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            (package_root / "specs" / "spec_metadata.json").write_text(
                json.dumps(
                    {
                        "specs": {
                            "main": {
                                "title": "Sample",
                                "current_version": "1.2.3",
                                "last_fetched": "2026-03-01T00:00:00Z",
                                "source_url": "https://storage.example.com/openapi-oldhash123456.json",
                                "version_history": [],
                            }
                        }
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {
                        "main": {
                            "name": "Sample API",
                            "local_file": "openapi.json",
                            "fetch_mode": "remote",
                            "url": "https://storage.example.com/openapi-pinnedabc123456.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                    "preflight": {"stats_url": "https://example.com/stats.yml", "stats_field": "openapi_spec_url"},
                },
            )

            def fake_fetch(url: str, api_key: str | None, auth: toolkit_config.AuthConfig | None) -> tuple[str | None, str | None]:
                self.assertEqual(url, "https://example.com/stats.yml")
                self.assertIsNone(api_key)
                self.assertIsNone(auth)
                return ("openapi_spec_url: https://storage.example.com/openapi-latestdef654321.json\n", None)

            with patch("api_toolkit.operations.fetch_remote_document", side_effect=fake_fetch) as fetch_mock:
                exit_code, payload = command_fetch(
                    SimpleNamespace(config_dir=config_dir, spec_name=None, dry_run=False, preflight_only=True)
                )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["preflight"]["status"], "ok")
            fetch_mock.assert_called_once()

    def test_fetch_preflight_offline_is_non_failing(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "remote", "url": "https://example.com/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                    "preflight": {"stats_url": "https://example.com/stats.yml", "stats_field": "openapi_spec_url"},
                },
            )

            with patch("api_toolkit.operations.fetch_remote_document", return_value=(None, "Network error: offline")):
                exit_code, payload = command_fetch(
                    SimpleNamespace(config_dir=config_dir, spec_name=None, dry_run=False, preflight_only=True)
                )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["preflight"]["status"], "offline")
            self.assertFalse(payload["preflight"]["online"])

    def test_fetch_yaml_without_pyyaml_raises_toolkit_error_with_source(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            _, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {
                        "main": {
                            "name": "Sample API",
                            "local_file": "openapi.yaml",
                            "fetch_mode": "remote",
                            "url": "https://example.com/openapi.yaml",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )

            with (
                patch(
                    "api_toolkit.operations.fetch_remote_document",
                    return_value=(
                        "openapi: 3.1.0\ninfo:\n  title: Sample\n  version: '1'\npaths: {}\ncomponents:\n  schemas: {}\n",
                        None,
                    ),
                ),
                patch.object(toolkit_config, "HAS_YAML", False),
                patch.object(toolkit_config, "yaml", None),
            ):
                with self.assertRaises(ToolkitError) as ctx:
                    command_fetch(
                        SimpleNamespace(
                            config_dir=config_dir,
                            spec_name=None,
                            dry_run=False,
                            preflight_only=False,
                        )
                    )

            message = str(ctx.exception)
            self.assertIn("https://example.com/openapi.yaml", message)
            self.assertIn("pip install pyyaml --user", message)

    def test_read_git_file_parses_json_from_git_ref(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            repo_root = Path(tmp_dir)
            spec_path = repo_root / "packages" / "sample_dart" / "specs" / "openapi.json"
            spec_path.parent.mkdir(parents=True)
            spec_path.write_text(json.dumps({"openapi": "3.1.0", "info": {"title": "Sample", "version": "1"}}))
            subprocess.run(["git", "init"], cwd=repo_root, check=True, capture_output=True, text=True)
            subprocess.run(["git", "config", "user.name", "Test User"], cwd=repo_root, check=True, capture_output=True, text=True)
            subprocess.run(["git", "config", "user.email", "test@example.com"], cwd=repo_root, check=True, capture_output=True, text=True)
            subprocess.run(["git", "add", "."], cwd=repo_root, check=True, capture_output=True, text=True)
            subprocess.run(["git", "commit", "-m", "init"], cwd=repo_root, check=True, capture_output=True, text=True)

            payload = toolkit_operations._read_git_file(repo_root, "HEAD", spec_path)

            self.assertEqual(payload["info"]["title"], "Sample")

    def test_read_git_file_parses_yaml_from_git_ref(self) -> None:
        if not toolkit_config.HAS_YAML:
            self.skipTest("PyYAML not available")
        with tempfile.TemporaryDirectory() as tmp_dir:
            repo_root = Path(tmp_dir)
            spec_path = repo_root / "packages" / "sample_dart" / "specs" / "openapi.yaml"
            spec_path.parent.mkdir(parents=True)
            spec_path.write_text("openapi: 3.1.0\ninfo:\n  title: Sample\n  version: '1'\n")
            subprocess.run(["git", "init"], cwd=repo_root, check=True, capture_output=True, text=True)
            subprocess.run(["git", "config", "user.name", "Test User"], cwd=repo_root, check=True, capture_output=True, text=True)
            subprocess.run(["git", "config", "user.email", "test@example.com"], cwd=repo_root, check=True, capture_output=True, text=True)
            subprocess.run(["git", "add", "."], cwd=repo_root, check=True, capture_output=True, text=True)
            subprocess.run(["git", "commit", "-m", "init"], cwd=repo_root, check=True, capture_output=True, text=True)

            payload = toolkit_operations._read_git_file(repo_root, "HEAD", spec_path)

            self.assertEqual(payload["info"]["title"], "Sample")

    def test_read_git_file_reports_invalid_git_ref(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            repo_root = Path(tmp_dir)
            spec_path = repo_root / "packages" / "sample_dart" / "specs" / "openapi.json"
            spec_path.parent.mkdir(parents=True)
            spec_path.write_text(json.dumps({"openapi": "3.1.0"}))
            subprocess.run(["git", "init"], cwd=repo_root, check=True, capture_output=True, text=True)
            subprocess.run(["git", "config", "user.name", "Test User"], cwd=repo_root, check=True, capture_output=True, text=True)
            subprocess.run(["git", "config", "user.email", "test@example.com"], cwd=repo_root, check=True, capture_output=True, text=True)
            subprocess.run(["git", "add", "."], cwd=repo_root, check=True, capture_output=True, text=True)
            subprocess.run(["git", "commit", "-m", "init"], cwd=repo_root, check=True, capture_output=True, text=True)

            with self.assertRaises(ToolkitError) as ctx:
                toolkit_operations._read_git_file(repo_root, "missing-ref", spec_path)

            self.assertIn("Unable to read", str(ctx.exception))

    def test_read_git_file_reports_invalid_yaml_without_broad_exception_masking(self) -> None:
        if not toolkit_config.HAS_YAML:
            self.skipTest("PyYAML not available")
        with tempfile.TemporaryDirectory() as tmp_dir:
            repo_root = Path(tmp_dir)
            spec_path = repo_root / "packages" / "sample_dart" / "specs" / "openapi.yaml"
            spec_path.parent.mkdir(parents=True)
            spec_path.write_text("openapi: [\n")
            subprocess.run(["git", "init"], cwd=repo_root, check=True, capture_output=True, text=True)
            subprocess.run(["git", "config", "user.name", "Test User"], cwd=repo_root, check=True, capture_output=True, text=True)
            subprocess.run(["git", "config", "user.email", "test@example.com"], cwd=repo_root, check=True, capture_output=True, text=True)
            subprocess.run(["git", "add", "."], cwd=repo_root, check=True, capture_output=True, text=True)
            subprocess.run(["git", "commit", "-m", "init"], cwd=repo_root, check=True, capture_output=True, text=True)

            with self.assertRaises(ToolkitError) as ctx:
                toolkit_operations._read_git_file(repo_root, "HEAD", spec_path)

            self.assertIn("Failed to parse", str(ctx.exception))

    def test_remote_fetch_updates_spec_metadata(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            specs_dir = package_root / "specs"
            output_dir = root / "tmp" / "sample"
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {
                        "main": {
                            "name": "Sample API",
                            "local_file": "openapi.json",
                            "fetch_mode": "remote",
                            "url": "https://storage.example.com/openapi-newhashabc123456.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
            )
            (specs_dir / "spec_metadata.json").write_text(
                json.dumps(
                    {
                        "specs": {
                            "main": {
                                "title": "Sample",
                                "current_version": "1.0.0",
                                "last_fetched": "2026-03-01T00:00:00Z",
                                "source_url": "https://storage.example.com/openapi-oldhashabc123456.json",
                                "version_history": [],
                            }
                        }
                    }
                )
            )

            with patch(
                "api_toolkit.operations.fetch_remote_document",
                return_value=(
                    json.dumps({"openapi": "3.1.0", "info": {"title": "Sample", "version": "2.0.0"}, "paths": {}, "components": {"schemas": {}}}),
                    None,
                ),
            ):
                exit_code, _ = command_fetch(
                    SimpleNamespace(config_dir=config_dir, spec_name=None, dry_run=False, preflight_only=False)
                )

            self.assertEqual(exit_code, 0)
            metadata = json.loads((specs_dir / "spec_metadata.json").read_text())
            main = metadata["specs"]["main"]
            self.assertEqual(main["current_version"], "2.0.0")
            self.assertEqual(main["source_url"], "https://storage.example.com/openapi-newhashabc123456.json")
            self.assertEqual(main["version_history"][0]["version"], "1.0.0")

    def test_review_reports_unmapped_changed_schema(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            specs_dir = package_root / "specs"
            output_dir = root / "tmp" / "sample"
            output_dir.mkdir(parents=True)
            old_spec = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "1"},
                "paths": {},
                "components": {"schemas": {"Existing": {"type": "object", "properties": {"id": {"type": "string"}}}}},
            }
            new_spec = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "2"},
                "paths": {},
                "components": {
                    "schemas": {
                        "Existing": {"type": "object", "properties": {"id": {"type": "string"}}},
                        "NewType": {"type": "object", "properties": {"name": {"type": "string"}}},
                    }
                },
            }
            (specs_dir / "openapi.json").write_text(json.dumps(old_spec))
            (output_dir / "latest-main.json").write_text(json.dumps(new_spec))
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {
                        "main": {
                            "name": "Sample API",
                            "local_file": "openapi.json",
                            "fetch_mode": "local_file",
                            "source_file": "specs/openapi.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
            )

            exit_code, payload = command_review(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    baseline=None,
                    git_ref=None,
                    changelog_out=None,
                    plan_out=None,
                )
            )
            self.assertEqual(exit_code, toolkit_config.EXIT_FAILURE)
            self.assertEqual(payload["missing_manifest_entries"], ["NewType"])
            self.assertGreaterEqual(payload["summary"]["error_count"], 1)
            self.assertTrue(any(issue["level"] == "error" for issue in payload["issues"]))

    def test_review_handles_circular_top_level_refs(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            specs_dir = package_root / "specs"
            output_dir = root / "tmp" / "sample"
            output_dir.mkdir(parents=True)
            old_spec = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "1"},
                "paths": {},
                "components": {"schemas": {}},
            }
            new_spec = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "2"},
                "paths": {},
                "components": {
                    "schemas": {
                        "LoopA": {"allOf": [{"$ref": "#/components/schemas/LoopB"}]},
                        "LoopB": {"allOf": [{"$ref": "#/components/schemas/LoopA"}]},
                    }
                },
            }
            (specs_dir / "openapi.json").write_text(json.dumps(old_spec))
            (output_dir / "latest-main.json").write_text(json.dumps(new_spec))
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {
                        "main": {
                            "name": "Sample API",
                            "local_file": "openapi.json",
                            "fetch_mode": "local_file",
                            "source_file": "specs/openapi.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
            )

            exit_code, payload = command_review(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    baseline=None,
                    git_ref=None,
                    changelog_out=None,
                    plan_out=None,
                )
            )

            self.assertEqual(exit_code, toolkit_config.EXIT_FAILURE)
            self.assertEqual(payload["missing_manifest_entries"], ["LoopA", "LoopB"])

    def test_review_reuses_loaded_payloads_and_extracted_openapi_schemas_for_missing_enum_entries(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            specs_dir = package_root / "specs"
            output_dir = root / "tmp" / "sample"
            output_dir.mkdir(parents=True)
            old_spec = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "1"},
                "paths": {},
                "components": {"schemas": {}},
            }
            new_spec = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "2"},
                "paths": {},
                "components": {
                    "schemas": {
                        "NewState": {"type": "string", "enum": ["active", "paused"]},
                    }
                },
            }
            (specs_dir / "openapi.json").write_text(json.dumps(old_spec))
            (output_dir / "latest-main.json").write_text(json.dumps(new_spec))
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {
                        "main": {
                            "name": "Sample API",
                            "local_file": "openapi.json",
                            "fetch_mode": "local_file",
                            "source_file": "specs/openapi.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
            )

            with patch(
                "api_toolkit.operations._load_old_new_payloads",
                wraps=toolkit_operations._load_old_new_payloads,
            ) as load_payloads:
                with patch(
                    "api_toolkit.operations._extract_openapi_schemas",
                    wraps=toolkit_operations._extract_openapi_schemas,
                ) as extract_schemas:
                    exit_code, payload = command_review(
                        SimpleNamespace(
                            config_dir=config_dir,
                            spec_name=None,
                            baseline=None,
                            git_ref=None,
                            changelog_out=None,
                            plan_out=None,
                        )
                    )

            self.assertEqual(exit_code, toolkit_config.EXIT_FAILURE)
            self.assertEqual(payload["missing_manifest_entries"], ["NewState"])
            self.assertTrue(any("--target enum --name NewState" in action for action in payload["actions"]))
            self.assertEqual(load_payloads.call_count, 1)
            self.assertEqual(extract_schemas.call_count, 3)

    def test_review_spec_name_only_checks_selected_spec(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir, output_dir = self._create_multi_spec_config(root)
            output_dir.mkdir(parents=True)
            (output_dir / "latest-interactions.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Interactions", "version": "2"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "Tool": {
                                    "type": "object",
                                    "properties": {
                                        "description": {"type": "string"},
                                        "state": {"type": "string"},
                                    },
                                    "required": ["description"],
                                }
                            }
                        },
                    }
                )
            )

            exit_code, payload = command_review(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name="interactions",
                    baseline=None,
                    git_ref=None,
                    changelog_out=None,
                    plan_out=None,
                )
            )

            self.assertEqual(exit_code, toolkit_config.EXIT_FAILURE)
            self.assertEqual(payload["spec_name"], "interactions")
            self.assertTrue(
                all("--spec-name interactions" in action for action in payload["actions"] if "scaffold" in action)
            )

    def test_describe_spec_name_filters_multi_spec_entries(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            _, config_dir, _ = self._create_multi_spec_config(root)

            exit_code, payload = command_describe(
                SimpleNamespace(config_dir=config_dir, spec_name="interactions", type_name=None)
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(set(payload["types"]), {"interactions:Tool"})
            self.assertTrue(payload["selected_spec"]["experimental"])

    def test_scaffold_without_spec_name_uses_exact_manifest_key(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            _, config_dir, _ = self._create_multi_spec_config(root)

            exit_code, payload = command_scaffold(
                SimpleNamespace(
                    config_dir=config_dir,
                    target="schema",
                    name="Tool",
                    spec_name=None,
                    output=None,
                    dry_run=True,
                )
            )

            self.assertEqual(exit_code, 0)
            self.assertIn("class Tool", payload["preview"])
            self.assertTrue(payload["output"].endswith("lib/src/models/common/tool.dart"))

    def test_scaffold_uses_manifest_schema_name_when_lookup_happens_by_dart_class(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "SchemaKey": {
                                    "type": "object",
                                    "properties": {"id": {"type": "string"}},
                                    "required": ["id"],
                                }
                            }
                        },
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {
                        "main": {
                            "name": "Sample API",
                            "local_file": "openapi.json",
                            "fetch_mode": "local_file",
                            "source_file": "specs/openapi.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "SchemaKey": {
                            "spec": "main",
                            "kind": "object",
                            "dart_class": "SchemaWrapper",
                            "file": "lib/src/models/common/schema_wrapper.dart",
                            "schema": None,
                        }
                    },
                },
            )

            exit_code, payload = command_scaffold(
                SimpleNamespace(
                    config_dir=config_dir,
                    target="schema",
                    name="SchemaWrapper",
                    spec_name=None,
                    output=None,
                    dry_run=True,
                )
            )

            self.assertEqual(exit_code, 0)
            self.assertIn("class SchemaWrapper", payload["preview"])
            self.assertIn("final String id;", payload["preview"])
            self.assertTrue(payload["output"].endswith("lib/src/models/common/schema_wrapper.dart"))

    def test_scaffold_multi_spec_uses_selected_spec(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            _, config_dir, _ = self._create_multi_spec_config(root)

            exit_code, payload = command_scaffold(
                SimpleNamespace(
                    config_dir=config_dir,
                    target="schema",
                    name="Tool",
                    spec_name="interactions",
                    output=None,
                    dry_run=True,
                )
            )

            self.assertEqual(exit_code, 0)
            self.assertIn("class InteractionTool", payload["preview"])
            self.assertTrue(payload["output"].endswith("lib/src/models/interactions/tool.dart"))

    def test_verify_scope_type_without_spec_name_uses_exact_manifest_key(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            _, config_dir, _ = self._create_multi_spec_config(root)

            exit_code, payload = command_verify(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    checks="implementation",
                    scope="type",
                    type_name="Tool",
                    baseline=None,
                    git_ref=None,
                )
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["implementation"]["selected_types"], ["Tool"])

    def test_create_dry_run_reports_changes_without_writing(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            spec_file = root / "spec.json"
            spec_file.write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "New API", "version": "1"},
                        "paths": {"/v1/items": {"get": {"operationId": "listItems"}}},
                        "components": {
                            "schemas": {
                                "Item": {"type": "object", "properties": {"id": {"type": "string"}}, "required": ["id"]},
                                "ItemState": {"type": "string", "enum": ["ACTIVE", "PAUSED"]},
                            }
                        },
                    }
                )
            )
            previous_cwd = Path.cwd()
            try:
                os.chdir(root)
                exit_code, payload = command_create(
                    SimpleNamespace(
                        package_name="new_client_dart",
                        display_name="New Client",
                        spec_url=None,
                        spec_file=spec_file,
                        shortname=None,
                        auth_env_var=[],
                        repo_root=None,
                        output_root="packages",
                        dry_run=True,
                    )
                )
            finally:
                os.chdir(previous_cwd)

            self.assertEqual(exit_code, 0)
            self.assertFalse((root / "packages" / "new_client_dart").exists())
            self.assertTrue(any(path.endswith("manifest.json") for path in payload["files"]))

    def test_create_dry_run_does_not_require_license_file(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            spec_file = root / "spec.json"
            spec_file.write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Licenseless API", "version": "1"},
                        "paths": {},
                        "components": {"schemas": {}},
                    }
                )
            )
            previous_cwd = Path.cwd()
            try:
                os.chdir(root)
                exit_code, payload = command_create(
                    SimpleNamespace(
                        package_name="licenseless_client_dart",
                        display_name="Licenseless Client",
                        spec_url=None,
                        spec_file=spec_file,
                        shortname=None,
                        auth_env_var=[],
                        repo_root=None,
                        output_root="packages",
                        dry_run=True,
                    )
                )
            finally:
                os.chdir(previous_cwd)

            self.assertEqual(exit_code, 0)
            self.assertFalse((root / "packages" / "licenseless_client_dart").exists())
            self.assertTrue(any(path.endswith("LICENSE") for path in payload["files"]))

    def test_create_respects_repo_root_outside_repo(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_repo, tempfile.TemporaryDirectory() as tmp_other:
            repo_root = Path(tmp_repo)
            other_root = Path(tmp_other)
            self._write_workspace(repo_root)
            self._write_repo_license(repo_root)
            spec_file = repo_root / "spec.json"
            spec_file.write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Repo Root API", "version": "1"},
                        "paths": {},
                        "components": {"schemas": {"Item": {"type": "object", "properties": {"id": {"type": "string"}}}}},
                    }
                )
            )
            previous_cwd = Path.cwd()
            try:
                os.chdir(other_root)
                exit_code, _ = command_create(
                    SimpleNamespace(
                        package_name="repo_root_client_dart",
                        display_name="Repo Root Client",
                        spec_url=None,
                        spec_file=spec_file,
                        shortname=None,
                        auth_env_var=[],
                        repo_root=repo_root,
                        output_root="packages",
                        dry_run=False,
                    )
                )
            finally:
                os.chdir(previous_cwd)

            self.assertEqual(exit_code, 0)
            self.assertTrue((repo_root / "packages" / "repo_root_client_dart").exists())

    def test_create_spec_url_dry_run_performs_zero_writes(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_repo, tempfile.TemporaryDirectory() as tmp_other:
            repo_root = Path(tmp_repo)
            other_root = Path(tmp_other)
            self._write_workspace(repo_root)
            self._write_repo_license(repo_root)
            previous_cwd = Path.cwd()
            fetch_mock = None
            try:
                os.chdir(other_root)
                with patch(
                    "api_toolkit.operations.fetch_remote_document",
                    return_value=(
                        json.dumps(
                            {
                                "openapi": "3.1.0",
                                "info": {"title": "Remote API", "version": "1"},
                                "paths": {},
                                "components": {"schemas": {"Item": {"type": "object", "properties": {"id": {"type": "string"}}}}},
                            }
                        ),
                        None,
                    ),
                ) as fetch_mock:
                    exit_code, payload = command_create(
                        SimpleNamespace(
                            package_name="remote_client_dart",
                            display_name="Remote Client",
                            spec_url="https://example.com/openapi.json",
                            spec_file=None,
                            shortname=None,
                            auth_env_var=[],
                            repo_root=repo_root,
                            output_root="packages",
                            dry_run=True,
                        )
                    )
            finally:
                os.chdir(previous_cwd)

            self.assertEqual(exit_code, 0)
            self.assertFalse((repo_root / "packages" / "remote_client_dart").exists())
            self.assertFalse((repo_root / ".agents" / "shared" / "api-toolkit" / ".tmp-create-spec.json").exists())
            self.assertTrue(payload["dry_run"])
            self.assertIsNotNone(fetch_mock)
            fetch_mock.assert_called_once_with("https://example.com/openapi.json", None, None)

    def test_create_spec_url_uses_auth_env_var_for_remote_bootstrap(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_repo, tempfile.TemporaryDirectory() as tmp_other:
            repo_root = Path(tmp_repo)
            other_root = Path(tmp_other)
            self._write_workspace(repo_root)
            self._write_repo_license(repo_root)
            previous_cwd = Path.cwd()
            fetch_mock = None
            try:
                os.chdir(other_root)
                with patch.dict(os.environ, {"REMOTE_CLIENT_API_KEY": "test-key"}, clear=False):
                    with patch(
                        "api_toolkit.operations.fetch_remote_document",
                        return_value=(
                            json.dumps(
                                {
                                    "openapi": "3.1.0",
                                    "info": {"title": "Remote API", "version": "1"},
                                    "paths": {},
                                    "components": {
                                        "schemas": {
                                            "Item": {
                                                "type": "object",
                                                "properties": {"id": {"type": "string"}},
                                            }
                                        }
                                    },
                                }
                            ),
                            None,
                        ),
                    ) as fetch_mock:
                        exit_code, payload = command_create(
                            SimpleNamespace(
                                package_name="remote_client_dart",
                                display_name="Remote Client",
                                spec_url="https://example.com/openapi.json",
                                spec_file=None,
                                shortname=None,
                                auth_env_var=["REMOTE_CLIENT_API_KEY"],
                                repo_root=repo_root,
                                output_root="packages",
                                dry_run=True,
                            )
                        )
            finally:
                os.chdir(previous_cwd)

            self.assertEqual(exit_code, 0)
            self.assertTrue(payload["dry_run"])
            self.assertIsNotNone(fetch_mock)
            fetch_mock.assert_called_once_with(
                "https://example.com/openapi.json",
                "test-key",
                toolkit_config.AuthConfig(location="header", name="Authorization", prefix="Bearer "),
            )

    def test_create_writes_bootstrap_files_and_workspace_entry(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            spec_file = root / "spec.json"
            spec_file.write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Bootstrap API", "version": "1"},
                        "paths": {"/v1/items": {"get": {"operationId": "listItems"}}},
                        "components": {
                            "schemas": {
                                "Item": {"type": "object", "properties": {"id": {"type": "string"}}, "required": ["id"]},
                                "ItemState": {"type": "string", "enum": ["ACTIVE", "PAUSED"]},
                            }
                        },
                    }
                )
            )
            previous_cwd = Path.cwd()
            try:
                os.chdir(root)
                exit_code, payload = command_create(
                    SimpleNamespace(
                        package_name="bootstrap_client_dart",
                        display_name="Bootstrap Client",
                        spec_url=None,
                        spec_file=spec_file,
                        shortname=None,
                        auth_env_var=["BOOTSTRAP_API_KEY"],
                        repo_root=None,
                        output_root="packages",
                        dry_run=False,
                    )
                )
            finally:
                os.chdir(previous_cwd)

            self.assertEqual(exit_code, 0)
            package_root = root / "packages" / "bootstrap_client_dart"
            skill_root = package_root / ".agents" / "skills" / "openapi-bootstrap_client"
            config_dir = skill_root / "config"
            self.assertTrue(package_root.exists())
            self.assertTrue((package_root / "specs" / "openapi.json").exists())
            self.assertTrue((package_root / "specs" / "openapi.source.json").exists())
            self.assertEqual(
                sorted(path.name for path in config_dir.iterdir() if path.is_file()),
                ["documentation.json", "manifest.json", "package.json", "specs.json"],
            )
            pubspec_text = (package_root / "pubspec.yaml").read_text()
            self.assertIn("resolution: workspace", pubspec_text)
            self.assertIn("http: ^1.6.0", pubspec_text)
            self.assertIn("logging: ^1.3.0", pubspec_text)
            self.assertIn("meta: ^1.16.0", pubspec_text)
            self.assertIn("mocktail: ^1.0.4", pubspec_text)
            workspace_text = (root / "pubspec.yaml").read_text()
            self.assertIn("  - packages/bootstrap_client_dart\n", workspace_text)
            self.assertIn("creation-plan.md", payload["creation_plan"])
            skill_text = (skill_root / "SKILL.md").read_text()
            self.assertIn("run the repo-relative examples from the repository root", skill_text)
            guide_text = (skill_root / "references" / "package-guide.md").read_text()
            self.assertIn(
                "invoke the script via an absolute path and pass an absolute `--config-dir`",
                guide_text,
            )
            creation_plan_text = Path(payload["creation_plan"]).read_text()
            self.assertIn(
                "invoke the script via an absolute path and pass an absolute `--config-dir`",
                creation_plan_text,
            )
            impl_patterns_text = (skill_root / "references" / "implementation-patterns.md").read_text()
            self.assertIn(
                "[implementation-patterns-core.md](../../../../../../.agents/shared/api-toolkit/references/implementation-patterns-core.md)",
                impl_patterns_text,
            )
            generated_config = load_toolkit_config(config_dir)
            self.assertEqual(generated_config.package.name, "bootstrap_client_dart")
            self.assertIn("Item", generated_config.manifest.types)
            self.assertIn("ItemState", generated_config.manifest.types)
            skill_yaml_text = (skill_root / "agents" / "openai.yaml").read_text()
            self.assertIn('  display_name: "Bootstrap Client OpenAPI"\n', skill_yaml_text)
            self.assertIn('  short_description: "Manage Bootstrap Client OpenAPI workflow"\n', skill_yaml_text)
            skill_markdown = (skill_root / "SKILL.md").read_text()
            self.assertIn("configured `output_dir` as `latest-<spec>.json`", skill_markdown)
            self.assertIn("`output_dir/latest-<spec>.json` into `packages/bootstrap_client_dart/specs/`", skill_markdown)
            creation_plan_text = (skill_root / "creation-plan.md").read_text()
            self.assertIn("`output_dir/latest-main.json` into `specs/openapi.json`", creation_plan_text)
            self.assertTrue(generated_config.specs["main"].requires_auth)
            self.assertEqual(
                generated_config.output_dir,
                toolkit_config.default_output_dir("bootstrap_client_dart"),
            )
            self.assertEqual(
                generated_config.specs["main"].auth_env_vars,
                ["BOOTSTRAP_API_KEY"],
            )
            self.assertEqual(
                generated_config.specs["main"].auth,
                toolkit_config.AuthConfig(location="header", name="Authorization", prefix="Bearer "),
            )

    def test_create_normalizes_discriminator_mapping_for_bootstrap_manifest(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            spec_file = root / "spec.json"
            spec_file.write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Bootstrap API", "version": "1"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "Message": {
                                    "oneOf": [
                                        {"$ref": "#/components/schemas/SystemMessage"},
                                        {"$ref": "#/components/schemas/UserMessage"},
                                    ],
                                    "discriminator": {
                                        "propertyName": "role",
                                        "mapping": {
                                            "system": "#/components/schemas/SystemMessage",
                                            "user": "#/components/schemas/UserMessage",
                                        },
                                    },
                                },
                                "SystemMessage": {
                                    "type": "object",
                                    "properties": {"role": {"type": "string"}},
                                },
                                "UserMessage": {
                                    "type": "object",
                                    "properties": {"role": {"type": "string"}},
                                },
                            }
                        },
                    }
                )
            )
            previous_cwd = Path.cwd()
            try:
                os.chdir(root)
                exit_code, _ = command_create(
                    SimpleNamespace(
                        package_name="discriminator_client_dart",
                        display_name="Discriminator Client",
                        spec_url=None,
                        spec_file=spec_file,
                        shortname=None,
                        auth_env_var=[],
                        repo_root=None,
                        output_root="packages",
                        dry_run=False,
                    )
                )
            finally:
                os.chdir(previous_cwd)

            self.assertEqual(exit_code, 0)
            manifest_path = (
                root
                / "packages"
                / "discriminator_client_dart"
                / ".agents"
                / "skills"
                / "openapi-discriminator_client"
                / "config"
                / "manifest.json"
            )
            manifest = json.loads(manifest_path.read_text())
            self.assertEqual(
                manifest["types"]["Message"]["discriminator"]["mapping"],
                {
                    "SystemMessage": "system",
                    "UserMessage": "user",
                },
            )

    def test_scaffold_enum_preview_contains_unknown_fallback(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            output_dir = root / "tmp" / "sample"
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {"schemas": {"ExampleState": {"type": "string", "enum": ["ACTIVE", "PAUSED"]}}},
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "ExampleState": {
                            "spec": "main",
                            "kind": "enum",
                            "dart_class": "ExampleState",
                            "file": "lib/src/models/common/example_state.dart",
                        }
                    },
                },
            )

            exit_code, payload = command_scaffold(
                SimpleNamespace(
                    config_dir=config_dir,
                    target="enum",
                    name="ExampleState",
                    spec_name=None,
                    output=None,
                    dry_run=True,
                )
            )

            self.assertEqual(exit_code, 0)
            self.assertIn("enum ExampleState", payload["preview"])
            self.assertIn("unknown", payload["preview"])
            self.assertTrue(payload["output"].endswith("example_state.dart"))

    def test_scaffold_enum_preview_deduplicates_three_colliding_members(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            output_dir = root / "tmp" / "sample"
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {"schemas": {"ExampleState": {"type": "string", "enum": ["foo", "FOO", "Foo"]}}},
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "ExampleState": {
                            "spec": "main",
                            "kind": "enum",
                            "dart_class": "ExampleState",
                            "file": "lib/src/models/common/example_state.dart",
                        }
                    },
                },
            )

            exit_code, payload = command_scaffold(
                SimpleNamespace(
                    config_dir=config_dir,
                    target="enum",
                    name="ExampleState",
                    spec_name=None,
                    output=None,
                    dry_run=True,
                )
            )

            self.assertEqual(exit_code, 0)
            self.assertIn("  foo,", payload["preview"])
            self.assertIn("  fooValue,", payload["preview"])
            self.assertIn("  fooValueValue,", payload["preview"])

    def test_scaffold_enum_preview_uses_unspecified_when_unknown_member_already_exists(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            output_dir = root / "tmp" / "sample"
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {"schemas": {"ExampleState": {"type": "string", "enum": ["UNKNOWN", "ACTIVE"]}}},
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "ExampleState": {
                            "spec": "main",
                            "kind": "enum",
                            "dart_class": "ExampleState",
                            "file": "lib/src/models/common/example_state.dart",
                        }
                    },
                },
            )

            exit_code, payload = command_scaffold(
                SimpleNamespace(
                    config_dir=config_dir,
                    target="enum",
                    name="ExampleState",
                    spec_name=None,
                    output=None,
                    dry_run=True,
                )
            )

            self.assertEqual(exit_code, 0)
            preview = payload["preview"]
            self.assertEqual(preview.splitlines().count("  unknown,"), 1)
            self.assertEqual(preview.splitlines().count("  unspecified,"), 1)
            self.assertIn("    _ => ExampleState.unspecified,", preview)
            self.assertIn("    ExampleState.unspecified => 'unknown',", preview)
            self.assertNotIn("    _ => ExampleState.unknown,", preview)

    def test_scaffold_enum_preview_uses_unique_fallback_when_unknown_and_unspecified_exist(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            output_dir = root / "tmp" / "sample"
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "ExampleState": {
                                    "type": "string",
                                    "enum": ["unknown", "unspecified", "ACTIVE"],
                                }
                            }
                        },
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "ExampleState": {
                            "spec": "main",
                            "kind": "enum",
                            "dart_class": "ExampleState",
                            "file": "lib/src/models/common/example_state.dart",
                        }
                    },
                },
            )

            exit_code, payload = command_scaffold(
                SimpleNamespace(
                    config_dir=config_dir,
                    target="enum",
                    name="ExampleState",
                    spec_name=None,
                    output=None,
                    dry_run=True,
                )
            )

            self.assertEqual(exit_code, 0)
            preview = payload["preview"]
            self.assertEqual(preview.splitlines().count("  unknown,"), 1)
            self.assertEqual(preview.splitlines().count("  unspecified,"), 1)
            self.assertEqual(preview.splitlines().count("  unknownValue,"), 1)
            self.assertIn("    _ => ExampleState.unknownValue,", preview)
            self.assertIn("    ExampleState.unknownValue => 'unknown',", preview)

    def test_scaffold_required_refs_and_numbers_are_non_nullable_when_required(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            output_dir = root / "tmp" / "sample"
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "Nested": {
                                    "type": "object",
                                    "properties": {"name": {"type": "string"}},
                                },
                                "Example": {
                                    "type": "object",
                                    "properties": {
                                        "requiredNested": {"$ref": "#/components/schemas/Nested"},
                                        "optionalNested": {"$ref": "#/components/schemas/Nested"},
                                        "requiredNumber": {"type": "number"},
                                        "optionalNumber": {"type": "number"},
                                    },
                                    "required": ["requiredNested", "requiredNumber"],
                                },
                            }
                        },
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Example": {
                            "spec": "main",
                            "kind": "object",
                            "dart_class": "Example",
                            "file": "lib/src/models/common/example.dart",
                            "schema": "Example",
                        }
                    },
                },
            )

            exit_code, payload = command_scaffold(
                SimpleNamespace(
                    config_dir=config_dir,
                    target="schema",
                    name="Example",
                    spec_name=None,
                    output=None,
                    dry_run=True,
                )
            )

            self.assertEqual(exit_code, 0)
            preview = payload["preview"]
            self.assertIn("requiredNested: Nested.fromJson(json['requiredNested'] as Map<String, dynamic>),", preview)
            self.assertIn(
                "optionalNested: json['optionalNested'] != null ? Nested.fromJson(json['optionalNested'] as Map<String, dynamic>) : null,",
                preview,
            )
            self.assertIn("requiredNumber: (json['requiredNumber'] as num).toDouble(),", preview)
            self.assertIn(
                "optionalNumber: json['optionalNumber'] != null ? (json['optionalNumber'] as num).toDouble() : null,",
                preview,
            )
            self.assertIn("'requiredNested': requiredNested.toJson(),", preview)
            self.assertIn("if (optionalNested != null) 'optionalNested': optionalNested!.toJson(),", preview)
            self.assertIn("'requiredNumber': requiredNumber,", preview)
            self.assertIn("if (optionalNumber != null) 'optionalNumber': optionalNumber!,", preview)

    def test_scaffold_preview_renders_empty_object_class(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            output_dir = root / "tmp" / "sample"
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {"schemas": {"Empty": {"type": "object", "properties": {}}}},
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Empty": {
                            "spec": "main",
                            "kind": "object",
                            "dart_class": "Empty",
                            "file": "lib/src/models/common/empty.dart",
                            "schema": "Empty",
                        }
                    },
                },
            )

            exit_code, payload = command_scaffold(
                SimpleNamespace(
                    config_dir=config_dir,
                    target="schema",
                    name="Empty",
                    spec_name=None,
                    output=None,
                    dry_run=True,
                )
            )

            self.assertEqual(exit_code, 0)
            preview = payload["preview"]
            self.assertIn("class Empty {", preview)
            self.assertIn("const Empty({", preview)
            self.assertIn("factory Empty.fromJson(Map<String, dynamic> json) {", preview)
            self.assertIn("Map<String, dynamic> toJson() => {", preview)
            self.assertIn("Empty copyWith({", preview)

    def test_scaffold_preview_serializes_nullable_self_reference(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            output_dir = root / "tmp" / "sample"
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "Node": {
                                    "type": "object",
                                    "properties": {
                                        "child": {"$ref": "#/components/schemas/Node"},
                                    },
                                }
                            }
                        },
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Node": {
                            "spec": "main",
                            "kind": "object",
                            "dart_class": "Node",
                            "file": "lib/src/models/common/node.dart",
                            "schema": "Node",
                        }
                    },
                },
            )

            exit_code, payload = command_scaffold(
                SimpleNamespace(
                    config_dir=config_dir,
                    target="schema",
                    name="Node",
                    spec_name=None,
                    output=None,
                    dry_run=True,
                )
            )

            self.assertEqual(exit_code, 0)
            preview = payload["preview"]
            self.assertIn(
                "child: json['child'] != null ? Node.fromJson(json['child'] as Map<String, dynamic>) : null,",
                preview,
            )
            self.assertIn(
                "if (child != null) 'child': child!.toJson(),",
                preview,
            )

    def test_scaffold_preview_serializes_scalar_arrays(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            output_dir = root / "tmp" / "sample"
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "Example": {
                                    "type": "object",
                                    "properties": {
                                        "tags": {"type": "array", "items": {"type": "string"}},
                                        "scores": {"type": "array", "items": {"type": "number"}},
                                    },
                                    "required": ["tags", "scores"],
                                }
                            }
                        },
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Example": {
                            "spec": "main",
                            "kind": "object",
                            "dart_class": "Example",
                            "file": "lib/src/models/common/example.dart",
                            "schema": "Example",
                        }
                    },
                },
            )

            exit_code, payload = command_scaffold(
                SimpleNamespace(
                    config_dir=config_dir,
                    target="schema",
                    name="Example",
                    spec_name=None,
                    output=None,
                    dry_run=True,
                )
            )

            self.assertEqual(exit_code, 0)
            preview = payload["preview"]
            self.assertIn("tags: (json['tags'] as List<dynamic>).map((item) => item as String).toList(),", preview)
            self.assertIn("scores: (json['scores'] as List<dynamic>).map((item) => (item as num).toDouble()).toList(),", preview)
            self.assertIn("'tags': tags,", preview)
            self.assertIn("'scores': scores,", preview)

    def test_scaffold_preview_serializes_ref_arrays(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            output_dir = root / "tmp" / "sample"
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "Nested": {
                                    "type": "object",
                                    "properties": {"id": {"type": "string"}},
                                },
                                "Example": {
                                    "type": "object",
                                    "properties": {
                                        "items": {
                                            "type": "array",
                                            "items": {"$ref": "#/components/schemas/Nested"},
                                        }
                                    },
                                    "required": ["items"],
                                },
                            }
                        },
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Example": {
                            "spec": "main",
                            "kind": "object",
                            "dart_class": "Example",
                            "file": "lib/src/models/common/example.dart",
                            "schema": "Example",
                        }
                    },
                },
            )

            exit_code, payload = command_scaffold(
                SimpleNamespace(
                    config_dir=config_dir,
                    target="schema",
                    name="Example",
                    spec_name=None,
                    output=None,
                    dry_run=True,
                )
            )

            self.assertEqual(exit_code, 0)
            preview = payload["preview"]
            self.assertIn(
                "items: (json['items'] as List<dynamic>).map((item) => Nested.fromJson(item as Map<String, dynamic>)).toList(),",
                preview,
            )
            self.assertIn("'items': items.map((item) => item.toJson()).toList(),", preview)

    def test_scaffold_preview_nullable_to_json_only_asserts_root_field_reference(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            output_dir = root / "tmp" / "sample"
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "Nested": {
                                    "type": "object",
                                    "properties": {"id": {"type": "string"}},
                                },
                                "Example": {
                                    "type": "object",
                                    "properties": {
                                        "item": {
                                            "type": "array",
                                            "items": {"$ref": "#/components/schemas/Nested"},
                                        },
                                        "json": {"$ref": "#/components/schemas/Nested"},
                                    },
                                },
                            }
                        },
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Example": {
                            "spec": "main",
                            "kind": "object",
                            "dart_class": "Example",
                            "file": "lib/src/models/common/example.dart",
                            "schema": "Example",
                        }
                    },
                },
            )

            exit_code, payload = command_scaffold(
                SimpleNamespace(
                    config_dir=config_dir,
                    target="schema",
                    name="Example",
                    spec_name=None,
                    output=None,
                    dry_run=True,
                )
            )

            self.assertEqual(exit_code, 0)
            preview = payload["preview"]
            self.assertIn("if (item != null) 'item': item!.map((item) => item.toJson()).toList(),", preview)
            self.assertIn("if (json != null) 'json': json!.toJson(),", preview)
            self.assertNotIn("item!.map((item!)", preview)
            self.assertNotIn("json!.toJson!()", preview)

    def test_scaffold_preview_marks_unsupported_array_shapes_with_todo(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            output_dir = root / "tmp" / "sample"
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "Example": {
                                    "type": "object",
                                    "properties": {
                                        "items": {
                                            "type": "array",
                                            "items": {
                                                "anyOf": [
                                                    {"type": "string"},
                                                    {"$ref": "#/components/schemas/Nested"},
                                                ]
                                            },
                                        }
                                    },
                                    "required": ["items"],
                                },
                                "Nested": {"type": "object", "properties": {"id": {"type": "string"}}},
                            }
                        },
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Example": {
                            "spec": "main",
                            "kind": "object",
                            "dart_class": "Example",
                            "file": "lib/src/models/common/example.dart",
                            "schema": "Example",
                        }
                    },
                },
            )

            exit_code, payload = command_scaffold(
                SimpleNamespace(
                    config_dir=config_dir,
                    target="schema",
                    name="Example",
                    spec_name=None,
                    output=None,
                    dry_run=True,
                )
            )

            self.assertEqual(exit_code, 0)
            preview = payload["preview"]
            self.assertIn("items: TODO(),", preview)
            self.assertIn("'items': TODO(),", preview)

    def test_scaffold_copywith_uses_local_sentinel_and_supports_nullable_fields(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            output_dir = root / "tmp" / "sample"
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "Example": {
                                    "type": "object",
                                    "properties": {
                                        "requiredId": {"type": "string"},
                                        "optionalNote": {"type": "string"},
                                    },
                                    "required": ["requiredId"],
                                }
                            }
                        },
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Example": {
                            "spec": "main",
                            "kind": "object",
                            "dart_class": "Example",
                            "file": "lib/src/models/common/example.dart",
                            "schema": "Example",
                        }
                    },
                },
            )

            exit_code, payload = command_scaffold(
                SimpleNamespace(
                    config_dir=config_dir,
                    target="schema",
                    name="Example",
                    spec_name=None,
                    output=None,
                    dry_run=True,
                )
            )

            self.assertEqual(exit_code, 0)
            preview = payload["preview"]
            self.assertIn("const Object _unsetCopyWithValue = _UnsetCopyWithSentinel();", preview)
            self.assertIn("Object? requiredId = _unsetCopyWithValue,", preview)
            self.assertIn("Object? optionalNote = _unsetCopyWithValue,", preview)
            self.assertIn(
                "requiredId: requiredId == _unsetCopyWithValue ? this.requiredId : requiredId! as String,",
                preview,
            )
            self.assertIn(
                "optionalNote: optionalNote == _unsetCopyWithValue ? this.optionalNote : optionalNote as String?,",
                preview,
            )
            self.assertNotIn("?? this.", preview)

    def test_verify_implementation_flags_missing_property(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            specs_dir = package_root / "specs"
            output_dir = root / "tmp" / "sample"
            output_dir.mkdir(parents=True)
            spec_payload = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "1"},
                "paths": {},
                "components": {
                    "schemas": {
                        "Example": {
                            "type": "object",
                            "properties": {
                                "id": {"type": "string"},
                                "name": {"type": "string"},
                            },
                            "required": ["id", "name"],
                        }
                    }
                },
            }
            (specs_dir / "openapi.json").write_text(json.dumps(spec_payload))
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Example": {
                            "spec": "main",
                            "kind": "object",
                            "dart_class": "Example",
                            "file": "lib/src/models/common/example.dart",
                            "schema": "Example",
                            "tags": ["critical"],
                        }
                    },
                },
            )
            (package_root / "lib" / "src" / "models" / "common" / "example.dart").write_text(
                "class Example {\n"
                "  final String id;\n\n"
                "  const Example({required this.id});\n"
                "  factory Example.fromJson(Map<String, dynamic> json) => Example(id: json['id'] as String);\n"
                "  Map<String, dynamic> toJson() => {'id': id};\n"
                "  Example copyWith({String? id}) => Example(id: id ?? this.id);\n"
                "}\n"
            )

            exit_code, payload = command_verify(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    checks="implementation",
                    scope="all",
                    type_name=None,
                    baseline=None,
                    git_ref=None,
                )
            )

            self.assertEqual(exit_code, 1)
            issues = payload["results"]["implementation"]["issues"]
            self.assertTrue(any(issue["message"] == "Missing property 'name'" for issue in issues))

    def test_verify_required_nullable_mismatch_is_blocking(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "Example": {
                                    "type": "object",
                                    "properties": {"id": {"type": "string"}},
                                    "required": ["id"],
                                }
                            }
                        },
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"}
                    },
                },
            )
            self._write_model(
                package_root / "lib" / "src" / "models" / "common" / "example.dart",
                "Example",
                fields=[("id", "String", True)],
            )

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 1)
            self.assertTrue(
                any("required in spec but nullable in Dart" in issue["message"] for issue in payload["results"]["implementation"]["issues"])
            )

    def test_verify_missing_copywith_coverage_is_blocking(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "Example": {
                                    "type": "object",
                                    "properties": {"id": {"type": "string"}, "name": {"type": "string"}},
                                    "required": ["id", "name"],
                                }
                            }
                        },
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"}
                    },
                },
            )
            (package_root / "lib" / "src" / "models" / "common" / "example.dart").write_text(
                "class Example {\n"
                "  final String id;\n"
                "  final String name;\n"
                "  const Example({required this.id, required this.name});\n"
                "  factory Example.fromJson(Map<String, dynamic> json) => Example(\n"
                "    id: json['id'] as String,\n"
                "    name: json['name'] as String,\n"
                "  );\n"
                "  Map<String, dynamic> toJson() => {'id': id, 'name': name};\n"
                "  Example copyWith({String? id}) => Example(id: id ?? this.id, name: name);\n"
                "}\n"
            )

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 1)
            self.assertTrue(any("copyWith does not reference all expected fields" in issue["message"] for issue in payload["results"]["implementation"]["issues"]))

    def test_verify_enum_missing_fallback_is_blocking(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {"schemas": {"ExampleState": {"type": "string", "enum": ["active", "paused"]}}},
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "ExampleState": {"spec": "main", "kind": "enum", "dart_class": "ExampleState", "file": "lib/src/models/common/example_state.dart", "schema": "ExampleState"}
                    },
                },
            )
            (package_root / "lib" / "src" / "models" / "common" / "example_state.dart").write_text(
                "enum ExampleState {\n"
                "  active,\n"
                "  paused,\n"
                "}\n"
            )

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 1)
            self.assertTrue(any("Enum fallback value" in issue["message"] for issue in payload["results"]["implementation"]["issues"]))

    def test_verify_coverage_gap_is_blocking(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {"/v1/widgets": {"get": {"operationId": "listWidgets"}}},
                        "components": {"schemas": {}},
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 1)
            self.assertTrue(payload["results"]["implementation"]["coverage_gaps"])

    def test_verify_scope_all_reports_partial_implementation_coverage_for_skipped_entries(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Message": {
                            "spec": "main",
                            "kind": "sealed_parent",
                            "dart_class": "Message",
                            "file": "lib/src/models/common/message.dart",
                            "schema": None,
                            "discriminator": {
                                "field": "role",
                                "mapping": {
                                    "system": "#/components/schemas/SystemMessage",
                                    "user": "#/components/schemas/UserMessage",
                                },
                            },
                        },
                        "SystemMessage": {
                            "spec": "main",
                            "kind": "skip",
                            "dart_class": "SystemMessage",
                            "file": "lib/src/models/common/message.dart",
                            "schema": "SystemMessage",
                            "parent": "Message",
                        },
                        "UserMessage": {
                            "spec": "main",
                            "kind": "skip",
                            "dart_class": "UserMessage",
                            "file": "lib/src/models/common/message.dart",
                            "schema": "UserMessage",
                            "parent": "Message",
                        },
                    },
                },
            )
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "Message": {
                                    "oneOf": [
                                        {"$ref": "#/components/schemas/SystemMessage"},
                                        {"$ref": "#/components/schemas/UserMessage"},
                                    ],
                                    "discriminator": {
                                        "propertyName": "role",
                                        "mapping": {
                                            "system": "#/components/schemas/SystemMessage",
                                            "user": "#/components/schemas/UserMessage",
                                        },
                                    },
                                },
                                "SystemMessage": {"type": "object", "properties": {"role": {"type": "string"}}},
                                "UserMessage": {"type": "object", "properties": {"role": {"type": "string"}}},
                            }
                        },
                    }
                )
            )
            (package_root / "lib" / "src" / "models" / "common" / "message.dart").write_text(
                "sealed class Message {\n"
                "  factory Message.fromJson(Map<String, dynamic> json) {\n"
                "    if (json['role'] == 'system') return SystemMessage.fromJson(json);\n"
                "    if (json['role'] == 'user') return UserMessage.fromJson(json);\n"
                "    return UserMessage.fromJson(json);\n"
                "  }\n"
                "}\n"
                "\n"
                "class SystemMessage extends Message {\n"
                "  factory SystemMessage.fromJson(Map<String, dynamic> json) => SystemMessage();\n"
                "}\n"
                "\n"
                "class UserMessage extends Message {\n"
                "  factory UserMessage.fromJson(Map<String, dynamic> json) => UserMessage();\n"
                "}\n"
            )

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 0)
            result = payload["results"]["implementation"]
            self.assertEqual(result["coverage_summary"]["manifest_entry_count"], 3)
            self.assertEqual(result["coverage_summary"]["selected_entry_count"], 1)
            self.assertEqual(result["coverage_summary"]["skipped_entry_count"], 2)
            self.assertEqual(result["coverage_summary"]["skipped_keys"], ["SystemMessage", "UserMessage"])
            self.assertTrue(result["coverage_summary"]["partial_coverage"])
            self.assertTrue(any(issue["level"] == "warning" and "kind='skip'" in issue["message"] for issue in result["issues"]))
            self.assertEqual(payload["summary"]["warning_checks"], ["implementation"])

    def test_verify_scope_all_checks_skipped_sealed_variants(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Message": {
                            "spec": "main",
                            "kind": "sealed_parent",
                            "dart_class": "Message",
                            "file": "lib/src/models/common/message.dart",
                            "schema": None,
                            "discriminator": {
                                "field": "role",
                                "mapping": {
                                    "system": "#/components/schemas/SystemMessage",
                                    "user": "#/components/schemas/UserMessage",
                                },
                            },
                        },
                        "SystemMessage": {
                            "spec": "main",
                            "kind": "skip",
                            "dart_class": "SystemMessage",
                            "file": "lib/src/models/common/message.dart",
                            "schema": "SystemMessage",
                            "parent": "Message",
                        },
                        "UserMessage": {
                            "spec": "main",
                            "kind": "skip",
                            "dart_class": "UserMessage",
                            "file": "lib/src/models/common/message.dart",
                            "schema": "UserMessage",
                            "parent": "Message",
                        },
                    },
                },
            )
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "Message": {
                                    "oneOf": [
                                        {"$ref": "#/components/schemas/SystemMessage"},
                                        {"$ref": "#/components/schemas/UserMessage"},
                                    ],
                                    "discriminator": {
                                        "propertyName": "role",
                                        "mapping": {
                                            "system": "#/components/schemas/SystemMessage",
                                            "user": "#/components/schemas/UserMessage",
                                        },
                                    },
                                },
                                "SystemMessage": {"type": "object", "properties": {"role": {"type": "string"}}},
                                "UserMessage": {"type": "object", "properties": {"role": {"type": "string"}}},
                            }
                        },
                    }
                )
            )
            (package_root / "lib" / "src" / "models" / "common" / "message.dart").write_text(
                "sealed class Message {\n"
                "  factory Message.fromJson(Map<String, dynamic> json) {\n"
                "    if (json['role'] == 'system') return SystemMessage.fromJson(json);\n"
                "    return UserMessage.fromJson(json);\n"
                "  }\n"
                "}\n"
                "\n"
                "class SystemMessage extends Message {\n"
                "  factory SystemMessage.fromJson(Map<String, dynamic> json) => SystemMessage();\n"
                "}\n"
                "\n"
                "class UserMessage extends Message {\n"
                "  factory UserMessage.fromJson(Map<String, dynamic> json) => UserMessage();\n"
                "}\n"
            )

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 1)
            self.assertTrue(
                any("discriminator value 'user'" in issue["message"] for issue in payload["results"]["implementation"]["issues"])
            )

    def test_verify_docs_reports_partial_coverage_when_documentation_exclusions_exist(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps({"openapi": "3.1.0", "info": {"title": "Sample", "version": "1"}, "paths": {}, "components": {"schemas": {}}})
            )
            documentation_path = config_dir / "documentation.json"
            documentation = json.loads(documentation_path.read_text())
            documentation["excluded_resources"] = ["alpha"]
            documentation["excluded_from_examples"] = ["beta"]
            documentation_path.write_text(json.dumps(documentation, indent=2))
            (package_root / "lib" / "src" / "resources" / "alpha_resource.dart").write_text("class AlphaResource {}\n")
            (package_root / "lib" / "src" / "resources" / "beta_resource.dart").write_text("class BetaResource {}\n")
            (package_root / "README.md").write_text("# Sample\n\nclient.beta\n")

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="docs", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 0)
            result = payload["results"]["docs"]
            self.assertTrue(result["coverage_summary"]["partial_coverage"])
            self.assertEqual(result["coverage_summary"]["discovered_resource_count"], 2)
            self.assertEqual(result["coverage_summary"]["verified_resource_count"], 1)
            self.assertEqual(result["coverage_summary"]["excluded_resources"], ["alpha"])
            self.assertEqual(result["coverage_summary"]["excluded_from_examples"], ["beta"])
            self.assertTrue(any(issue["level"] == "warning" and "documentation.json excludes" in issue["message"] for issue in result["issues"]))
            self.assertEqual(payload["summary"]["warning_checks"], ["docs"])

    def test_verify_changed_scope_checks_parent_for_changed_skipped_variant(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            output_dir = root / "tmp" / "sample"
            output_dir.mkdir(parents=True)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Message": {
                            "spec": "main",
                            "kind": "sealed_parent",
                            "dart_class": "Message",
                            "file": "lib/src/models/common/message.dart",
                            "schema": None,
                            "discriminator": {
                                "field": "role",
                                "mapping": {
                                    "system": "#/components/schemas/SystemMessage",
                                    "user": "#/components/schemas/UserMessage",
                                },
                            },
                        },
                        "SystemMessage": {
                            "spec": "main",
                            "kind": "skip",
                            "dart_class": "SystemMessage",
                            "file": "lib/src/models/common/message.dart",
                            "schema": "SystemMessage",
                            "parent": "Message",
                        },
                        "UserMessage": {
                            "spec": "main",
                            "kind": "skip",
                            "dart_class": "UserMessage",
                            "file": "lib/src/models/common/message.dart",
                            "schema": "UserMessage",
                            "parent": "Message",
                        },
                    },
                },
            )
            old_spec = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "1"},
                "paths": {},
                "components": {
                    "schemas": {
                        "Message": {
                            "oneOf": [
                                {"$ref": "#/components/schemas/SystemMessage"},
                                {"$ref": "#/components/schemas/UserMessage"},
                            ],
                            "discriminator": {
                                "propertyName": "role",
                                "mapping": {
                                    "system": "#/components/schemas/SystemMessage",
                                    "user": "#/components/schemas/UserMessage",
                                },
                            },
                        },
                        "SystemMessage": {"type": "object", "properties": {"role": {"type": "string"}}},
                        "UserMessage": {"type": "object", "properties": {"role": {"type": "string"}}},
                    }
                },
            }
            new_spec = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "2"},
                "paths": {},
                "components": {
                    "schemas": {
                        "Message": old_spec["components"]["schemas"]["Message"],
                        "SystemMessage": old_spec["components"]["schemas"]["SystemMessage"],
                        "UserMessage": {
                            "type": "object",
                            "properties": {"role": {"type": "string"}, "id": {"type": "string"}},
                        },
                    }
                },
            }
            (package_root / "specs" / "openapi.json").write_text(json.dumps(old_spec))
            (output_dir / "latest-main.json").write_text(json.dumps(new_spec))
            (package_root / "lib" / "src" / "models" / "common" / "message.dart").write_text(
                "sealed class Message {\n"
                "  factory Message.fromJson(Map<String, dynamic> json) {\n"
                "    if (json['role'] == 'system') return SystemMessage.fromJson(json);\n"
                "    return UserMessage.fromJson(json);\n"
                "  }\n"
                "}\n"
                "\n"
                "class SystemMessage extends Message {\n"
                "  factory SystemMessage.fromJson(Map<String, dynamic> json) => SystemMessage();\n"
                "}\n"
                "\n"
                "class UserMessage extends Message {\n"
                "  factory UserMessage.fromJson(Map<String, dynamic> json) => UserMessage();\n"
                "}\n"
            )

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="changed", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 1)
            self.assertEqual(payload["results"]["implementation"]["selected_types"], ["UserMessage"])
            self.assertTrue(
                any("discriminator value 'user'" in issue["message"] for issue in payload["results"]["implementation"]["issues"])
            )

    def test_verify_changed_scope_ignores_unrelated_coverage_gaps(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            output_dir = root / "tmp" / "sample"
            output_dir.mkdir(parents=True)
            old_spec = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "1"},
                "paths": {
                    "/v1/widgets": {"get": {"operationId": "listWidgets"}},
                    "/v1/gadgets": {"get": {"operationId": "listGadgets"}},
                },
                "components": {"schemas": {}},
            }
            new_spec = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "2"},
                "paths": {
                    "/v1/widgets": {
                        "get": {
                            "operationId": "listWidgets",
                            "parameters": [{"name": "verbose", "in": "query", "schema": {"type": "boolean"}}],
                        }
                    },
                    "/v1/gadgets": {"get": {"operationId": "listGadgets"}},
                },
                "components": {"schemas": {}},
            }
            (package_root / "specs" / "openapi.json").write_text(json.dumps(old_spec))
            (output_dir / "latest-main.json").write_text(json.dumps(new_spec))
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
            )
            (package_root / "lib" / "src" / "resources" / "widgets_resource.dart").write_text("class WidgetsResource {}\n")

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="changed", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["implementation"]["coverage_gaps"], [])

    def test_verify_changed_scope_reports_changed_resource_coverage_gap(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            output_dir = root / "tmp" / "sample"
            output_dir.mkdir(parents=True)
            old_spec = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "1"},
                "paths": {"/v1/widgets": {"get": {"operationId": "listWidgets"}}},
                "components": {"schemas": {}},
            }
            new_spec = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "2"},
                "paths": {
                    "/v1/widgets": {
                        "get": {
                            "operationId": "listWidgets",
                            "parameters": [{"name": "verbose", "in": "query", "schema": {"type": "boolean"}}],
                        }
                    }
                },
                "components": {"schemas": {}},
            }
            (package_root / "specs" / "openapi.json").write_text(json.dumps(old_spec))
            (output_dir / "latest-main.json").write_text(json.dumps(new_spec))
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
            )

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="changed", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 1)
            self.assertEqual([gap["resource"] for gap in payload["results"]["implementation"]["coverage_gaps"]], ["widgets"])

    def test_verify_coverage_alias_matches_grouped_resource_file(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {"/v1/copy": {"post": {"operationId": "copyModel"}}},
                        "components": {"schemas": {}},
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {"resource_aliases": {"copy": "models"}},
                    "types": {},
                },
            )
            (package_root / "lib" / "src" / "resources" / "models_resource.dart").write_text("class ModelsResource {}\n")

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["implementation"]["coverage_gaps"], [])

    def test_review_summary_counts_implementation_warnings(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            specs_dir = package_root / "specs"
            output_dir = root / "tmp" / "sample"
            output_dir.mkdir(parents=True)
            old_spec = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "1"},
                "paths": {},
                "components": {
                    "schemas": {
                        "Existing": {
                            "type": "object",
                            "properties": {"id": {"type": "string"}},
                            "required": ["id"],
                        }
                    }
                },
            }
            new_spec = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "2"},
                "paths": {},
                "components": {
                    "schemas": {
                        "Existing": {
                            "type": "object",
                            "properties": {
                                "id": {"type": "string"},
                                "name": {"type": "string"},
                            },
                            "required": ["id"],
                        }
                    }
                },
            }
            (specs_dir / "openapi.json").write_text(json.dumps(old_spec))
            (output_dir / "latest-main.json").write_text(json.dumps(new_spec))
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {
                        "main": {
                            "name": "Sample API",
                            "local_file": "openapi.json",
                            "fetch_mode": "local_file",
                            "source_file": "specs/openapi.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Existing": {
                            "spec": "main",
                            "kind": "object",
                            "dart_class": "Existing",
                            "file": "lib/src/models/common/existing.dart",
                            "schema": "Existing",
                        }
                    },
                },
            )
            (package_root / "lib" / "src" / "models" / "common" / "existing.dart").write_text(
                "class Existing {\n"
                "  final String id;\n"
                "  final String? name;\n"
                "\n"
                "  const Existing({required this.id, this.name});\n"
                "\n"
                "  factory Existing.fromJson(Map<String, dynamic> json) => Existing(\n"
                "    id: json['id'] as String,\n"
                "    name: json['name'] as String?,\n"
                "  );\n"
                "\n"
                "  Map<String, dynamic> toJson() => {\n"
                "    'id': id,\n"
                "    if (name != null) 'name': name,\n"
                "  };\n"
                "\n"
                "  Existing copyWith({String? id, String? name}) => Existing(\n"
                "    id: id ?? this.id,\n"
                "    name: name ?? this.name,\n"
                "  );\n"
                "\n"
                "  @override\n"
                "  bool operator ==(Object other) => identical(this, other) || (other is Existing && other.id == id);\n"
                "\n"
                "  @override\n"
                "  int get hashCode => Object.hash(id);\n"
                "\n"
                "  @override\n"
                "  String toString() => 'Existing(id: $id)';\n"
                "}\n"
            )

            exit_code, payload = command_review(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    baseline=None,
                    git_ref=None,
                    changelog_out=None,
                    plan_out=None,
                )
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["summary"]["warning_count"], 3)
            self.assertTrue(any(issue["level"] == "warning" for issue in payload["issues"]))

    def test_review_returns_failure_for_changed_implementation_errors(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            specs_dir = package_root / "specs"
            output_dir = root / "tmp" / "sample"
            output_dir.mkdir(parents=True)
            old_spec = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "1"},
                "paths": {},
                "components": {
                    "schemas": {
                        "Existing": {
                            "type": "object",
                            "properties": {"id": {"type": "string"}},
                            "required": ["id"],
                        }
                    }
                },
            }
            new_spec = {
                "openapi": "3.1.0",
                "info": {"title": "Sample", "version": "2"},
                "paths": {},
                "components": {
                    "schemas": {
                        "Existing": {
                            "type": "object",
                            "properties": {
                                "id": {"type": "string"},
                                "name": {"type": "string"},
                            },
                            "required": ["id", "name"],
                        }
                    }
                },
            }
            (specs_dir / "openapi.json").write_text(json.dumps(old_spec))
            (output_dir / "latest-main.json").write_text(json.dumps(new_spec))
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {
                        "main": {
                            "name": "Sample API",
                            "local_file": "openapi.json",
                            "fetch_mode": "local_file",
                            "source_file": "specs/openapi.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(output_dir),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Existing": {
                            "spec": "main",
                            "kind": "object",
                            "dart_class": "Existing",
                            "file": "lib/src/models/common/existing.dart",
                            "schema": "Existing",
                        }
                    },
                },
            )
            (package_root / "lib" / "src" / "models" / "common" / "existing.dart").write_text(
                "class Existing {\n"
                "  final String id;\n"
                "\n"
                "  const Existing({required this.id});\n"
                "\n"
                "  factory Existing.fromJson(Map<String, dynamic> json) => Existing(\n"
                "    id: json['id'] as String,\n"
                "  );\n"
                "\n"
                "  Map<String, dynamic> toJson() => {\n"
                "    'id': id,\n"
                "  };\n"
                "\n"
                "  Existing copyWith({String? id}) => Existing(\n"
                "    id: id ?? this.id,\n"
                "  );\n"
                "\n"
                "  @override\n"
                "  bool operator ==(Object other) => identical(this, other) || (other is Existing && other.id == id);\n"
                "\n"
                "  @override\n"
                "  int get hashCode => Object.hash(id);\n"
                "\n"
                "  @override\n"
                "  String toString() => 'Existing(id: $id)';\n"
                "}\n"
            )

            exit_code, payload = command_review(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    baseline=None,
                    git_ref=None,
                    changelog_out=None,
                    plan_out=None,
                )
            )

            self.assertEqual(exit_code, toolkit_config.EXIT_FAILURE)
            self.assertEqual(payload["missing_manifest_entries"], [])
            self.assertGreater(payload["summary"]["error_count"], 0)
            self.assertTrue(any(issue["level"] == "error" for issue in payload["issues"]))

    def test_verify_coverage_normalizes_query_suffixes(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {"/v1/files?beta=true": {"get": {"operationId": "listFiles"}}},
                        "components": {"schemas": {}},
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            files_dir = package_root / "lib" / "src" / "resources" / "files"
            files_dir.mkdir(parents=True, exist_ok=True)
            (files_dir / "files_resource.dart").write_text("class FilesResource {}\n")

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["implementation"]["coverage_gaps"], [])

    def test_verify_coverage_normalizes_fragment_suffixes(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {"/v1/conversations#stream": {"post": {"operationId": "streamConversation"}}},
                        "components": {"schemas": {}},
                    }
                )
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            conversations_dir = package_root / "lib" / "src" / "resources" / "conversations"
            conversations_dir.mkdir(parents=True, exist_ok=True)
            (conversations_dir / "conversations_resource.dart").write_text("class ConversationsResource {}\n")

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["implementation"]["coverage_gaps"], [])

    def test_verify_extension_without_schema_only_checks_linkage(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps({"openapi": "3.1.0", "info": {"title": "Sample", "version": "1"}, "paths": {}, "components": {"schemas": {}}})
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {"excluded_paths": [], "excluded_tags": [".*"]},
                    "types": {
                        "ToolChoice:Auto": {
                            "spec": "main",
                            "kind": "extension",
                            "dart_class": "ToolChoiceAuto",
                            "file": "lib/src/models/common/tool_choice.dart",
                            "parent": "ToolChoice",
                        }
                    },
                },
            )
            (package_root / "lib" / "src" / "models" / "common" / "tool_choice.dart").write_text(
                "class ToolChoice {}\nclass ToolChoiceAuto extends ToolChoice {}\n"
            )

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["implementation"]["issues"], [])

    def test_verify_extension_parent_lookup_accepts_manifest_key_alias(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps({"openapi": "3.1.0", "info": {"title": "Sample", "version": "1"}, "paths": {}, "components": {"schemas": {}}})
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {"excluded_paths": [], "excluded_tags": [".*"]},
                    "types": {
                        "ToolChoice": {
                            "spec": "main",
                            "kind": "sealed_parent",
                            "dart_class": "ToolChoiceParent",
                            "file": "lib/src/models/common/tool_choice.dart",
                        },
                        "ToolChoice:Auto": {
                            "spec": "main",
                            "kind": "extension",
                            "dart_class": "ToolChoiceAuto",
                            "file": "lib/src/models/common/tool_choice.dart",
                            "parent": "ToolChoice",
                        },
                    },
                },
            )
            (package_root / "lib" / "src" / "models" / "common" / "tool_choice.dart").write_text(
                "class ToolChoiceParent {}\nclass ToolChoiceAuto extends ToolChoiceParent {}\n"
            )

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["implementation"]["issues"], [])

    def test_verify_sealed_parent_lookup_accepts_manifest_key_alias(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Message": {
                            "spec": "main",
                            "kind": "sealed_parent",
                            "dart_class": "MessageEnvelope",
                            "file": "lib/src/models/common/message.dart",
                            "schema": None,
                            "discriminator": {
                                "field": "role",
                                "mapping": {
                                    "system": "#/components/schemas/SystemMessage",
                                    "user": "#/components/schemas/UserMessage",
                                },
                            },
                        },
                        "SystemMessage": {
                            "spec": "main",
                            "kind": "skip",
                            "dart_class": "SystemMessage",
                            "file": "lib/src/models/common/message.dart",
                            "schema": "SystemMessage",
                            "parent": "Message",
                        },
                        "UserMessage": {
                            "spec": "main",
                            "kind": "skip",
                            "dart_class": "UserMessage",
                            "file": "lib/src/models/common/message.dart",
                            "schema": "UserMessage",
                            "parent": "Message",
                        },
                    },
                },
            )
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "Message": {
                                    "oneOf": [
                                        {"$ref": "#/components/schemas/SystemMessage"},
                                        {"$ref": "#/components/schemas/UserMessage"},
                                    ],
                                    "discriminator": {
                                        "propertyName": "role",
                                        "mapping": {
                                            "system": "#/components/schemas/SystemMessage",
                                            "user": "#/components/schemas/UserMessage",
                                        },
                                    },
                                },
                                "SystemMessage": {"type": "object", "properties": {"role": {"type": "string"}}},
                                "UserMessage": {"type": "object", "properties": {"role": {"type": "string"}}},
                            }
                        },
                    }
                )
            )
            (package_root / "lib" / "src" / "models" / "common" / "message.dart").write_text(
                "sealed class MessageEnvelope {\n"
                "  factory MessageEnvelope.fromJson(Map<String, dynamic> json) {\n"
                "    if (json['role'] == 'system') return SystemMessage.fromJson(json);\n"
                "    return UserMessage.fromJson(json);\n"
                "  }\n"
                "}\n"
                "\n"
                "class SystemMessage extends MessageEnvelope {\n"
                "  factory SystemMessage.fromJson(Map<String, dynamic> json) => SystemMessage();\n"
                "}\n"
                "\n"
                "class UserMessage extends MessageEnvelope {\n"
                "  factory UserMessage.fromJson(Map<String, dynamic> json) => UserMessage();\n"
                "}\n"
            )

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 1)
            self.assertTrue(
                any("discriminator value 'user'" in issue["message"] for issue in payload["results"]["implementation"]["issues"])
            )

    def test_verify_exports_detects_missing_export(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps({"openapi": "3.1.0", "info": {"title": "Sample", "version": "1"}, "paths": {}, "components": {"schemas": {}}})
            )
            common_dir = package_root / "lib" / "src" / "models" / "common"
            (common_dir / "example.dart").write_text("class Example {}\n")
            (common_dir / "missing.dart").write_text("class Missing {}\n")
            (package_root / "lib" / "sample_dart.dart").write_text("export 'src/models/common/example.dart';\n")

            exit_code, payload = command_verify(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    checks="exports",
                    scope="all",
                    type_name=None,
                    baseline=None,
                    git_ref=None,
                )
            )

            self.assertEqual(exit_code, 1)
            self.assertIn("lib/src/models/common/missing.dart", payload["results"]["exports"]["missing_exports"])

    def test_verify_exports_detects_duplicate_basename_missing_export(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps({"openapi": "3.1.0", "info": {"title": "Sample", "version": "1"}, "paths": {}, "components": {"schemas": {}}})
            )
            common_dir = package_root / "lib" / "src" / "models" / "common"
            other_dir = package_root / "lib" / "src" / "models" / "other"
            other_dir.mkdir(parents=True, exist_ok=True)
            (common_dir / "content.dart").write_text("class CommonContent {}\n")
            (other_dir / "content.dart").write_text("class OtherContent {}\n")
            (package_root / "lib" / "sample_dart.dart").write_text("export 'src/models/common/content.dart';\n")

            exit_code, payload = command_verify(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    checks="exports",
                    scope="all",
                    type_name=None,
                    baseline=None,
                    git_ref=None,
                )
            )

            self.assertEqual(exit_code, 1)
            self.assertEqual(payload["results"]["exports"]["missing_exports"], ["lib/src/models/other/content.dart"])

    def test_verify_exports_uses_live_models_dir_for_websocket(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_websocket_config(root)
            (package_root / "specs" / "live.json").write_text(
                json.dumps({"info": {"title": "Live", "version": "1"}, "message_types": {}, "config_types": {}, "enums": {}})
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {
                        "live": {
                            "name": "Live",
                            "local_file": "live.json",
                            "fetch_mode": "local_file",
                            "source_file": "specs/live.json",
                            "experimental": False,
                            "websocket_endpoints": {"google_ai": "wss://example.com/live"},
                        }
                    },
                    "specs_dir": "packages/sample_ws_dart/specs",
                    "output_dir": str(root / "tmp" / "ws"),
                },
                manifest_payload={
                    "surface": "websocket",
                    "type_mappings": {},
                    "placement": {},
                    "coverage": {},
                    "types": {},
                },
            )
            live_file = package_root / "lib" / "src" / "models" / "live" / "messages" / "client" / "client_message.dart"
            live_file.write_text("class ClientMessage {}\n")
            ignored_file = package_root / "lib" / "src" / "models" / "common" / "missing.dart"
            ignored_file.write_text("class Missing {}\n")
            (package_root / "lib" / "sample_ws_dart.dart").write_text("export 'src/models/live/messages/client/client_message.dart';\n")

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name="live", checks="exports", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["exports"]["missing_exports"], [])

    def test_verify_exports_handles_circular_barrel_exports(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps({"openapi": "3.1.0", "info": {"title": "Sample", "version": "1"}, "paths": {}, "components": {"schemas": {}}})
            )
            (package_root / "lib" / "a.dart").write_text("export 'sample_dart.dart';\n")
            (package_root / "lib" / "sample_dart.dart").write_text(
                "export 'src/models/common/example.dart';\n"
                "export 'a.dart';\n"
            )

            exit_code, payload = command_verify(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    checks="exports",
                    scope="all",
                    type_name=None,
                    baseline=None,
                    git_ref=None,
                )
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["exports"]["missing_exports"], [])

    def test_verify_docs_flags_removed_api_reference(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps({"openapi": "3.1.0", "info": {"title": "Sample", "version": "1"}, "paths": {}, "components": {"schemas": {}}})
            )
            (config_dir / "documentation.json").write_text(
                json.dumps(
                    {
                        "removed_apis": [{"api": "OldApi"}],
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
            (package_root / "README.md").write_text("# Sample\n\nOldApi is still documented here.\n")

            exit_code, payload = command_verify(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    checks="docs",
                    scope="all",
                    type_name=None,
                    baseline=None,
                    git_ref=None,
                )
            )

            self.assertEqual(exit_code, 1)
            issues = payload["results"]["docs"]["issues"]
            self.assertTrue(any(issue["level"] == "error" and issue["name"] == "OldApi" for issue in issues))

    def test_verify_docs_flags_missing_tool_property_documentation(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            _, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            (config_dir / "documentation.json").write_text(
                json.dumps(
                    {
                        "removed_apis": [],
                        "tool_properties": {
                            "function_calling": {
                                "description": "Function/tool calling support",
                                "search_terms": ["function calling", "tools"],
                            }
                        },
                        "excluded_resources": [],
                        "resource_to_example": {},
                        "excluded_from_examples": [],
                        "drift_patterns": [],
                        "live_features": {},
                    },
                    indent=2,
                )
            )

            exit_code, payload = command_verify(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    checks="docs",
                    scope="all",
                    type_name=None,
                    baseline=None,
                    git_ref=None,
                )
            )

            self.assertEqual(exit_code, 1)
            issues = payload["results"]["docs"]["issues"]
            self.assertTrue(
                any(
                    issue["level"] == "error"
                    and issue["name"] == "function_calling"
                    and "Function/tool calling support" in issue["message"]
                    for issue in issues
                )
            )

    def test_verify_docs_accepts_documented_tool_property(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            (config_dir / "documentation.json").write_text(
                json.dumps(
                    {
                        "removed_apis": [],
                        "tool_properties": {
                            "function_calling": {
                                "description": "Function/tool calling support",
                                "search_terms": ["function calling", "tools"],
                            }
                        },
                        "excluded_resources": [],
                        "resource_to_example": {},
                        "excluded_from_examples": [],
                        "drift_patterns": [],
                        "live_features": {},
                    },
                    indent=2,
                )
            )
            (package_root / "README.md").write_text(
                "# Sample\n\nThis client supports function calling for tool-based workflows.\n"
            )

            exit_code, payload = command_verify(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    checks="docs",
                    scope="all",
                    type_name=None,
                    baseline=None,
                    git_ref=None,
                )
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["docs"]["issues"], [])

    def test_verify_docs_accepts_nested_resource_access_paths_and_parent_example_fallback(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps({"openapi": "3.1.0", "info": {"title": "Sample", "version": "1"}, "paths": {}, "components": {"schemas": {}}})
            )
            batch_dir = package_root / "lib" / "src" / "resources" / "batch"
            batch_dir.mkdir(parents=True, exist_ok=True)
            (batch_dir / "batch_resource.dart").write_text("class BatchResource {}\n")
            (batch_dir / "batch_jobs_resource.dart").write_text("class BatchJobsResource {}\n")
            (package_root / "README.md").write_text(
                "# Sample\n\nUse `client.batch.jobs.create()` to submit a batch job.\n"
            )
            (package_root / "example" / "batch_example.dart").write_text("void main() {}\n")

            exit_code, payload = command_verify(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    checks="docs",
                    scope="all",
                    type_name=None,
                    baseline=None,
                    git_ref=None,
                )
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["docs"]["issues"], [])

    def test_verify_sealed_parent_understands_raw_openapi_discriminator_mapping(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
                manifest_payload={
                    "surface": "openapi",
                    "type_mappings": {},
                    "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                    "coverage": {},
                    "types": {
                        "Message": {
                            "spec": "main",
                            "kind": "sealed_parent",
                            "dart_class": "Message",
                            "file": "lib/src/models/common/message.dart",
                            "schema": None,
                            "discriminator": {
                                "field": "role",
                                "mapping": {
                                    "system": "#/components/schemas/SystemMessage",
                                    "user": "#/components/schemas/UserMessage",
                                },
                            },
                        },
                        "SystemMessage": {
                            "spec": "main",
                            "kind": "skip",
                            "dart_class": "SystemMessage",
                            "file": "lib/src/models/common/message.dart",
                            "schema": "SystemMessage",
                            "parent": "Message",
                        },
                        "UserMessage": {
                            "spec": "main",
                            "kind": "skip",
                            "dart_class": "UserMessage",
                            "file": "lib/src/models/common/message.dart",
                            "schema": "UserMessage",
                            "parent": "Message",
                        },
                    },
                },
            )
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Sample", "version": "1"},
                        "paths": {},
                        "components": {
                            "schemas": {
                                "Message": {
                                    "oneOf": [
                                        {"$ref": "#/components/schemas/SystemMessage"},
                                        {"$ref": "#/components/schemas/UserMessage"},
                                    ],
                                    "discriminator": {
                                        "propertyName": "role",
                                        "mapping": {
                                            "system": "#/components/schemas/SystemMessage",
                                            "user": "#/components/schemas/UserMessage",
                                        },
                                    },
                                },
                                "SystemMessage": {
                                    "type": "object",
                                    "properties": {"role": {"type": "string"}},
                                },
                                "UserMessage": {
                                    "type": "object",
                                    "properties": {"role": {"type": "string"}},
                                },
                            }
                        },
                    }
                )
            )
            (package_root / "lib" / "src" / "models" / "common" / "message.dart").write_text(
                "sealed class Message {\n"
                "  factory Message.fromJson(Map<String, dynamic> json) {\n"
                "    if (json['role'] == 'system') return SystemMessage.fromJson(json);\n"
                "    return UserMessage.fromJson(json);\n"
                "  }\n"
                "}\n"
                "\n"
                "class SystemMessage extends Message {\n"
                "  factory SystemMessage.fromJson(Map<String, dynamic> json) => SystemMessage();\n"
                "}\n"
                "\n"
                "class UserMessage extends Message {\n"
                "  factory UserMessage.fromJson(Map<String, dynamic> json) => UserMessage();\n"
                "}\n"
            )

            config = load_toolkit_config(config_dir)
            issues = _verify_sealed_parent(
                config,
                config.manifest.types["Message"],
                [
                    config.manifest.types["SystemMessage"],
                    config.manifest.types["UserMessage"],
                ],
            )
            self.assertTrue(
                any(
                    issue["level"] == "error"
                    and "discriminator value 'user'" in issue["message"]
                    for issue in issues
                )
            )

    def test_verify_docs_respects_nested_short_key_exclusions(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps({"openapi": "3.1.0", "info": {"title": "Sample", "version": "1"}, "paths": {}, "components": {"schemas": {}}})
            )
            (config_dir / "documentation.json").write_text(
                json.dumps(
                    {
                        "removed_apis": [],
                        "tool_properties": {},
                        "excluded_resources": ["transcriptions"],
                        "resource_to_example": {},
                        "excluded_from_examples": ["transcriptions"],
                        "drift_patterns": [],
                        "live_features": {},
                    },
                    indent=2,
                )
            )
            audio_dir = package_root / "lib" / "src" / "resources" / "audio"
            audio_dir.mkdir(parents=True, exist_ok=True)
            (audio_dir / "transcriptions_resource.dart").write_text("class TranscriptionsResource {}\n")
            (package_root / "README.md").write_text("# Sample\n")

            exit_code, payload = command_verify(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    checks="docs",
                    scope="all",
                    type_name=None,
                    baseline=None,
                    git_ref=None,
                )
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(
                payload["results"]["docs"]["issues"],
                [
                    {
                        "level": "warning",
                        "name": "documentation",
                        "message": "Documentation verification is partial because documentation.json excludes resources or example checks",
                    }
                ],
            )

    def test_verify_docs_normalizes_nested_resource_example_aliases(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_openapi_config(root)
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {"main": {"name": "Sample API", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps({"openapi": "3.1.0", "info": {"title": "Sample", "version": "1"}, "paths": {}, "components": {"schemas": {}}})
            )
            (config_dir / "documentation.json").write_text(
                json.dumps(
                    {
                        "removed_apis": [],
                        "tool_properties": {},
                        "excluded_resources": [],
                        "resource_to_example": {"fileSearchStores": "completeApi"},
                        "excluded_from_examples": [],
                        "drift_patterns": [],
                        "live_features": {},
                    },
                    indent=2,
                )
            )
            stores_dir = package_root / "lib" / "src" / "resources" / "file_search_stores"
            stores_dir.mkdir(parents=True, exist_ok=True)
            (stores_dir / "file_search_stores_resource.dart").write_text("class FileSearchStoresResource {}\n")
            (package_root / "README.md").write_text("# Sample\n\nUse `client.fileSearchStores.create()` to create a store.\n")
            (package_root / "example" / "complete_api_example.dart").write_text("void main() {}\n")

            exit_code, payload = command_verify(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    checks="docs",
                    scope="all",
                    type_name=None,
                    baseline=None,
                    git_ref=None,
                )
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["docs"]["issues"], [])

    def test_verify_websocket_docs_uses_live_features(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            package_root, config_dir = self._create_websocket_config(root)
            (package_root / "specs" / "live.json").write_text(
                json.dumps({"info": {"title": "Live", "version": "1"}, "message_types": {}, "config_types": {}, "enums": {}})
            )
            self._write_specs_and_manifest(
                config_dir,
                specs_payload={
                    "specs": {
                        "live": {
                            "name": "Live",
                            "local_file": "live.json",
                            "fetch_mode": "local_file",
                            "source_file": "specs/live.json",
                            "experimental": False,
                            "websocket_endpoints": {"google_ai": "wss://example.com/live"},
                        }
                    },
                    "specs_dir": "packages/sample_ws_dart/specs",
                    "output_dir": str(root / "tmp" / "ws"),
                },
                manifest_payload={
                    "surface": "websocket",
                    "type_mappings": {},
                    "placement": {},
                    "coverage": {},
                    "types": {},
                },
            )
            (package_root / "README.md").write_text(
                "# Live Sample\n\nThis live client supports websocket streaming and tool calling.\n\n```dart\nsession.sendText('hi');\n```\n"
            )
            (package_root / "example" / "live_example.dart").write_text(
                "void main() {\n"
                "  final label = 'live client websocket tool calling';\n"
                "}\n"
            )

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name="live", checks="docs", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["docs"]["issues"], [])

    def test_selected_assets_use_local_sentinel_pattern(self) -> None:
        toolkit_root = Path(__file__).resolve().parents[1]
        model_template = (toolkit_root / "assets" / "model_template.dart").read_text()
        sealed_template = (toolkit_root / "assets" / "sealed_message_template.dart").read_text()

        for content in (model_template, sealed_template):
            self.assertNotIn("copy_with_sentinel.dart", content)
            self.assertIn("const Object _unsetCopyWithValue = _UnsetCopyWithSentinel();", content)
            self.assertIn("class _UnsetCopyWithSentinel {", content)


if __name__ == "__main__":
    unittest.main()
