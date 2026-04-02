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
from api_toolkit.config import ManifestEntry, ToolkitError, load_toolkit_config
from api_toolkit.operations import (
    _verify_sealed_parent,
    _verify_sealed_parent_variant_coverage,
    command_create,
    command_describe,
    command_fetch,
    command_generate_llms_txt,
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

    def _write_llms_workspace(self, root: Path) -> None:
        (root / "pubspec.yaml").write_text(
            "name: workspace\n"
            "description: Workspace summary for llms.txt generation.\n"
            "publish_to: none\n"
            "workspace:\n"
            "  - packages/existing\n"
            "melos:\n"
            "  repository: https://github.com/example/ai_clients_dart\n"
        )

    def _write_llms_package(
        self,
        root: Path,
        *,
        name: str,
        description: str,
        readme: str,
        example_files: dict[str, str],
        include_changelog: bool = False,
        include_migration: bool = False,
    ) -> Path:
        package_root = root / "packages" / name
        (package_root / "example").mkdir(parents=True)
        (package_root / "pubspec.yaml").write_text(
            f"name: {name}\n"
            f"description: {description}\n"
            "version: 0.1.0\n"
            f"repository: https://github.com/example/ai_clients_dart/tree/main/packages/{name}\n"
        )
        (package_root / "README.md").write_text(readme)
        for filename, content in example_files.items():
            (package_root / "example" / filename).write_text(content)
        if include_changelog:
            (package_root / "CHANGELOG.md").write_text("## 0.1.0\n\n- Initial release.\n")
        if include_migration:
            (package_root / "MIGRATION.md").write_text("# Migration\n\nUpgrade notes.\n")
        return package_root

    def _write_canonical_readme(
        self,
        package_root: Path,
        *,
        include_examples: bool = True,
        llms_callout_position: str = "top",
    ) -> None:
        llms_callout = (
            "> [!TIP]\n"
            "> Coding agents: start with [llms.txt](./llms.txt). It links to the package docs, examples, and optional references in a compact format.\n\n"
        )
        sections = [
            "# Sample Dart Client\n\n",
        ]
        if llms_callout_position == "top":
            sections.append(llms_callout)
        sections.extend(
            [
                "[![sample_dart](https://img.shields.io/pub/v/sample_dart.svg)](https://pub.dev/packages/sample_dart)\n\n",
                "Dart client for the **Sample API** API. Works with Dart and Flutter on iOS, Android, macOS, Windows, Linux, Web, and server-side Dart.\n\n",
                "<details>\n"
                "<summary><b>Table of Contents</b></summary>\n\n"
                "- [Features](#features)\n"
                "- [Why choose this client?](#why-choose-this-client)\n"
                "- [Quickstart](#quickstart)\n"
                "- [Configuration](#configuration)\n"
                "- [Usage](#usage)\n"
                "- [Error Handling](#error-handling)\n"
                "- [Examples](#examples)\n"
                "- [API Coverage](#api-coverage)\n"
                "- [Official Documentation](#official-documentation)\n"
                "- [Sponsor](#sponsor)\n"
                "- [License](#license)\n\n"
                "</details>\n\n",
            ]
        )
        if llms_callout_position == "after_intro":
            sections.append(llms_callout)
        sections.extend(
            [
                "## Features\n\n"
                "Coverage: `sample_dart` covers the primary Sample workflows for Dart and Flutter applications.\n\n",
                "## Why choose this client?\n\n"
                "- Pure Dart client\n\n",
                "## Quickstart\n\n"
                "```yaml\n"
                "dependencies:\n"
                "  sample_dart: ^0.1.0\n"
                "```\n\n"
                "```dart\n"
                "Future<void> main() async {}\n"
                "```\n\n",
            ]
        )
        sections.extend(
            [
                "## Configuration\n\n"
                "<details>\n"
                "<summary><b>Configuration options</b></summary>\n\n"
                "Document environment variables here.\n\n"
                "</details>\n\n",
                "## Usage\n\n"
                "### How do I make my first request?\n\n"
                "```dart\n"
                "Future<void> main() async {}\n"
                "```\n\n"
                "→ [Full example](example/example.dart)\n\n",
                "## Error Handling\n\n"
                "```dart\n"
                "Future<void> main() async {}\n"
                "```\n\n",
            ]
        )
        if include_examples:
            sections.extend(
                [
                    "## Examples\n\n"
                    "| Example | Description |\n"
                    "|---------|-------------|\n"
                    "| [`example.dart`](example/example.dart) | Package overview example |\n\n",
                    "## API Coverage\n\n"
                    "| API | Status |\n"
                    "|-----|--------|\n"
                    "| Sample | ✅ Full |\n\n",
                    "## Official Documentation\n\n"
                    "- [Sample API Reference](https://example.com/docs)\n\n",
                ]
            )
        sections.extend(
            [
                f"## Sponsor\n\n{toolkit_operations.SPONSOR_PARAGRAPH}\n\n",
                "## License\n\n"
                "This package is licensed under the [MIT License](LICENSE).\n\n",
            ]
        )
        if llms_callout_position == "after_toc":
            sections.insert(4, llms_callout)
        (package_root / "README.md").write_text("".join(sections))
        (package_root / "example" / "example.dart").write_text("void main() {}\n")

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

    def test_create_succeeds_when_shared_template_headings_change(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_workspace(root)
            self._write_repo_license(root)
            spec_file = root / "spec.json"
            spec_file.write_text(
                json.dumps(
                    {
                        "openapi": "3.1.0",
                        "info": {"title": "Template API", "version": "1"},
                        "paths": {},
                        "components": {"schemas": {}},
                    }
                )
            )
            previous_cwd = Path.cwd()
            try:
                os.chdir(root)
                with patch.object(
                    toolkit_operations,
                    "_load_shared_readme_template",
                    return_value="# arbitrary template\n",
                ):
                    exit_code, _ = command_create(
                        SimpleNamespace(
                            package_name="template_client_dart",
                            display_name="Template Client",
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
            readme_text = (root / "packages" / "template_client_dart" / "README.md").read_text()
            self.assertIn("# Template Client Dart Client", readme_text)

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
            readme_text = (package_root / "README.md").read_text()
            self.assertIn("- [Examples](#examples)", readme_text)
            self.assertIn("## Examples", readme_text)
            self.assertIn("## API Coverage", readme_text)
            self.assertIn("## Official Documentation", readme_text)
            self.assertIn("[llms.txt](./llms.txt)", readme_text)
            self.assertLess(readme_text.index("# Bootstrap Client Dart Client"), readme_text.index("[llms.txt](./llms.txt)"))
            self.assertLess(readme_text.index("[![bootstrap_client_dart]"), readme_text.index("[llms.txt](./llms.txt)"))
            self.assertLess(readme_text.index("[llms.txt](./llms.txt)"), readme_text.index("## Features"))
            self.assertIn(toolkit_operations.SPONSOR_PARAGRAPH, readme_text)
            self.assertIn(toolkit_operations.SPONSOR_WIDGET, readme_text)
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
            self.assertIn("'optionalNumber': ?optionalNumber,", preview)

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

    def test_verify_enum_inline_fallback_via_enum_values(self) -> None:
        """When spec has no schema for an inline enum, manifest enum_values are used."""
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
                    "coverage": {},
                    "types": {
                        "InlineRole": {
                            "spec": "main",
                            "kind": "enum",
                            "dart_class": "InlineRole",
                            "file": "lib/src/models/common/inline_role.dart",
                            "schema": "InlineRole",
                            "enum_values": ["user", "assistant"],
                        }
                    },
                },
            )
            (package_root / "lib" / "src" / "models" / "common" / "inline_role.dart").write_text(
                "enum InlineRole {\n"
                "  user,\n"
                "  assistant,\n"
                "  unknown,\n"
                "}\n"
            )

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            issues = payload["results"]["implementation"]["issues"]
            # Should NOT have "No enum values found" error (fallback to enum_values).
            self.assertFalse(
                any("No enum values found" in issue["message"] for issue in issues),
                f"Expected no 'No enum values found' error, got: {issues}",
            )
            self.assertEqual(exit_code, 0)

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

    def test_verify_docs_resource_in_readme_display_name_fallback(self) -> None:
        """Resource mentioned by display name in prose (not client.X) should not be flagged as missing."""
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
            # Create a resource discovered from lib/src/resources/
            (package_root / "lib" / "src" / "resources" / "cached_contents_resource.dart").write_text("class CachedContentsResource {}\n")
            # README mentions the resource via display name (space-separated) but NOT via client.cachedContents
            self._write_canonical_readme(package_root)
            readme = (package_root / "README.md").read_text()
            readme += "\n## API Coverage\n\n| API | Status |\n|-----|--------|\n| Cached contents | ✅ Full |\n\n"
            (package_root / "README.md").write_text(readme)

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="docs", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            issues = payload["results"]["docs"]["issues"]
            # The display-name fallback should match "cached contents" in the table.
            self.assertFalse(
                any("cached_contents" in issue.get("name", "") and "missing from README" in issue.get("message", "") for issue in issues),
                f"Expected no 'missing from README' error for cached_contents, got: {issues}",
            )

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

    def test_verify_endpoint_action_mismatch(self) -> None:
        """Resource file exists but does not contain the spec's action suffix."""
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
                        "paths": {
                            "/v1/widgets/{widget}:uploadToWidget": {
                                "post": {"operationId": "uploadToWidget"},
                            },
                        },
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
            # Resource file exists but uses wrong action
            (package_root / "lib" / "src" / "resources" / "widgets_resource.dart").write_text(
                "class WidgetsResource { void upload() {} }\n"
            )

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            # Endpoint-action mismatches are warnings, so exit_code is still 0
            self.assertEqual(exit_code, 0)
            impl = payload["results"]["implementation"]
            self.assertTrue(impl["endpoint_action_mismatches"])
            self.assertTrue(
                any("uploadToWidget" in issue["message"] for issue in impl["endpoint_action_mismatches"])
            )

    def test_verify_endpoint_action_match(self) -> None:
        """Resource file contains the spec's action suffix — no issue."""
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
                        "paths": {
                            "/v1/widgets/{widget}:generateContent": {
                                "post": {"operationId": "generateContent"},
                            },
                        },
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
            (package_root / "lib" / "src" / "resources" / "widgets_resource.dart").write_text(
                "class WidgetsResource { void doStuff() { buildUrl(':generateContent'); } }\n"
            )

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            self.assertEqual(exit_code, 0)
            impl = payload["results"]["implementation"]
            self.assertEqual(impl["endpoint_action_mismatches"], [])

    def test_verify_endpoint_action_no_resource_file(self) -> None:
        """No resource file for the endpoint — skip (coverage_gaps handles it)."""
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
                        "paths": {
                            "/v1/missing/{id}:doSomething": {
                                "post": {"operationId": "doSomething"},
                            },
                        },
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
            # No resource file at all — endpoint_action_issues should not flag this

            exit_code, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )

            # Coverage gaps cause exit_code=1
            self.assertEqual(exit_code, 1)
            impl = payload["results"]["implementation"]
            self.assertEqual(impl["endpoint_action_mismatches"], [])
            # But coverage_gaps should catch it
            self.assertTrue(impl["coverage_gaps"])

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

    def test_verify_sealed_parent_variant_coverage_complete(self) -> None:
        """When all spec union members are in the mapping, no warnings."""
        entry = ManifestEntry(
            key="ContentPart",
            spec="main",
            kind="sealed_parent",
            dart_class="ContentPart",
            file="lib/src/models/chat/content_part.dart",
            schema=None,
            discriminator={
                "field": "type",
                "mapping": {
                    "TextPart": "text",
                    "ImagePart": "image_url",
                },
            },
        )
        spec_payload = {
            "components": {
                "schemas": {
                    "UserContentPart": {
                        "anyOf": [
                            {"$ref": "#/components/schemas/TextPart"},
                            {"$ref": "#/components/schemas/ImagePart"},
                        ],
                    },
                    "TextPart": {"type": "object", "properties": {}},
                    "ImagePart": {"type": "object", "properties": {}},
                }
            }
        }
        issues = _verify_sealed_parent_variant_coverage(entry, spec_payload)
        self.assertEqual(issues, [])

    def test_verify_sealed_parent_variant_coverage_missing_member(self) -> None:
        """When a spec union member is missing from the mapping, emit a warning."""
        entry = ManifestEntry(
            key="ContentPart",
            spec="main",
            kind="sealed_parent",
            dart_class="ContentPart",
            file="lib/src/models/chat/content_part.dart",
            schema=None,
            discriminator={
                "field": "type",
                "mapping": {
                    "TextPart": "text",
                    "ImagePart": "image_url",
                },
            },
        )
        spec_payload = {
            "components": {
                "schemas": {
                    "UserContentPart": {
                        "anyOf": [
                            {"$ref": "#/components/schemas/TextPart"},
                            {"$ref": "#/components/schemas/ImagePart"},
                            {"$ref": "#/components/schemas/FilePart"},
                        ],
                    },
                    "TextPart": {"type": "object", "properties": {}},
                    "ImagePart": {"type": "object", "properties": {}},
                    "FilePart": {"type": "object", "properties": {}},
                }
            }
        }
        issues = _verify_sealed_parent_variant_coverage(entry, spec_payload)
        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0]["level"], "warning")
        self.assertIn("FilePart", issues[0]["message"])
        self.assertIn("UserContentPart", issues[0]["message"])
        self.assertIn("ContentPart", issues[0]["name"])

    def test_verify_sealed_parent_variant_coverage_multiple_unions(self) -> None:
        """When multiple spec unions reference the mapping, all are checked."""
        entry = ManifestEntry(
            key="ContentPart",
            spec="main",
            kind="sealed_parent",
            dart_class="ContentPart",
            file="lib/src/models/chat/content_part.dart",
            schema=None,
            discriminator={
                "field": "type",
                "mapping": {
                    "TextPart": "text",
                },
            },
        )
        spec_payload = {
            "components": {
                "schemas": {
                    "UserContentPart": {
                        "anyOf": [
                            {"$ref": "#/components/schemas/TextPart"},
                            {"$ref": "#/components/schemas/FilePart"},
                        ],
                    },
                    "AssistantContentPart": {
                        "anyOf": [
                            {"$ref": "#/components/schemas/TextPart"},
                            {"$ref": "#/components/schemas/RefusalPart"},
                        ],
                    },
                    "TextPart": {"type": "object", "properties": {}},
                    "FilePart": {"type": "object", "properties": {}},
                    "RefusalPart": {"type": "object", "properties": {}},
                }
            }
        }
        issues = _verify_sealed_parent_variant_coverage(entry, spec_payload)
        # Should warn about FilePart (from UserContentPart) and RefusalPart (from AssistantContentPart)
        self.assertEqual(len(issues), 2)
        messages = {issue["message"] for issue in issues}
        self.assertTrue(any("FilePart" in m for m in messages))
        self.assertTrue(any("RefusalPart" in m for m in messages))

    def test_verify_sealed_parent_variant_coverage_raw_openapi_mapping(self) -> None:
        """Works with raw OpenAPI-style mapping ({value: $ref})."""
        entry = ManifestEntry(
            key="ContentPart",
            spec="main",
            kind="sealed_parent",
            dart_class="ContentPart",
            file="lib/src/models/chat/content_part.dart",
            schema=None,
            discriminator={
                "field": "type",
                "mapping": {
                    "text": "#/components/schemas/TextPart",
                    "image_url": "#/components/schemas/ImagePart",
                },
            },
        )
        spec_payload = {
            "components": {
                "schemas": {
                    "ContentPartUnion": {
                        "anyOf": [
                            {"$ref": "#/components/schemas/TextPart"},
                            {"$ref": "#/components/schemas/ImagePart"},
                            {"$ref": "#/components/schemas/AudioPart"},
                        ],
                    },
                    "TextPart": {"type": "object", "properties": {}},
                    "ImagePart": {"type": "object", "properties": {}},
                    "AudioPart": {"type": "object", "properties": {}},
                }
            }
        }
        issues = _verify_sealed_parent_variant_coverage(entry, spec_payload)
        self.assertEqual(len(issues), 1)
        self.assertIn("AudioPart", issues[0]["message"])

    def test_verify_sealed_parent_variant_coverage_dart_class_keys(self) -> None:
        """When mapping keys are Dart class names, cross-reference via variants to find schema names."""
        entry = ManifestEntry(
            key="ContentBlock",
            spec="main",
            kind="sealed_parent",
            dart_class="ContentBlock",
            file="lib/src/models/content_block.dart",
            schema=None,
            discriminator={
                "field": "type",
                "mapping": {
                    "TextBlock": "text",
                    "ImageBlock": "image",
                },
            },
        )
        variants = [
            ManifestEntry(
                key="ResponseTextBlock",
                spec="main",
                kind="sealed_variant",
                dart_class="TextBlock",
                file="lib/src/models/content_block.dart",
                schema="ResponseTextBlock",
                parent="ContentBlock",
            ),
            ManifestEntry(
                key="ResponseImageBlock",
                spec="main",
                kind="sealed_variant",
                dart_class="ImageBlock",
                file="lib/src/models/content_block.dart",
                schema="ResponseImageBlock",
                parent="ContentBlock",
            ),
        ]
        spec_payload = {
            "components": {
                "schemas": {
                    "ContentBlockUnion": {
                        "anyOf": [
                            {"$ref": "#/components/schemas/ResponseTextBlock"},
                            {"$ref": "#/components/schemas/ResponseImageBlock"},
                            {"$ref": "#/components/schemas/ResponseToolBlock"},
                        ],
                    },
                    "ResponseTextBlock": {"type": "object", "properties": {}},
                    "ResponseImageBlock": {"type": "object", "properties": {}},
                    "ResponseToolBlock": {"type": "object", "properties": {}},
                }
            }
        }
        # Without variants, mapping keys (Dart class names) don't match $ref schema names,
        # so the function finds no overlap and produces 0 warnings (false negative).
        issues_without = _verify_sealed_parent_variant_coverage(entry, spec_payload)
        self.assertEqual(issues_without, [])

        # With variants, Dart class names are cross-referenced to schema names.
        issues_with = _verify_sealed_parent_variant_coverage(entry, spec_payload, variants)
        # Now it should detect ResponseToolBlock is missing.
        self.assertEqual(len(issues_with), 1)
        self.assertIn("ResponseToolBlock", issues_with[0]["message"])

    def test_verify_sealed_parent_variant_coverage_ancestor_mapping(self) -> None:
        """Missing members covered by an ancestor discriminator should not warn."""
        # Hierarchy: Item → MessageItem → InputMessage/OutputMessage
        # Item's discriminator covers MessageItem and FunctionCallItem.
        # MessageItem's discriminator covers InputMessage and OutputMessage.
        # The spec union references all concrete types — MessageItem should not
        # warn about FunctionCallItem because Item's mapping covers it.
        grandparent = ManifestEntry(
            key="Item",
            spec="main",
            kind="sealed_parent",
            dart_class="Item",
            file="lib/src/models/item.dart",
            schema=None,
            discriminator={
                "field": "type",
                "mapping": {
                    "MessageItem": "message",
                    "FunctionCallItem": "function_call",
                },
            },
        )
        parent = ManifestEntry(
            key="MessageItem",
            spec="main",
            kind="sealed_parent",
            dart_class="MessageItem",
            file="lib/src/models/item.dart",
            schema=None,
            parent="Item",
            discriminator={
                "field": "role",
                "mapping": {
                    "InputMessage": "user",
                    "OutputMessage": "assistant",
                },
            },
        )
        all_types = {
            "Item": grandparent,
            "MessageItem": parent,
        }
        spec_payload = {
            "components": {
                "schemas": {
                    "ItemUnion": {
                        "anyOf": [
                            {"$ref": "#/components/schemas/InputMessage"},
                            {"$ref": "#/components/schemas/OutputMessage"},
                            {"$ref": "#/components/schemas/FunctionCallItem"},
                        ],
                    },
                    "InputMessage": {"type": "object", "properties": {}},
                    "OutputMessage": {"type": "object", "properties": {}},
                    "FunctionCallItem": {"type": "object", "properties": {}},
                }
            }
        }
        issues = _verify_sealed_parent_variant_coverage(parent, spec_payload, all_types=all_types)
        # FunctionCallItem is covered by ancestor Item's mapping — no warnings expected.
        self.assertEqual(issues, [])

    def test_verify_sealed_parent_variant_coverage_ancestor_skips_no_discriminator(self) -> None:
        """Ancestor without discriminator should not stop the walk."""
        # Hierarchy: Root → Middle (no discriminator) → Leaf
        # Root has a discriminator that covers Sibling.
        root = ManifestEntry(
            key="Root",
            spec="main",
            kind="sealed_parent",
            dart_class="Root",
            file="lib/src/models/root.dart",
            schema=None,
            discriminator={
                "field": "type",
                "mapping": {
                    "Sibling": "sibling",
                    "Middle": "middle",
                },
            },
        )
        middle = ManifestEntry(
            key="Middle",
            spec="main",
            kind="sealed_parent",
            dart_class="Middle",
            file="lib/src/models/root.dart",
            schema=None,
            parent="Root",
            # No discriminator on this intermediate level.
        )
        leaf = ManifestEntry(
            key="Leaf",
            spec="main",
            kind="sealed_parent",
            dart_class="Leaf",
            file="lib/src/models/root.dart",
            schema=None,
            parent="Middle",
            discriminator={
                "field": "kind",
                "mapping": {
                    "LeafA": "a",
                },
            },
        )
        all_types = {"Root": root, "Middle": middle, "Leaf": leaf}
        spec_payload = {
            "components": {
                "schemas": {
                    "LeafUnion": {
                        "anyOf": [
                            {"$ref": "#/components/schemas/LeafA"},
                            {"$ref": "#/components/schemas/Sibling"},
                        ],
                    },
                    "LeafA": {"type": "object", "properties": {}},
                    "Sibling": {"type": "object", "properties": {}},
                }
            }
        }
        issues = _verify_sealed_parent_variant_coverage(leaf, spec_payload, all_types=all_types)
        # Sibling is covered by Root's mapping — walk should continue past Middle.
        self.assertEqual(issues, [])

    def test_verify_sealed_parent_variant_coverage_ancestor_dart_class_keys(self) -> None:
        """Ancestor mapping with Dart class keys should cross-reference to schema names."""
        grandparent = ManifestEntry(
            key="Item",
            spec="main",
            kind="sealed_parent",
            dart_class="Item",
            file="lib/src/models/item.dart",
            schema=None,
            discriminator={
                "field": "type",
                "mapping": {
                    # Dart class name as key (differs from schema name)
                    "FnCallItem": "function_call",
                },
            },
        )
        fn_call_variant = ManifestEntry(
            key="FunctionCallItem",
            spec="main",
            kind="sealed_variant",
            dart_class="FnCallItem",
            file="lib/src/models/item.dart",
            schema="FunctionCallItem",
            parent="Item",
        )
        child = ManifestEntry(
            key="MessageItem",
            spec="main",
            kind="sealed_parent",
            dart_class="MessageItem",
            file="lib/src/models/item.dart",
            schema=None,
            parent="Item",
            discriminator={
                "field": "role",
                "mapping": {
                    "InputMessage": "user",
                },
            },
        )
        all_types = {
            "Item": grandparent,
            "FunctionCallItem": fn_call_variant,
            "MessageItem": child,
        }
        spec_payload = {
            "components": {
                "schemas": {
                    "ItemUnion": {
                        "anyOf": [
                            {"$ref": "#/components/schemas/InputMessage"},
                            {"$ref": "#/components/schemas/FunctionCallItem"},
                        ],
                    },
                    "InputMessage": {"type": "object", "properties": {}},
                    "FunctionCallItem": {"type": "object", "properties": {}},
                }
            }
        }
        issues = _verify_sealed_parent_variant_coverage(child, spec_payload, all_types=all_types)
        # FunctionCallItem should be resolved via ancestor dart_to_schema cross-reference.
        self.assertEqual(issues, [])

    def test_verify_sealed_parent_variant_coverage_skip_non_object(self) -> None:
        """Non-object union members (e.g., string enums) should be skipped."""
        entry = ManifestEntry(
            key="ContentPart",
            spec="main",
            kind="sealed_parent",
            dart_class="ContentPart",
            file="lib/src/models/content_part.dart",
            schema=None,
            discriminator={
                "field": "type",
                "mapping": {
                    "TextPart": "text",
                },
            },
        )
        spec_payload = {
            "components": {
                "schemas": {
                    "ContentPartUnion": {
                        "anyOf": [
                            {"$ref": "#/components/schemas/TextPart"},
                            {"$ref": "#/components/schemas/ContentPartRole"},
                        ],
                    },
                    "TextPart": {"type": "object", "properties": {}},
                    "ContentPartRole": {"type": "string", "enum": ["user", "assistant"]},
                }
            }
        }
        issues = _verify_sealed_parent_variant_coverage(entry, spec_payload)
        # ContentPartRole is a string enum — should be skipped, no warning.
        self.assertEqual(issues, [])

    def test_verify_sealed_parent_variant_coverage_skip_non_object_array_type(self) -> None:
        """OpenAPI 3.1 array-typed type field: nullable objects should not be skipped."""
        entry = ManifestEntry(
            key="ContentPart",
            spec="main",
            kind="sealed_parent",
            dart_class="ContentPart",
            file="lib/src/models/content_part.dart",
            schema=None,
            discriminator={
                "field": "type",
                "mapping": {
                    "TextPart": "text",
                },
            },
        )
        spec_payload = {
            "components": {
                "schemas": {
                    "ContentPartUnion": {
                        "anyOf": [
                            {"$ref": "#/components/schemas/TextPart"},
                            {"$ref": "#/components/schemas/NullableObject"},
                            {"$ref": "#/components/schemas/StringEnum"},
                        ],
                    },
                    "TextPart": {"type": "object", "properties": {}},
                    # OpenAPI 3.1 nullable object — should NOT be skipped.
                    "NullableObject": {"type": ["object", "null"], "properties": {}},
                    # OpenAPI 3.1 nullable string — should be skipped.
                    "StringEnum": {"type": ["string", "null"], "enum": ["a", "b"]},
                }
            }
        }
        issues = _verify_sealed_parent_variant_coverage(entry, spec_payload)
        # NullableObject should warn (it's an object), StringEnum should not.
        self.assertEqual(len(issues), 1)
        self.assertIn("NullableObject", issues[0]["message"])

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

    def test_verify_docs_client_utility_methods_not_flagged_as_stale(self) -> None:
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
            # Client with regular utility methods and named factory constructors
            client_dir = package_root / "lib" / "src" / "client"
            client_dir.mkdir(parents=True)
            (client_dir / "sample_client.dart").write_text(
                "class SampleClient {\n"
                "  factory SampleClient.fromEnvironment() => SampleClient._();\n"
                "  SampleClient._();\n"
                "  void close() {}\n"
                "}\n"
            )
            # Live client in a subdirectory (not lib/src/client/)
            live_dir = package_root / "lib" / "src" / "live"
            live_dir.mkdir(parents=True)
            (live_dir / "live_client.dart").write_text(
                "class LiveClient {\n"
                "  Future<void> connect() async {}\n"
                "  Future<void> resume(String id) async {}\n"
                "}\n"
            )
            # README references these utility methods — should NOT trigger stale warnings
            (package_root / "README.md").write_text(
                "# Sample\n\n"
                "Use `client.close()` to release resources.\n"
                "Use `client.fromEnvironment()` to create from env.\n"
                "Use `liveClient.connect()` to start a session.\n"
                "Use `liveClient.resume(id)` to resume.\n"
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
            docs_issues = payload["results"]["docs"]["issues"]
            stale_warnings = [i for i in docs_issues if i.get("level") == "warning" and "stale" in i.get("message", "").lower()]
            self.assertEqual(stale_warnings, [], f"Unexpected stale-reference warnings: {stale_warnings}")

    def test_verify_readme_reports_missing_examples_section(self) -> None:
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
                            "source_file": "specs/openapi.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            self._write_canonical_readme(package_root, include_examples=False)

            exit_code, payload = command_verify(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    checks="readme",
                    scope="all",
                    type_name=None,
                    baseline=None,
                    git_ref=None,
                )
            )

            self.assertEqual(exit_code, 0)
            issues = payload["results"]["readme"]["issues"]
            missing_names = [i["name"] for i in issues if "missing" in i["message"].lower()]
            self.assertIn("Examples", missing_names, issues)
            self.assertIn("API Coverage", missing_names, issues)
            self.assertIn("Official Documentation", missing_names, issues)

    def test_verify_readme_reports_missing_llms_link(self) -> None:
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
                            "source_file": "specs/openapi.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            self._write_canonical_readme(package_root, llms_callout_position="missing")

            exit_code, payload = command_verify(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    checks="readme",
                    scope="all",
                    type_name=None,
                    baseline=None,
                    git_ref=None,
                )
            )

            self.assertEqual(exit_code, 0)
            issues = payload["results"]["readme"]["issues"]
            self.assertTrue(
                any(issue["name"] == "llms.txt" and "./llms.txt" in issue["message"] for issue in issues),
                issues,
            )

    def test_verify_readme_passes_with_all_required_sections(self) -> None:
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
                            "source_file": "specs/openapi.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            self._write_canonical_readme(package_root)

            exit_code, payload = command_verify(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    checks="readme",
                    scope="all",
                    type_name=None,
                    baseline=None,
                    git_ref=None,
                )
            )

            self.assertEqual(exit_code, 0)
            self.assertEqual(payload["results"]["readme"]["issues"], [])

    def test_verify_readme_reports_llms_callout_after_intro(self) -> None:
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
                            "source_file": "specs/openapi.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            self._write_canonical_readme(package_root, llms_callout_position="after_intro")

            exit_code, payload = command_verify(
                SimpleNamespace(
                    config_dir=config_dir,
                    spec_name=None,
                    checks="readme",
                    scope="all",
                    type_name=None,
                    baseline=None,
                    git_ref=None,
                )
            )

            self.assertEqual(exit_code, 0)
            issues = payload["results"]["readme"]["issues"]
            self.assertFalse(
                any(issue["name"] == "llms.txt" for issue in issues),
                "llms.txt callout after intro should be accepted",
            )

    def test_generate_llms_txt_package_mode_emits_link_hub_and_preserves_identifiers(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_llms_workspace(root)
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
                            "source_file": "specs/openapi.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                    "output_dir": str(root / "tmp" / "sample"),
                },
            )
            (package_root / "specs" / "openapi.json").write_text(
                json.dumps({"openapi": "3.1.0", "info": {"title": "Sample", "version": "1"}, "paths": {}, "components": {"schemas": {}}})
            )
            (package_root / "pubspec.yaml").write_text(
                "name: sample_dart\n"
                "description: Package for anthropic_sdk_dart and OPENAI_API_KEY examples.\n"
                "version: 0.1.0\n"
                "repository: https://github.com/example/ai_clients_dart/tree/main/packages/sample_dart\n"
            )
            (package_root / "README.md").write_text(
                "# Sample Dart Client\n\n"
                "Dart client for `anthropic_sdk_dart` workflows that rely on `OPENAI_API_KEY`.\n\n"
                "## Usage\n\n"
                "### How do I stream events?\n\n"
                "→ [Full example](example/streaming_example.dart)\n"
            )
            (package_root / "CHANGELOG.md").write_text("## 0.1.0\n\n- Initial release.\n")
            (package_root / "MIGRATION.md").write_text("# Migration\n\nUpgrade notes.\n")
            (package_root / "example" / "streaming_example.dart").write_text("void main() {}\n")

            with patch.object(toolkit_config, "yaml", None), patch.object(toolkit_config, "HAS_YAML", False):
                exit_code, payload = command_generate_llms_txt(
                    SimpleNamespace(config_dir=config_dir, repo_root=None, dry_run=True)
                )

            self.assertEqual(exit_code, 0)
            preview = payload["preview"]
            self.assertTrue(preview.startswith("# Sample Dart Client\n\n> Dart client for anthropic_sdk_dart workflows"))
            self.assertIn("anthropic_sdk_dart", preview)
            self.assertIn("OPENAI_API_KEY", preview)
            self.assertIn("## Docs", preview)
            self.assertIn("## Examples", preview)
            self.assertIn("## Optional", preview)
            self.assertIn(
                "[README](https://github.com/example/ai_clients_dart/blob/main/packages/sample_dart/README.md)",
                preview,
            )
            self.assertIn(
                "[CHANGELOG](https://github.com/example/ai_clients_dart/blob/main/packages/sample_dart/CHANGELOG.md)",
                preview,
            )
            self.assertIn(
                "[MIGRATION](https://github.com/example/ai_clients_dart/blob/main/packages/sample_dart/MIGRATION.md)",
                preview,
            )
            self.assertIn(
                "[streaming_example.dart](https://github.com/example/ai_clients_dart/blob/main/packages/sample_dart/example/streaming_example.dart)",
                preview,
            )
            self.assertIn("[Package directory](https://github.com/example/ai_clients_dart/tree/main/packages/sample_dart)", preview)
            self.assertNotIn("```", preview)
            self.assertNotIn("Platforms:", preview)
            self.assertNotIn("Quickstart entry point:", preview)

    def test_generate_llms_txt_repo_mode_builds_ctx_files_and_fallback_examples(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_llms_workspace(root)
            self._write_repo_license(root)
            (root / "README.md").write_text(
                "# Workspace README\n\n"
                "Repository overview for optional context.\n\n"
                "## Usage\n\n"
                "```md\n"
                "# Literal code heading\n"
                "## Another literal code heading\n"
                "```\n"
            )
            self._write_llms_package(
                root,
                name="alpha_dart",
                description="Alpha package.",
                readme=(
                    "# Alpha Dart Client\n\n"
                    "Dart client for alpha provider flows.\n\n"
                    "## Usage\n\n"
                    "### How do I send alpha requests?\n\n"
                    "→ [Full example](example/alpha_example.dart)\n"
                ),
                example_files={"alpha_example.dart": "void main() {}\n"},
                include_changelog=True,
            )
            self._write_llms_package(
                root,
                name="beta_dart",
                description="Beta package.",
                readme="# Beta Dart Client\n\nDart client for beta provider flows.\n",
                example_files={"fallback_demo.dart": "void main() {}\n"},
            )

            with patch.object(toolkit_config, "yaml", None), patch.object(toolkit_config, "HAS_YAML", False):
                exit_code, payload = command_generate_llms_txt(
                    SimpleNamespace(config_dir=None, repo_root=root, dry_run=True)
                )

            self.assertEqual(exit_code, 0)
            root_preview = payload["preview"]["llms.txt"]
            ctx_preview = payload["preview"]["llms-ctx.txt"]
            ctx_full_preview = payload["preview"]["llms-ctx-full.txt"]
            alpha_preview = payload["preview"]["packages"]["alpha_dart"]
            beta_preview = payload["preview"]["packages"]["beta_dart"]

            self.assertTrue(root_preview.startswith("# AI Clients Dart\n\n> Workspace summary for llms.txt generation."))
            self.assertIn("## Packages", root_preview)
            self.assertIn("## Optional", root_preview)
            self.assertIn(
                "[alpha_dart](https://github.com/example/ai_clients_dart/blob/main/packages/alpha_dart/llms.txt)",
                root_preview,
            )
            self.assertIn(
                "[Repository README](https://github.com/example/ai_clients_dart/blob/main/README.md)",
                root_preview,
            )
            self.assertNotIn("###", root_preview)
            self.assertNotIn("```", root_preview)
            self.assertNotIn("Platforms:", root_preview)
            self.assertNotIn("Quickstart entry point:", root_preview)

            self.assertIn("Start with the package llms.txt hub that matches your provider or runtime.", root_preview)
            self.assertIn("## Source: packages/alpha_dart/llms.txt", ctx_preview)
            self.assertIn("## Source: packages/beta_dart/llms.txt", ctx_preview)
            self.assertNotIn("Repository overview for optional context.", ctx_preview)
            self.assertIn("Repository overview for optional context.", ctx_full_preview)
            self.assertIn("Canonical URL: https://github.com/example/ai_clients_dart/blob/main/packages/alpha_dart/llms.txt", ctx_preview)
            self.assertIn("### Alpha Dart Client", ctx_preview)
            self.assertIn("#### Docs", ctx_preview)
            self.assertIn("[README](https://github.com/example/ai_clients_dart/blob/main/packages/alpha_dart/README.md)", ctx_preview)
            self.assertNotIn("## Usage", ctx_preview)
            self.assertIn("### Workspace README", ctx_full_preview)
            self.assertIn("#### Usage", ctx_full_preview)
            self.assertIn("```md\n# Literal code heading\n## Another literal code heading\n```", ctx_full_preview)

            self.assertIn("## Examples", alpha_preview)
            self.assertIn(
                "[alpha_example.dart](https://github.com/example/ai_clients_dart/blob/main/packages/alpha_dart/example/alpha_example.dart)",
                alpha_preview,
            )
            self.assertIn("How do I send alpha requests?", alpha_preview)
            self.assertIn(
                "[fallback_demo.dart](https://github.com/example/ai_clients_dart/blob/main/packages/beta_dart/example/fallback_demo.dart)",
                beta_preview,
            )
            self.assertIn("Fallback demo example.", beta_preview)

    def test_generate_llms_txt_repo_mode_skips_missing_root_readme(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_llms_workspace(root)
            self._write_repo_license(root)
            self._write_llms_package(
                root,
                name="delta_dart",
                description="Delta package.",
                readme="# Delta Dart Client\n\nDart client for delta provider flows.\n",
                example_files={"delta_example.dart": "void main() {}\n"},
            )

            exit_code, payload = command_generate_llms_txt(
                SimpleNamespace(config_dir=None, repo_root=root, dry_run=True)
            )

            self.assertEqual(exit_code, 0)
            root_preview = payload["preview"]["llms.txt"]
            ctx_full_preview = payload["preview"]["llms-ctx-full.txt"]

            self.assertNotIn("Repository README", root_preview)
            self.assertNotIn("## Optional", root_preview)
            self.assertNotIn("## Source: README.md", ctx_full_preview)

    def test_generate_llms_txt_repo_mode_writes_outputs_and_removes_legacy_file(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_llms_workspace(root)
            self._write_repo_license(root)
            (root / "README.md").write_text("# Workspace README\n\nRepository overview for optional context.\n")
            self._write_llms_package(
                root,
                name="gamma_dart",
                description="Gamma package.",
                readme="# Gamma Dart Client\n\nDart client for gamma provider flows.\n",
                example_files={"gamma_example.dart": "void main() {}\n"},
            )
            (root / "llms-full.txt").write_text("legacy\n")

            exit_code, payload = command_generate_llms_txt(
                SimpleNamespace(config_dir=None, repo_root=root, dry_run=False)
            )

            self.assertEqual(exit_code, 0)
            self.assertFalse((root / "llms-full.txt").exists())
            self.assertTrue((root / "llms.txt").exists())
            self.assertTrue((root / "llms-ctx.txt").exists())
            self.assertTrue((root / "llms-ctx-full.txt").exists())
            self.assertTrue((root / "packages" / "gamma_dart" / "llms.txt").exists())
            self.assertIn(str((root / "packages" / "gamma_dart" / "llms.txt").resolve()), payload["outputs"])
            generated_root_llms = (root / "llms.txt").read_text()
            generated_ctx_llms = (root / "llms-ctx.txt").read_text()
            generated_package_llms = (root / "packages" / "gamma_dart" / "llms.txt").read_text()
            self.assertIn(
                "[gamma_dart](https://github.com/example/ai_clients_dart/blob/main/packages/gamma_dart/llms.txt)",
                generated_root_llms,
            )
            self.assertIn("## Source: packages/gamma_dart/llms.txt", generated_ctx_llms)
            self.assertIn("### Gamma Dart Client", generated_ctx_llms)
            self.assertIn("## Docs", generated_package_llms)
            self.assertIn("## Examples", generated_package_llms)
            self.assertIn("## Optional", generated_package_llms)

    def test_blob_url_rejects_path_outside_repo(self) -> None:
        from api_toolkit.operations import _blob_url, _tree_url

        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            self._write_llms_workspace(root)
            outside = root.parent / "outside.txt"
            with self.assertRaises(ValueError):
                _blob_url(root, outside)
            with self.assertRaises(ValueError):
                _tree_url(root, outside)

    def test_selected_assets_use_local_sentinel_pattern(self) -> None:
        toolkit_root = Path(__file__).resolve().parents[1]
        model_template = (toolkit_root / "assets" / "model_template.dart").read_text()
        sealed_template = (toolkit_root / "assets" / "sealed_message_template.dart").read_text()

        for content in (model_template, sealed_template):
            self.assertNotIn("copy_with_sentinel.dart", content)
            self.assertIn("const Object _unsetCopyWithValue = _UnsetCopyWithSentinel();", content)
            self.assertIn("class _UnsetCopyWithSentinel {", content)


    # ── Type safety & consistency tests ──────────────────────────────────

    def _setup_type_check_env(
        self,
        root: Path,
        *,
        spec_schemas: dict,
        manifest_types: dict,
        dart_files: dict[str, str],
        type_mappings: dict | None = None,
    ) -> Path:
        """Helper that wires up spec, manifest, and Dart files for type/consistency tests."""
        self._write_workspace(root)
        self._write_repo_license(root)
        package_root, config_dir = self._create_openapi_config(root)
        output_dir = root / "tmp" / "sample"
        output_dir.mkdir(parents=True)
        (package_root / "specs" / "openapi.json").write_text(json.dumps({
            "openapi": "3.1.0",
            "info": {"title": "Sample", "version": "1"},
            "paths": {},
            "components": {"schemas": spec_schemas},
        }))
        self._write_specs_and_manifest(
            config_dir,
            specs_payload={
                "specs": {"main": {"name": "Sample", "local_file": "openapi.json", "fetch_mode": "local_file", "source_file": "specs/openapi.json"}},
                "specs_dir": "packages/sample_dart/specs",
                "output_dir": str(output_dir),
            },
            manifest_payload={
                "surface": "openapi",
                "type_mappings": type_mappings or {"string": "String", "integer": "int", "number": "double", "boolean": "bool", "array": "List", "object": "Map"},
                "placement": {"categories": {}, "default_category": "common", "parent_model_patterns": {}},
                "coverage": {},
                "types": manifest_types,
            },
        )
        for rel_path, content in dart_files.items():
            full_path = package_root / rel_path
            full_path.parent.mkdir(parents=True, exist_ok=True)
            full_path.write_text(content)
        return config_dir

    def _make_dart_class(self, class_name: str, fields: list[tuple[str, str, bool]]) -> str:
        """Generate a minimal valid Dart class string with fromJson/toJson/copyWith."""
        lines = [f"class {class_name} {{"]
        for name, dart_type, nullable in fields:
            suffix = "?" if nullable else ""
            lines.append(f"  final {dart_type}{suffix} {name};")
        lines.append(f"\n  const {class_name}({{")
        for name, _, nullable in fields:
            qualifier = "" if nullable else "required "
            lines.append(f"    {qualifier}this.{name},")
        lines.append("  });")
        lines.append(f"\n  factory {class_name}.fromJson(Map<String, dynamic> json) => {class_name}(")
        for name, dart_type, nullable in fields:
            suffix = "?" if nullable else ""
            lines.append(f"    {name}: json['{name}'] as {dart_type}{suffix},")
        lines.append("  );")
        lines.append("\n  Map<String, dynamic> toJson() => {")
        for name, _, nullable in fields:
            if nullable:
                lines.append(f"    if ({name} != null) '{name}': {name},")
            else:
                lines.append(f"    '{name}': {name},")
        lines.append("  };")
        lines.append(f"\n  {class_name} copyWith({{")
        for name, dart_type, _ in fields:
            lines.append(f"    {dart_type}? {name},")
        lines.append(f"  }}) => {class_name}(")
        for name, _, _ in fields:
            lines.append(f"        {name}: {name} ?? this.{name},")
        lines.append("      );")
        lines.append(f"\n  @override\n  bool operator ==(Object other) => identical(this, other) || (other is {class_name});")
        lines.append(f"\n  @override\n  int get hashCode => 0;")
        lines.append(f"\n  @override\n  String toString() => '{class_name}()';")
        lines.append("}")
        return "\n".join(lines) + "\n"

    def test_verify_type_warns_object_for_ref_property(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {"config": {"$ref": "#/components/schemas/FooConfig"}},
                        "required": ["config"],
                    },
                    "FooConfig": {"type": "object", "properties": {"name": {"type": "string"}}},
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                    "FooConfig": {"spec": "main", "kind": "object", "dart_class": "FooConfig", "file": "lib/src/models/common/foo_config.dart", "schema": "FooConfig"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("config", "Object", False)]),
                    "lib/src/models/common/foo_config.dart": self._make_dart_class("FooConfig", [("name", "String", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            type_warnings = [i for i in issues if i["level"] == "warning" and "Object" in i["message"] and "FooConfig" in i["message"]]
            self.assertTrue(len(type_warnings) >= 1, f"Expected warning about Object vs FooConfig: {issues}")

    def test_verify_type_warns_object_for_oneOf_union(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {
                            "result": {"oneOf": [
                                {"$ref": "#/components/schemas/TypeA"},
                                {"$ref": "#/components/schemas/TypeB"},
                                {"type": "string"},
                            ]},
                        },
                    },
                    "TypeA": {"type": "object", "properties": {}},
                    "TypeB": {"type": "object", "properties": {}},
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                    "TypeA": {"spec": "main", "kind": "object", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA"},
                    "TypeB": {"spec": "main", "kind": "object", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("result", "Object", True)]),
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", []),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", []),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            union_warnings = [i for i in issues if i["level"] == "warning" and "union" in i["message"]]
            self.assertTrue(len(union_warnings) >= 1, f"Expected union warning: {issues}")

    def test_verify_type_warns_object_for_anyOf_union(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {
                            "container": {"anyOf": [
                                {"$ref": "#/components/schemas/ToolA"},
                                {"$ref": "#/components/schemas/ToolB"},
                            ]},
                        },
                    },
                    "ToolA": {"type": "object", "properties": {}},
                    "ToolB": {"type": "object", "properties": {}},
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                    "ToolA": {"spec": "main", "kind": "object", "dart_class": "ToolA", "file": "lib/src/models/common/tool_a.dart", "schema": "ToolA"},
                    "ToolB": {"spec": "main", "kind": "object", "dart_class": "ToolB", "file": "lib/src/models/common/tool_b.dart", "schema": "ToolB"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("container", "Object", True)]),
                    "lib/src/models/common/tool_a.dart": self._make_dart_class("ToolA", []),
                    "lib/src/models/common/tool_b.dart": self._make_dart_class("ToolB", []),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            union_warnings = [i for i in issues if i["level"] == "warning" and "union" in i["message"]]
            self.assertTrue(len(union_warnings) >= 1, f"Expected union warning for anyOf: {issues}")

    def test_verify_type_warns_object_for_pure_type_union(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {
                            "result": {"oneOf": [
                                {"type": "object"},
                                {"type": "object"},
                                {"type": "string"},
                            ]},
                        },
                    },
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("result", "Object", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            union_warnings = [i for i in issues if i["level"] == "warning" and "union" in i["message"]]
            self.assertTrue(len(union_warnings) >= 1, f"Expected union warning for pure-type union: {issues}")

    def test_verify_type_unwraps_allOf_in_anyOf_branch(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {
                            "config": {"anyOf": [
                                {"allOf": [{"$ref": "#/components/schemas/AudioTranscription"}]},
                                {"type": "null"},
                            ]},
                        },
                    },
                    "AudioTranscription": {"type": "object", "properties": {"lang": {"type": "string"}}},
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                    "AudioTranscription": {"spec": "main", "kind": "object", "dart_class": "AudioTranscription", "file": "lib/src/models/common/audio.dart", "schema": "AudioTranscription"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("config", "Object", True)]),
                    "lib/src/models/common/audio.dart": self._make_dart_class("AudioTranscription", [("lang", "String", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            ref_warnings = [i for i in issues if i["level"] == "warning" and "AudioTranscription" in i["message"]]
            self.assertTrue(len(ref_warnings) >= 1, f"Expected warning referencing AudioTranscription: {issues}")

    def test_verify_type_unwraps_nested_oneOf_in_anyOf(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {
                            "effort": {"anyOf": [
                                {"oneOf": [{"$ref": "#/components/schemas/ReasoningEffortEnum"}]},
                                {"type": "null"},
                            ]},
                        },
                    },
                    "ReasoningEffortEnum": {"type": "string", "enum": ["low", "medium", "high"]},
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                    "ReasoningEffortEnum": {"spec": "main", "kind": "enum", "dart_class": "ReasoningEffortEnum", "file": "lib/src/models/common/effort.dart", "schema": "ReasoningEffortEnum"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("effort", "Object", True)]),
                    "lib/src/models/common/effort.dart": "enum ReasoningEffortEnum { low, medium, high, unknown }\n",
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            ref_warnings = [i for i in issues if i["level"] == "warning" and "ReasoningEffortEnum" in i["message"]]
            self.assertTrue(len(ref_warnings) >= 1, f"Expected warning referencing ReasoningEffortEnum: {issues}")

    def test_verify_type_no_warning_when_correct(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {"config": {"$ref": "#/components/schemas/FooConfig"}},
                    },
                    "FooConfig": {"type": "object", "properties": {"name": {"type": "string"}}},
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                    "FooConfig": {"spec": "main", "kind": "object", "dart_class": "FooConfig", "file": "lib/src/models/common/foo_config.dart", "schema": "FooConfig"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("config", "FooConfig", True)]),
                    "lib/src/models/common/foo_config.dart": self._make_dart_class("FooConfig", [("name", "String", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            type_warnings = [i for i in issues if i["level"] == "warning" and "typed as" in i.get("message", "")]
            self.assertEqual(type_warnings, [], f"Unexpected type warnings: {type_warnings}")

    def test_verify_type_alias_aware_lookup(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {"request": {"$ref": "#/components/schemas/CreateMessageParams"}},
                    },
                    "CreateMessageParams": {"type": "object", "properties": {"text": {"type": "string"}}},
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                    "CreateMessageRequest": {"spec": "main", "kind": "object", "dart_class": "MessageCreateRequest", "file": "lib/src/models/common/msg_req.dart", "schema": "CreateMessageParams"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("request", "Object", True)]),
                    "lib/src/models/common/msg_req.dart": self._make_dart_class("MessageCreateRequest", [("text", "String", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            alias_warnings = [i for i in issues if i["level"] == "warning" and "MessageCreateRequest" in i["message"]]
            self.assertTrue(len(alias_warnings) >= 1, f"Expected alias-aware warning about MessageCreateRequest: {issues}")

    def test_verify_type_list_generic_mismatch(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {
                            "items": {"type": "array", "items": {"$ref": "#/components/schemas/Foo"}},
                        },
                    },
                    "Foo": {"type": "object", "properties": {}},
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                    "Foo": {"spec": "main", "kind": "object", "dart_class": "Foo", "file": "lib/src/models/common/foo.dart", "schema": "Foo"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("items", "List<Object>", True)]),
                    "lib/src/models/common/foo.dart": self._make_dart_class("Foo", []),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            generic_infos = [i for i in issues if i["level"] == "info" and "generic parameter mismatch" in i.get("message", "")]
            self.assertTrue(len(generic_infos) >= 1, f"Expected generic mismatch info: {issues}")

    def test_verify_sibling_nullability_inconsistency(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Parent": {"type": "object", "properties": {"type": {"type": "string"}}},
                    "VariantA": {"type": "object", "properties": {"id": {"type": "string"}, "type": {"type": "string"}}},
                    "VariantB": {"type": "object", "properties": {"id": {"type": "string"}, "type": {"type": "string"}}},
                    "VariantC": {"type": "object", "properties": {"id": {"type": "string"}, "type": {"type": "string"}}, "required": ["id"]},
                },
                manifest_types={
                    "Parent": {"spec": "main", "kind": "sealed_parent", "dart_class": "Parent", "file": "lib/src/models/common/parent.dart", "schema": "Parent", "discriminator": {"field": "type"}},
                    "VariantA": {"spec": "main", "kind": "sealed_variant", "dart_class": "VariantA", "file": "lib/src/models/common/variant_a.dart", "schema": "VariantA", "parent": "Parent"},
                    "VariantB": {"spec": "main", "kind": "sealed_variant", "dart_class": "VariantB", "file": "lib/src/models/common/variant_b.dart", "schema": "VariantB", "parent": "Parent"},
                    "VariantC": {"spec": "main", "kind": "sealed_variant", "dart_class": "VariantC", "file": "lib/src/models/common/variant_c.dart", "schema": "VariantC", "parent": "Parent"},
                },
                dart_files={
                    "lib/src/models/common/parent.dart": "sealed class Parent {}\n",
                    "lib/src/models/common/variant_a.dart": self._make_dart_class("VariantA", [("id", "String", True)]),
                    "lib/src/models/common/variant_b.dart": self._make_dart_class("VariantB", [("id", "String", True)]),
                    "lib/src/models/common/variant_c.dart": self._make_dart_class("VariantC", [("id", "String", False)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="consistency", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["consistency"]["issues"]
            null_warnings = [i for i in issues if "inconsistent nullability" in i.get("message", "")]
            self.assertTrue(len(null_warnings) >= 1, f"Expected nullability inconsistency warning: {issues}")

    def test_verify_sibling_type_inconsistency(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Parent": {"type": "object", "properties": {"type": {"type": "string"}}},
                    "VariantA": {"type": "object", "properties": {"content": {"type": "string"}, "type": {"type": "string"}}},
                    "VariantB": {"type": "object", "properties": {"content": {"type": "string"}, "type": {"type": "string"}}},
                },
                manifest_types={
                    "Parent": {"spec": "main", "kind": "sealed_parent", "dart_class": "Parent", "file": "lib/src/models/common/parent.dart", "schema": "Parent", "discriminator": {"field": "type"}},
                    "VariantA": {"spec": "main", "kind": "sealed_variant", "dart_class": "VariantA", "file": "lib/src/models/common/variant_a.dart", "schema": "VariantA", "parent": "Parent"},
                    "VariantB": {"spec": "main", "kind": "sealed_variant", "dart_class": "VariantB", "file": "lib/src/models/common/variant_b.dart", "schema": "VariantB", "parent": "Parent"},
                },
                dart_files={
                    "lib/src/models/common/parent.dart": "sealed class Parent {}\n",
                    "lib/src/models/common/variant_a.dart": self._make_dart_class("VariantA", [("content", "String", True)]),
                    "lib/src/models/common/variant_b.dart": self._make_dart_class("VariantB", [("content", "Object", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="consistency", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["consistency"]["issues"]
            type_warnings = [i for i in issues if "inconsistent types" in i.get("message", "")]
            self.assertTrue(len(type_warnings) >= 1, f"Expected type inconsistency warning: {issues}")

    def test_verify_sibling_consistent_ok(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Parent": {"type": "object", "properties": {"type": {"type": "string"}}},
                    "VariantA": {"type": "object", "properties": {"id": {"type": "string"}, "type": {"type": "string"}}},
                    "VariantB": {"type": "object", "properties": {"id": {"type": "string"}, "type": {"type": "string"}}},
                },
                manifest_types={
                    "Parent": {"spec": "main", "kind": "sealed_parent", "dart_class": "Parent", "file": "lib/src/models/common/parent.dart", "schema": "Parent", "discriminator": {"field": "type"}},
                    "VariantA": {"spec": "main", "kind": "sealed_variant", "dart_class": "VariantA", "file": "lib/src/models/common/variant_a.dart", "schema": "VariantA", "parent": "Parent"},
                    "VariantB": {"spec": "main", "kind": "sealed_variant", "dart_class": "VariantB", "file": "lib/src/models/common/variant_b.dart", "schema": "VariantB", "parent": "Parent"},
                },
                dart_files={
                    "lib/src/models/common/parent.dart": "sealed class Parent {}\n",
                    "lib/src/models/common/variant_a.dart": self._make_dart_class("VariantA", [("id", "String", True)]),
                    "lib/src/models/common/variant_b.dart": self._make_dart_class("VariantB", [("id", "String", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="consistency", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["consistency"]["issues"]
            warnings = [i for i in issues if i["level"] == "warning"]
            self.assertEqual(warnings, [], f"Unexpected sibling warnings: {warnings}")

    def test_verify_sibling_includes_skip_entries(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Parent": {"type": "object", "properties": {"type": {"type": "string"}}},
                    "VariantA": {"type": "object", "properties": {"id": {"type": "string"}, "type": {"type": "string"}}},
                    "VariantB": {"type": "object", "properties": {"id": {"type": "string"}, "type": {"type": "string"}}},
                    "SkipChild": {"type": "object", "properties": {"id": {"type": "string"}, "type": {"type": "string"}}, "required": ["id"]},
                },
                manifest_types={
                    "Parent": {"spec": "main", "kind": "sealed_parent", "dart_class": "Parent", "file": "lib/src/models/common/parent.dart", "schema": "Parent", "discriminator": {"field": "type"}},
                    "VariantA": {"spec": "main", "kind": "sealed_variant", "dart_class": "VariantA", "file": "lib/src/models/common/variant_a.dart", "schema": "VariantA", "parent": "Parent"},
                    "VariantB": {"spec": "main", "kind": "sealed_variant", "dart_class": "VariantB", "file": "lib/src/models/common/variant_b.dart", "schema": "VariantB", "parent": "Parent"},
                    "SkipChild": {"spec": "main", "kind": "skip", "dart_class": "SkipChild", "file": "lib/src/models/common/skip_child.dart", "schema": "SkipChild", "parent": "Parent", "note": "test skip"},
                },
                dart_files={
                    "lib/src/models/common/parent.dart": "sealed class Parent {}\n",
                    "lib/src/models/common/variant_a.dart": self._make_dart_class("VariantA", [("id", "String", True)]),
                    "lib/src/models/common/variant_b.dart": self._make_dart_class("VariantB", [("id", "String", True)]),
                    "lib/src/models/common/skip_child.dart": self._make_dart_class("SkipChild", [("id", "String", False)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="consistency", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["consistency"]["issues"]
            null_warnings = [i for i in issues if "inconsistent nullability" in i.get("message", "")]
            self.assertTrue(len(null_warnings) >= 1, f"Expected nullability warning including skip child: {issues}")

    def test_verify_sibling_aliased_parent(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Tool": {"type": "object", "properties": {"type": {"type": "string"}}},
                    "ToolA": {"type": "object", "properties": {"id": {"type": "string"}, "type": {"type": "string"}}},
                    "ToolB": {"type": "object", "properties": {"id": {"type": "string"}, "type": {"type": "string"}}, "required": ["id"]},
                },
                manifest_types={
                    "interactions:Tool": {"spec": "main", "kind": "sealed_parent", "dart_class": "InteractionTool", "file": "lib/src/models/common/tool.dart", "schema": "Tool", "discriminator": {"field": "type"}},
                    "ToolA": {"spec": "main", "kind": "sealed_variant", "dart_class": "ToolA", "file": "lib/src/models/common/tool_a.dart", "schema": "ToolA", "parent": "InteractionTool"},
                    "ToolB": {"spec": "main", "kind": "sealed_variant", "dart_class": "ToolB", "file": "lib/src/models/common/tool_b.dart", "schema": "ToolB", "parent": "InteractionTool"},
                },
                dart_files={
                    "lib/src/models/common/tool.dart": "sealed class InteractionTool {}\n",
                    "lib/src/models/common/tool_a.dart": self._make_dart_class("ToolA", [("id", "String", True)]),
                    "lib/src/models/common/tool_b.dart": self._make_dart_class("ToolB", [("id", "String", False)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="consistency", scope="type", type_name="interactions:Tool", baseline=None, git_ref=None)
            )
            issues = payload["results"]["consistency"]["issues"]
            null_warnings = [i for i in issues if "inconsistent nullability" in i.get("message", "")]
            self.assertTrue(len(null_warnings) >= 1, f"Expected warning despite aliased parent: {issues}")

    def test_verify_all_includes_consistency(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {"id": {"type": "string"}},
                        "required": ["id"],
                    },
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("id", "String", False)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="all", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            self.assertIn("consistency", payload["results"])
            self.assertIn("implementation", payload["results"])

    def test_verify_consistency_surfaces_in_warning_checks(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Parent": {"type": "object", "properties": {"type": {"type": "string"}}},
                    "VariantA": {"type": "object", "properties": {"id": {"type": "string"}, "type": {"type": "string"}}},
                    "VariantB": {"type": "object", "properties": {"id": {"type": "string"}, "type": {"type": "string"}}, "required": ["id"]},
                },
                manifest_types={
                    "Parent": {"spec": "main", "kind": "sealed_parent", "dart_class": "Parent", "file": "lib/src/models/common/parent.dart", "schema": "Parent", "discriminator": {"field": "type"}},
                    "VariantA": {"spec": "main", "kind": "sealed_variant", "dart_class": "VariantA", "file": "lib/src/models/common/variant_a.dart", "schema": "VariantA", "parent": "Parent"},
                    "VariantB": {"spec": "main", "kind": "sealed_variant", "dart_class": "VariantB", "file": "lib/src/models/common/variant_b.dart", "schema": "VariantB", "parent": "Parent"},
                },
                dart_files={
                    "lib/src/models/common/parent.dart": "sealed class Parent {}\n",
                    "lib/src/models/common/variant_a.dart": self._make_dart_class("VariantA", [("id", "String", True)]),
                    "lib/src/models/common/variant_b.dart": self._make_dart_class("VariantB", [("id", "String", False)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="all", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            self.assertIn("consistency", payload["summary"]["warning_checks"])

    def test_verify_consistency_payload_includes_observability_fields(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Parent": {"type": "object", "properties": {"type": {"type": "string"}}},
                    "VariantA": {"type": "object", "properties": {"id": {"type": "string"}, "type": {"type": "string"}}},
                    "VariantB": {"type": "object", "properties": {"id": {"type": "string"}, "type": {"type": "string"}}},
                },
                manifest_types={
                    "Parent": {"spec": "main", "kind": "sealed_parent", "dart_class": "Parent", "file": "lib/src/models/common/parent.dart", "schema": "Parent", "discriminator": {"field": "type"}},
                    "VariantA": {"spec": "main", "kind": "sealed_variant", "dart_class": "VariantA", "file": "lib/src/models/common/variant_a.dart", "schema": "VariantA", "parent": "Parent"},
                    "VariantB": {"spec": "main", "kind": "sealed_variant", "dart_class": "VariantB", "file": "lib/src/models/common/variant_b.dart", "schema": "VariantB", "parent": "Parent"},
                },
                dart_files={
                    "lib/src/models/common/parent.dart": "sealed class Parent {}\n",
                    "lib/src/models/common/variant_a.dart": self._make_dart_class("VariantA", [("id", "String", True)]),
                    "lib/src/models/common/variant_b.dart": self._make_dart_class("VariantB", [("id", "String", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="consistency", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            consistency = payload["results"]["consistency"]
            self.assertIn("scope", consistency)
            self.assertIn("selected_types", consistency)
            self.assertIn("checked_parent_groups", consistency)
            self.assertIn("sibling_group_count", consistency)

    def test_verify_sibling_skip_parent_wrapper(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Content": {"type": "object", "properties": {"type": {"type": "string"}}},
                    "TextContent": {"type": "object", "properties": {"id": {"type": "string"}, "type": {"type": "string"}}},
                    "ImageContent": {"type": "object", "properties": {"id": {"type": "string"}, "type": {"type": "string"}}, "required": ["id"]},
                },
                manifest_types={
                    "interactions:Content": {"spec": "main", "kind": "skip", "dart_class": "InteractionContent", "file": "lib/src/models/common/content.dart", "schema": "Content", "note": "wrapper only"},
                    "TextContent": {"spec": "main", "kind": "sealed_variant", "dart_class": "TextContent", "file": "lib/src/models/common/text.dart", "schema": "TextContent", "parent": "InteractionContent"},
                    "ImageContent": {"spec": "main", "kind": "sealed_variant", "dart_class": "ImageContent", "file": "lib/src/models/common/image.dart", "schema": "ImageContent", "parent": "InteractionContent"},
                },
                dart_files={
                    "lib/src/models/common/content.dart": "sealed class InteractionContent {}\n",
                    "lib/src/models/common/text.dart": self._make_dart_class("TextContent", [("id", "String", True)]),
                    "lib/src/models/common/image.dart": self._make_dart_class("ImageContent", [("id", "String", False)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="consistency", scope="type", type_name="interactions:Content", baseline=None, git_ref=None)
            )
            issues = payload["results"]["consistency"]["issues"]
            null_warnings = [i for i in issues if "inconsistent nullability" in i.get("message", "")]
            self.assertTrue(len(null_warnings) >= 1, f"Expected nullability warning from skip parent wrapper: {issues}")


    def test_verify_skip_entries_get_type_checks(self) -> None:
        """P1: skip entries with schema+file still get type warnings."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Interaction": {
                        "type": "object",
                        "properties": {"input": {"$ref": "#/components/schemas/InteractionInput"}},
                    },
                    "InteractionInput": {"type": "object", "properties": {"text": {"type": "string"}}},
                },
                manifest_types={
                    "Interaction": {"spec": "main", "kind": "skip", "dart_class": "Interaction", "file": "lib/src/models/common/interaction.dart", "schema": "Interaction", "note": "complex type"},
                    "InteractionInput": {"spec": "main", "kind": "object", "dart_class": "InteractionInput", "file": "lib/src/models/common/input.dart", "schema": "InteractionInput"},
                },
                dart_files={
                    "lib/src/models/common/interaction.dart": self._make_dart_class("Interaction", [("input", "Object", True)]),
                    "lib/src/models/common/input.dart": self._make_dart_class("InteractionInput", [("text", "String", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            type_warnings = [i for i in issues if i["level"] == "warning" and "InteractionInput" in i.get("message", "")]
            self.assertTrue(len(type_warnings) >= 1, f"Expected type warning on skip entry: {issues}")

    def test_verify_type_no_false_positive_on_list_of_primitives(self) -> None:
        """P2: List<String> should not warn when spec says array of string."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {
                            "tools": {"type": "array", "items": {"type": "string"}},
                        },
                        "required": ["tools"],
                    },
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("tools", "List<String>", False)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            type_issues = [i for i in issues if "typed as" in i.get("message", "") or "mismatch" in i.get("message", "")]
            self.assertEqual(type_issues, [], f"Unexpected false positive on List<String>: {type_issues}")

    def test_verify_type_respects_custom_array_container_mapping(self) -> None:
        """Custom array type_mapping (e.g. BuiltList) should not cause false positive."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {
                            "tags": {"type": "array", "items": {"type": "string"}},
                            "items": {"type": "array", "items": {"$ref": "#/components/schemas/Foo"}},
                        },
                        "required": ["tags", "items"],
                    },
                    "Foo": {"type": "object", "properties": {}},
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                    "Foo": {"spec": "main", "kind": "object", "dart_class": "Foo", "file": "lib/src/models/common/foo.dart", "schema": "Foo"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("tags", "BuiltList<String>", False), ("items", "BuiltList<Foo>", False)]),
                    "lib/src/models/common/foo.dart": self._make_dart_class("Foo", []),
                },
                type_mappings={"string": "String", "integer": "int", "number": "double", "boolean": "bool", "array": "BuiltList", "object": "Map"},
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            type_issues = [i for i in issues if "typed as" in i.get("message", "") or "mismatch" in i.get("message", "")]
            self.assertEqual(type_issues, [], f"Unexpected false positive with custom BuiltList mapping: {type_issues}")

    def test_verify_type_nested_array_resolves_inner_type(self) -> None:
        """array<array<string>> should resolve to the correct nested generic, not bare container."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {
                            "matrix": {
                                "type": "array",
                                "items": {"type": "array", "items": {"type": "string"}},
                            },
                        },
                        "required": ["matrix"],
                    },
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("matrix", "BuiltList<BuiltList<String>>", False)]),
                },
                type_mappings={"string": "String", "integer": "int", "number": "double", "boolean": "bool", "array": "BuiltList", "object": "Map"},
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            type_issues = [i for i in issues if "typed as" in i.get("message", "") or "mismatch" in i.get("message", "")]
            self.assertEqual(type_issues, [], f"Unexpected false positive for nested BuiltList<BuiltList<String>>: {type_issues}")

    def test_verify_type_no_false_positive_on_inline_object(self) -> None:
        """P3: inline object (type: object without $ref) should not warn about Map."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {
                            "text": {"type": "object", "properties": {"value": {"type": "string"}}},
                        },
                    },
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("text", "TextContent", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            type_issues = [i for i in issues if "typed as" in i.get("message", "") or "mismatch" in i.get("message", "")]
            self.assertEqual(type_issues, [], f"Unexpected false positive on inline object: {type_issues}")

    def test_verify_sibling_excluded_properties_suppresses_warning(self) -> None:
        """P4: parent excluded_properties should suppress sibling divergence warnings."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "MessageItem": {"type": "object", "properties": {"type": {"type": "string"}}},
                    "UserMsg": {"type": "object", "properties": {"content": {"type": "string"}, "type": {"type": "string"}}},
                    "AssistantMsg": {"type": "object", "properties": {"content": {"type": "string"}, "type": {"type": "string"}}},
                },
                manifest_types={
                    "MessageItem": {"spec": "main", "kind": "sealed_parent", "dart_class": "MessageItem", "file": "lib/src/models/common/msg_item.dart", "schema": "MessageItem", "discriminator": {"field": "type"}, "excluded_properties": ["content"]},
                    "UserMsg": {"spec": "main", "kind": "sealed_variant", "dart_class": "UserMsg", "file": "lib/src/models/common/user_msg.dart", "schema": "UserMsg", "parent": "MessageItem"},
                    "AssistantMsg": {"spec": "main", "kind": "sealed_variant", "dart_class": "AssistantMsg", "file": "lib/src/models/common/assistant_msg.dart", "schema": "AssistantMsg", "parent": "MessageItem"},
                },
                dart_files={
                    "lib/src/models/common/msg_item.dart": "sealed class MessageItem {}\n",
                    "lib/src/models/common/user_msg.dart": self._make_dart_class("UserMsg", [("content", "String", False)]),
                    "lib/src/models/common/assistant_msg.dart": self._make_dart_class("AssistantMsg", [("content", "OutputContent", False)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="consistency", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["consistency"]["issues"]
            content_warnings = [i for i in issues if "content" in i.get("message", "") and i["level"] == "warning"]
            self.assertEqual(content_warnings, [], f"Expected content divergence to be suppressed: {content_warnings}")

    def test_verify_skip_type_checks_only_on_scope_all(self) -> None:
        """Skip-entry type checks should not run for scoped verification (type/critical)."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Selected": {
                        "type": "object",
                        "properties": {"id": {"type": "string"}},
                        "required": ["id"],
                    },
                    "Skipped": {
                        "type": "object",
                        "properties": {"data": {"$ref": "#/components/schemas/SomeRef"}},
                    },
                    "SomeRef": {"type": "object", "properties": {}},
                },
                manifest_types={
                    "Selected": {"spec": "main", "kind": "object", "dart_class": "Selected", "file": "lib/src/models/common/selected.dart", "schema": "Selected", "tags": ["critical"]},
                    "Skipped": {"spec": "main", "kind": "skip", "dart_class": "Skipped", "file": "lib/src/models/common/skipped.dart", "schema": "Skipped", "note": "test"},
                    "SomeRef": {"spec": "main", "kind": "object", "dart_class": "SomeRef", "file": "lib/src/models/common/some_ref.dart", "schema": "SomeRef"},
                },
                dart_files={
                    "lib/src/models/common/selected.dart": self._make_dart_class("Selected", [("id", "String", False)]),
                    "lib/src/models/common/skipped.dart": self._make_dart_class("Skipped", [("data", "Object", True)]),
                    "lib/src/models/common/some_ref.dart": self._make_dart_class("SomeRef", []),
                },
            )
            # scope=critical should NOT include the skip entry's type warnings
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="critical", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            skip_warnings = [i for i in issues if i.get("name") == "Skipped"]
            self.assertEqual(skip_warnings, [], f"Skip entry should not appear in critical scope: {skip_warnings}")

            # scope=all SHOULD include the skip entry's type warnings
            _, payload_all = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues_all = payload_all["results"]["implementation"]["issues"]
            skip_warnings_all = [i for i in issues_all if i.get("name") == "Skipped" and "SomeRef" in i.get("message", "")]
            self.assertTrue(len(skip_warnings_all) >= 1, f"Skip entry type warnings expected in scope=all: {issues_all}")

    def test_verify_type_union_when_allOf_mixed_with_ref(self) -> None:
        """anyOf: [{$ref: AltConfig}, {allOf: [...]}] is a union — Object should warn regardless of branch order."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "ExampleA": {
                        "type": "object",
                        "properties": {
                            "cfg": {"anyOf": [
                                {"$ref": "#/components/schemas/AltConfig"},
                                {"allOf": [{"$ref": "#/components/schemas/BaseConfig"}, {"properties": {"x": {"type": "string"}}}]},
                            ]},
                        },
                    },
                    "ExampleB": {
                        "type": "object",
                        "properties": {
                            "cfg": {"anyOf": [
                                {"allOf": [{"$ref": "#/components/schemas/BaseConfig"}, {"properties": {"x": {"type": "string"}}}]},
                                {"$ref": "#/components/schemas/AltConfig"},
                            ]},
                        },
                    },
                    "AltConfig": {"type": "object", "properties": {}},
                    "BaseConfig": {"type": "object", "properties": {}},
                },
                manifest_types={
                    "ExampleA": {"spec": "main", "kind": "object", "dart_class": "ExampleA", "file": "lib/src/models/common/example_a.dart", "schema": "ExampleA"},
                    "ExampleB": {"spec": "main", "kind": "object", "dart_class": "ExampleB", "file": "lib/src/models/common/example_b.dart", "schema": "ExampleB"},
                    "AltConfig": {"spec": "main", "kind": "object", "dart_class": "AltConfig", "file": "lib/src/models/common/alt.dart", "schema": "AltConfig"},
                    "BaseConfig": {"spec": "main", "kind": "object", "dart_class": "BaseConfig", "file": "lib/src/models/common/base.dart", "schema": "BaseConfig"},
                },
                dart_files={
                    "lib/src/models/common/example_a.dart": self._make_dart_class("ExampleA", [("cfg", "Object", True)]),
                    "lib/src/models/common/example_b.dart": self._make_dart_class("ExampleB", [("cfg", "Object", True)]),
                    "lib/src/models/common/alt.dart": self._make_dart_class("AltConfig", []),
                    "lib/src/models/common/base.dart": self._make_dart_class("BaseConfig", []),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            # Both orderings must trigger a union warning, never a single-type suggestion
            a_warnings = [i for i in issues if i.get("name") == "ExampleA" and i["level"] == "warning" and "union" in i.get("message", "")]
            b_warnings = [i for i in issues if i.get("name") == "ExampleB" and i["level"] == "warning" and "union" in i.get("message", "")]
            a_wrong = [i for i in issues if i.get("name") == "ExampleA" and "AltConfig" in i.get("message", "")]
            b_wrong = [i for i in issues if i.get("name") == "ExampleB" and "AltConfig" in i.get("message", "")]
            self.assertTrue(len(a_warnings) >= 1, f"ExampleA (ref first): expected union warning, got: {issues}")
            self.assertTrue(len(b_warnings) >= 1, f"ExampleB (allOf first): expected union warning, got: {issues}")
            self.assertEqual(a_wrong, [], f"ExampleA must not suggest a single type: {a_wrong}")
            self.assertEqual(b_wrong, [], f"ExampleB must not suggest a single type: {b_wrong}")

    def test_verify_type_no_warning_for_multi_item_allOf_branch(self) -> None:
        """P2a: anyOf with a multi-item allOf branch is indeterminate — no spurious type warning."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {
                            "config": {"anyOf": [
                                {"allOf": [
                                    {"$ref": "#/components/schemas/BaseConfig"},
                                    {"properties": {"extra": {"type": "string"}}},
                                ]},
                                {"type": "null"},
                            ]},
                        },
                    },
                    "BaseConfig": {"type": "object", "properties": {"name": {"type": "string"}}},
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                    "BaseConfig": {"spec": "main", "kind": "object", "dart_class": "BaseConfig", "file": "lib/src/models/common/base_config.dart", "schema": "BaseConfig"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("config", "ExtendedConfig", True)]),
                    "lib/src/models/common/base_config.dart": self._make_dart_class("BaseConfig", [("name", "String", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            # Multi-item allOf branch is indeterminate — no type warning on a concrete Dart class
            type_issues = [i for i in issues if "typed as" in i.get("message", "") and "config" in i.get("message", "").lower()]
            self.assertEqual(type_issues, [], f"No type warning expected for multi-item allOf branch: {type_issues}")

    def test_verify_type_warns_for_nested_union_in_anyOf(self) -> None:
        """P2b: anyOf: [{oneOf: [A, B]}, null] should be counted as a 2-branch union."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {
                            "result": {"anyOf": [
                                {"oneOf": [
                                    {"$ref": "#/components/schemas/TypeA"},
                                    {"$ref": "#/components/schemas/TypeB"},
                                ]},
                                {"type": "null"},
                            ]},
                        },
                    },
                    "TypeA": {"type": "object", "properties": {}},
                    "TypeB": {"type": "object", "properties": {}},
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                    "TypeA": {"spec": "main", "kind": "object", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA"},
                    "TypeB": {"spec": "main", "kind": "object", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("result", "Object", True)]),
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", []),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", []),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            union_warnings = [i for i in issues if i["level"] == "warning" and "union" in i.get("message", "")]
            self.assertTrue(len(union_warnings) >= 1, f"Expected union warning for nested anyOf/oneOf: {issues}")

    def test_verify_sibling_excluded_properties_skip_wrapper_parent(self) -> None:
        """excluded_properties on skip-wrapper parents (aliased key) should suppress sibling warnings."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Content": {"type": "object", "properties": {"type": {"type": "string"}}},
                    "TextContent": {"type": "object", "properties": {"result": {"type": "string"}, "type": {"type": "string"}}},
                    "ImageContent": {"type": "object", "properties": {"result": {"type": "string"}, "type": {"type": "string"}}},
                },
                manifest_types={
                    "interactions:Content": {"spec": "main", "kind": "skip", "dart_class": "InteractionContent", "file": "lib/src/models/common/content.dart", "schema": "Content", "note": "wrapper", "excluded_properties": ["result"]},
                    "TextContent": {"spec": "main", "kind": "sealed_variant", "dart_class": "TextContent", "file": "lib/src/models/common/text.dart", "schema": "TextContent", "parent": "InteractionContent"},
                    "ImageContent": {"spec": "main", "kind": "sealed_variant", "dart_class": "ImageContent", "file": "lib/src/models/common/image.dart", "schema": "ImageContent", "parent": "InteractionContent"},
                },
                dart_files={
                    "lib/src/models/common/content.dart": "sealed class InteractionContent {}\n",
                    "lib/src/models/common/text.dart": self._make_dart_class("TextContent", [("result", "String", True)]),
                    "lib/src/models/common/image.dart": self._make_dart_class("ImageContent", [("result", "Object", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="consistency", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["consistency"]["issues"]
            result_warnings = [i for i in issues if "result" in i.get("message", "") and i["level"] == "warning"]
            self.assertEqual(result_warnings, [], f"Expected 'result' divergence to be suppressed via skip-wrapper parent: {result_warnings}")


    def test_verify_type_array_item_anyOf_wrapper_resolves_ref(self) -> None:
        """items: {anyOf: [{$ref: Foo}, null]} should resolve to List<Foo>, not be indeterminate."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "FooItem": {"type": "object", "properties": {"name": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "items": {
                                "type": "array",
                                "items": {"anyOf": [{"$ref": "#/components/schemas/FooItem"}, {"type": "null"}]},
                            },
                        },
                    },
                },
                manifest_types={
                    "FooItem": {"spec": "main", "kind": "object", "dart_class": "FooItem", "file": "lib/src/models/common/foo_item.dart", "schema": "FooItem"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/foo_item.dart": self._make_dart_class("FooItem", [("name", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("items", "Object", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            warnings = [i for i in issues if i["level"] == "warning" and "items" in i.get("message", "")]
            self.assertTrue(len(warnings) >= 1, f"Expected warning for Object field when spec has array<anyOf FooItem>: {issues}")
            self.assertTrue(any("FooItem" in i["message"] or "List" in i["message"] for i in warnings),
                            f"Expected warning to reference FooItem or List: {warnings}")

    def test_verify_type_array_item_anyOf_no_false_positive_when_correct(self) -> None:
        """items: {anyOf: [{$ref: Foo}, null]} with Dart List<Foo>? should not warn."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "FooItem": {"type": "object", "properties": {"name": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "items": {
                                "type": "array",
                                "items": {"anyOf": [{"$ref": "#/components/schemas/FooItem"}, {"type": "null"}]},
                            },
                        },
                    },
                },
                manifest_types={
                    "FooItem": {"spec": "main", "kind": "object", "dart_class": "FooItem", "file": "lib/src/models/common/foo_item.dart", "schema": "FooItem"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/foo_item.dart": self._make_dart_class("FooItem", [("name", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("items", "List<FooItem>", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            type_issues = [i for i in issues if "typed as" in i.get("message", "") or "mismatch" in i.get("message", "")]
            self.assertEqual(type_issues, [], f"Unexpected false positive for List<FooItem> with anyOf-wrapped items: {type_issues}")


    def test_verify_type_array_union_items_warns_object(self) -> None:
        """array with multi-ref union items + Dart Object? should warn."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "items": {
                                "type": "array",
                                "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                            },
                        },
                    },
                },
                manifest_types={
                    "TypeA": {"spec": "main", "kind": "object", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA"},
                    "TypeB": {"spec": "main", "kind": "object", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("items", "Object", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            warnings = [i for i in issues if i["level"] == "warning" and "items" in i.get("message", "")]
            self.assertTrue(len(warnings) >= 1, f"Expected warning for Object field when spec has array of union items: {issues}")
            self.assertTrue(any("union" in i["message"] or "List" in i["message"] for i in warnings),
                            f"Expected warning to mention union or List: {warnings}")

    def test_verify_type_array_union_items_warns_list_of_object(self) -> None:
        """array with multi-ref union items + Dart List<Object>? should warn about item type."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "items": {
                                "type": "array",
                                "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                            },
                        },
                    },
                },
                manifest_types={
                    "TypeA": {"spec": "main", "kind": "object", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA"},
                    "TypeB": {"spec": "main", "kind": "object", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("items", "List<Object>", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            warnings = [i for i in issues if i["level"] == "warning" and "items" in i.get("message", "")]
            self.assertTrue(len(warnings) >= 1, f"Expected warning for List<Object> when spec has array of union items: {issues}")
            self.assertTrue(any("item" in i["message"] and "union" in i["message"] for i in warnings),
                            f"Expected warning to mention item type and union: {warnings}")

    def test_verify_type_array_union_items_mismatch_for_wrong_container(self) -> None:
        """array with union items + Dart String (completely wrong type) should emit info mismatch."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "items": {
                                "type": "array",
                                "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                            },
                        },
                    },
                },
                manifest_types={
                    "TypeA": {"spec": "main", "kind": "object", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA"},
                    "TypeB": {"spec": "main", "kind": "object", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("items", "String", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            info_issues = [i for i in issues if i["level"] == "info" and "items" in i.get("message", "")]
            self.assertTrue(len(info_issues) >= 1, f"Expected info mismatch for String field on array-of-union-items spec: {issues}")
            self.assertTrue(any("List" in i["message"] or "union" in i["message"] for i in info_issues),
                            f"Expected mismatch to mention List or union: {info_issues}")

    def test_verify_type_array_union_items_info_for_primitive_item_type(self) -> None:
        """array with union items + Dart List<String>? should emit info (primitive item type)."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "items": {
                                "type": "array",
                                "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                            },
                        },
                    },
                },
                manifest_types={
                    "TypeA": {"spec": "main", "kind": "object", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA"},
                    "TypeB": {"spec": "main", "kind": "object", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("items", "List<String>", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            info_issues = [i for i in issues if i["level"] == "info" and "items" in i.get("message", "")]
            self.assertTrue(len(info_issues) >= 1, f"Expected info issue for List<String> on union-item array: {issues}")

    def test_verify_type_array_union_items_info_for_known_variant_item_type(self) -> None:
        """array with union items + Dart List<TypeA>? should emit info (TypeA is a known manifest type, not the union parent)."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "items": {
                                "type": "array",
                                "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                            },
                        },
                    },
                },
                manifest_types={
                    "TypeA": {"spec": "main", "kind": "object", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA"},
                    "TypeB": {"spec": "main", "kind": "object", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("items", "List<TypeA>", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            info_issues = [i for i in issues if i["level"] == "info" and "items" in i.get("message", "")]
            self.assertTrue(len(info_issues) >= 1, f"Expected info issue for List<TypeA> (known variant) on union-item array: {issues}")

    def test_verify_type_array_union_items_no_warning_for_manifest_sealed_parent(self) -> None:
        """List<ItemUnion> where ItemUnion is a manifest sealed_parent should not warn (not a concrete mismatch)."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "ItemUnion": {"type": "object", "properties": {"type": {"type": "string"}}},
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}, "type": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}, "type": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "items": {
                                "type": "array",
                                "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                            },
                        },
                    },
                },
                manifest_types={
                    "ItemUnion": {"spec": "main", "kind": "sealed_parent", "dart_class": "ItemUnion", "file": "lib/src/models/common/item_union.dart", "schema": "ItemUnion"},
                    "TypeA": {"spec": "main", "kind": "sealed_variant", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA", "parent": "ItemUnion"},
                    "TypeB": {"spec": "main", "kind": "sealed_variant", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB", "parent": "ItemUnion"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/item_union.dart": "sealed class ItemUnion {}\n",
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("items", "List<ItemUnion>", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            type_issues = [i for i in issues if "items" in i.get("message", "") and i["level"] in ("warning", "info") and "union" in i.get("message", "")]
            self.assertEqual(type_issues, [], f"False positive: List<ItemUnion> with sealed_parent in manifest should not warn: {type_issues}")

    def test_verify_type_array_union_items_no_warning_for_skip_wrapper_parent(self) -> None:
        """List<ItemUnion> where ItemUnion is a skip-wrapper parent (children reference it via parent field) should not warn."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}, "type": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}, "type": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "items": {
                                "type": "array",
                                "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                            },
                        },
                    },
                },
                manifest_types={
                    "interactions:ItemUnion": {"spec": "main", "kind": "skip", "dart_class": "ItemUnion", "file": "lib/src/models/common/item_union.dart", "schema": None, "note": "wrapper"},
                    "TypeA": {"spec": "main", "kind": "sealed_variant", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA", "parent": "ItemUnion"},
                    "TypeB": {"spec": "main", "kind": "sealed_variant", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB", "parent": "ItemUnion"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/item_union.dart": "sealed class ItemUnion {}\n",
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("items", "List<ItemUnion>", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            type_issues = [i for i in issues if "items" in i.get("message", "") and i["level"] in ("warning", "info") and "union" in i.get("message", "")]
            self.assertEqual(type_issues, [], f"False positive: List<ItemUnion> with skip-wrapper parent should not warn: {type_issues}")

    def test_verify_type_array_union_items_no_warning_for_key_addressed_wrapper_parent(self) -> None:
        """List<ItemUnion> where children reference the wrapper by manifest key (parent: 'interactions:ItemUnion') should not warn."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}, "type": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}, "type": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "items": {
                                "type": "array",
                                "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                            },
                        },
                    },
                },
                manifest_types={
                    "interactions:ItemUnion": {"spec": "main", "kind": "skip", "dart_class": "ItemUnion", "file": "lib/src/models/common/item_union.dart", "schema": None, "note": "wrapper"},
                    "TypeA": {"spec": "main", "kind": "sealed_variant", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA", "parent": "interactions:ItemUnion"},
                    "TypeB": {"spec": "main", "kind": "sealed_variant", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB", "parent": "interactions:ItemUnion"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/item_union.dart": "sealed class ItemUnion {}\n",
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("items", "List<ItemUnion>", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            type_issues = [i for i in issues if "items" in i.get("message", "") and i["level"] in ("warning", "info") and "union" in i.get("message", "")]
            self.assertEqual(type_issues, [], f"False positive: List<ItemUnion> with key-addressed skip-wrapper parent should not warn: {type_issues}")

    def test_verify_skip_entry_array_union_items_no_warning_for_key_addressed_wrapper_parent(self) -> None:
        """skip entry with List<ItemUnion> where children use parent: 'interactions:ItemUnion' (key ref) should not warn via _verify_field_types."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}, "type": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}, "type": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "items": {
                                "type": "array",
                                "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                            },
                        },
                    },
                },
                manifest_types={
                    "interactions:ItemUnion": {"spec": "main", "kind": "skip", "dart_class": "ItemUnion", "file": "lib/src/models/common/item_union.dart", "schema": None, "note": "wrapper"},
                    "TypeA": {"spec": "main", "kind": "sealed_variant", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA", "parent": "interactions:ItemUnion"},
                    "TypeB": {"spec": "main", "kind": "sealed_variant", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB", "parent": "interactions:ItemUnion"},
                    # Example is kind: skip so it goes through _verify_field_types
                    "Example": {"spec": "main", "kind": "skip", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example", "note": "tested via skip path"},
                },
                dart_files={
                    "lib/src/models/common/item_union.dart": "sealed class ItemUnion {}\n",
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("items", "List<ItemUnion>", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            type_issues = [i for i in issues if "items" in i.get("message", "") and i["level"] in ("warning", "info") and "union" in i.get("message", "")]
            self.assertEqual(type_issues, [], f"False positive: skip entry List<ItemUnion> with key-addressed wrapper parent should not warn: {type_issues}")

    def test_verify_type_array_composed_allof_items_indeterminate(self) -> None:
        """items: {allOf: [{$ref: BaseConfig}, {properties: ...}]} is composition — indeterminate, no mismatch warning for wrapper types."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "BaseConfig": {"type": "object", "properties": {"id": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "items": {
                                "type": "array",
                                "items": {
                                    "allOf": [
                                        {"$ref": "#/components/schemas/BaseConfig"},
                                        {"type": "object", "properties": {"extra": {"type": "string"}}},
                                    ],
                                },
                            },
                        },
                    },
                },
                manifest_types={
                    "BaseConfig": {"spec": "main", "kind": "object", "dart_class": "BaseConfig", "file": "lib/src/models/common/base_config.dart", "schema": "BaseConfig"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/base_config.dart": self._make_dart_class("BaseConfig", [("id", "String", True)]),
                    # ItemWrapper is a valid subtype — should not be flagged as wrong
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("items", "List<ItemWrapper>", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            type_issues = [i for i in issues if "typed as" in i.get("message", "") or "mismatch" in i.get("message", "") or "item type" in i.get("message", "")]
            self.assertEqual(type_issues, [], f"False positive: List<ItemWrapper> on composed allOf items should be indeterminate: {type_issues}")

    def test_verify_type_nested_union_items_warns_object(self) -> None:
        """List<List<Object>> on spec array<array<anyOf[TypeA, TypeB]>> should warn."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "matrix": {
                                "type": "array",
                                "items": {
                                    "type": "array",
                                    "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                                },
                            },
                        },
                    },
                },
                manifest_types={
                    "TypeA": {"spec": "main", "kind": "object", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA"},
                    "TypeB": {"spec": "main", "kind": "object", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("matrix", "List<List<Object>>", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            warnings = [i for i in issues if i["level"] == "warning" and "matrix" in i.get("message", "")]
            self.assertTrue(len(warnings) >= 1, f"Expected warning for List<List<Object>> on nested union-item array: {issues}")

    def test_verify_type_nested_union_items_info_for_known_variant(self) -> None:
        """List<List<TypeA>> on spec array<array<anyOf[TypeA, TypeB]>> should emit info."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "matrix": {
                                "type": "array",
                                "items": {
                                    "type": "array",
                                    "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                                },
                            },
                        },
                    },
                },
                manifest_types={
                    "TypeA": {"spec": "main", "kind": "object", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA"},
                    "TypeB": {"spec": "main", "kind": "object", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("matrix", "List<List<TypeA>>", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            info_issues = [i for i in issues if i["level"] == "info" and "matrix" in i.get("message", "")]
            self.assertTrue(len(info_issues) >= 1, f"Expected info for List<List<TypeA>> on nested union-item array: {issues}")

    def test_verify_type_extension_parent_not_excluded_from_known_concrete(self) -> None:
        """extension entry with parent: ToolChoice must not cause ToolChoice to be excluded from known_concrete."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "ToolChoice": {"type": "object", "properties": {"type": {"type": "string"}}},
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "items": {
                                "type": "array",
                                "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                            },
                        },
                    },
                },
                manifest_types={
                    "ToolChoice": {"spec": "main", "kind": "object", "dart_class": "ToolChoice", "file": "lib/src/models/common/tool_choice.dart", "schema": "ToolChoice"},
                    # extension that references ToolChoice as parent — must not suppress ToolChoice from known_concrete
                    "ToolChoiceValues": {"spec": "main", "kind": "extension", "dart_class": "ToolChoiceValues", "file": "lib/src/models/common/tool_choice_values.dart", "schema": None, "parent": "ToolChoice"},
                    "TypeA": {"spec": "main", "kind": "object", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA"},
                    "TypeB": {"spec": "main", "kind": "object", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/tool_choice.dart": self._make_dart_class("ToolChoice", [("type", "String", True)]),
                    "lib/src/models/common/tool_choice_values.dart": "extension ToolChoiceValues on ToolChoice {}\n",
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    # List<ToolChoice> is wrong here (specific class for a union-item array) — should be flagged
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("items", "List<ToolChoice>", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            info_issues = [i for i in issues if i["level"] == "info" and "items" in i.get("message", "") and "union" in i.get("message", "")]
            self.assertTrue(len(info_issues) >= 1, f"Expected info for List<ToolChoice> (extension parent should not suppress ToolChoice): {issues}")

    def test_verify_type_nested_union_items_info_for_wrong_inner_container(self) -> None:
        """List<Set<TypeA>> on spec array<array<anyOf[TypeA,TypeB]>> should emit info (inner container diverges)."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "matrix": {
                                "type": "array",
                                "items": {
                                    "type": "array",
                                    "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                                },
                            },
                        },
                    },
                },
                manifest_types={
                    "TypeA": {"spec": "main", "kind": "object", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA"},
                    "TypeB": {"spec": "main", "kind": "object", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("matrix", "List<Set<TypeA>>", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            info_issues = [i for i in issues if i["level"] == "info" and "matrix" in i.get("message", "")]
            self.assertTrue(len(info_issues) >= 1, f"Expected info for List<Set<TypeA>> (wrong inner container): {issues}")

    def test_verify_type_nested_union_items_no_false_positive_for_correct_sealed_type(self) -> None:
        """List<List<ItemUnion>> where ItemUnion is sealed_parent should not warn at any nesting level."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "ItemUnion": {"type": "object", "properties": {"type": {"type": "string"}}},
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}, "type": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}, "type": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "matrix": {
                                "type": "array",
                                "items": {
                                    "type": "array",
                                    "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                                },
                            },
                        },
                    },
                },
                manifest_types={
                    "ItemUnion": {"spec": "main", "kind": "sealed_parent", "dart_class": "ItemUnion", "file": "lib/src/models/common/item_union.dart", "schema": "ItemUnion"},
                    "TypeA": {"spec": "main", "kind": "sealed_variant", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA", "parent": "ItemUnion"},
                    "TypeB": {"spec": "main", "kind": "sealed_variant", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB", "parent": "ItemUnion"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/item_union.dart": "sealed class ItemUnion {}\n",
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("matrix", "List<List<ItemUnion>>", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            type_issues = [i for i in issues if "matrix" in i.get("message", "") and i["level"] in ("warning", "info")
                           and not any(m in i.get("message", "") for m in ("operator ==", "hashCode", "toString"))]
            self.assertEqual(type_issues, [], f"False positive: List<List<ItemUnion>> should not warn for nested sealed type: {type_issues}")

    def test_verify_type_array_union_items_no_warning_for_sealed_type(self) -> None:
        """array with multi-ref union items + Dart List<ItemUnion>? should not warn."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "items": {
                                "type": "array",
                                "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                            },
                        },
                    },
                },
                manifest_types={
                    "TypeA": {"spec": "main", "kind": "object", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA"},
                    "TypeB": {"spec": "main", "kind": "object", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("items", "List<ItemUnion>", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            type_issues = [i for i in issues if "typed as" in i.get("message", "") or "mismatch" in i.get("message", "") or ("item" in i.get("message", "") and "union" in i.get("message", ""))]
            self.assertEqual(type_issues, [], f"Unexpected false positive for List<ItemUnion> with union items: {type_issues}")


    def test_verify_type_array_union_items_info_for_bare_container(self) -> None:
        """array with union items + Dart List (no generic arg) should emit info."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "items": {
                                "type": "array",
                                "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                            },
                        },
                    },
                },
                manifest_types={
                    "TypeA": {"spec": "main", "kind": "object", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA"},
                    "TypeB": {"spec": "main", "kind": "object", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("items", "List", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            info_issues = [i for i in issues if i["level"] == "info" and "raw" in i.get("message", "")]
            self.assertTrue(len(info_issues) >= 1, f"Expected info for bare List (no generic) on union-item array: {issues}")
            # Suggestion must reflect the full shape (List<SomeSealedType>), not just the container name
            self.assertIn("List<SomeSealedType>", info_issues[0]["message"])

    def test_verify_type_array_union_items_info_for_bare_nested_container(self) -> None:
        """array<array<union>> with bare List field should suggest the full nested shape."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "TypeA": {"type": "object", "properties": {"a": {"type": "string"}}},
                    "TypeB": {"type": "object", "properties": {"b": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "matrix": {
                                "type": "array",
                                "items": {
                                    "type": "array",
                                    "items": {"anyOf": [{"$ref": "#/components/schemas/TypeA"}, {"$ref": "#/components/schemas/TypeB"}]},
                                },
                            },
                        },
                    },
                },
                manifest_types={
                    "TypeA": {"spec": "main", "kind": "object", "dart_class": "TypeA", "file": "lib/src/models/common/type_a.dart", "schema": "TypeA"},
                    "TypeB": {"spec": "main", "kind": "object", "dart_class": "TypeB", "file": "lib/src/models/common/type_b.dart", "schema": "TypeB"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/type_a.dart": self._make_dart_class("TypeA", [("a", "String", True)]),
                    "lib/src/models/common/type_b.dart": self._make_dart_class("TypeB", [("b", "String", True)]),
                    # bare List — no generic argument at all
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("matrix", "List", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            info_issues = [i for i in issues if i["level"] == "info" and "raw" in i.get("message", "")]
            self.assertTrue(len(info_issues) >= 1, f"Expected info for bare List on nested union array: {issues}")
            # Must suggest the full nested shape, not just the outer container
            self.assertIn("List<List<SomeSealedType>>", info_issues[0]["message"],
                          f"Expected full nested suggestion in: {info_issues[0]['message']}")

    def test_verify_type_openapi31_list_type_nullable_scalar(self) -> None:
        """OpenAPI 3.1 type: ['integer', 'null'] resolves to the mapped Dart type (int)."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {
                            "count": {"type": ["integer", "null"]},
                        },
                    },
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("count", "int", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            # Filter to type-mismatch issues only (exclude method-coverage warnings)
            type_issues = [i for i in issues if i.get("name") == "Example"
                           and i["level"] in ("warning", "error")
                           and "typed as" in i.get("message", "")]
            self.assertEqual(type_issues, [], f"Expected no type warnings for int? field with type=['integer','null']: {type_issues}")

    def test_verify_type_openapi31_list_type_null_makes_field_nullable(self) -> None:
        """OpenAPI 3.1 type: ['integer', 'null'] must not emit 'required but nullable' error even when the field is in required."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "required": ["count"],
                        "properties": {
                            "count": {"type": ["integer", "null"]},
                        },
                    },
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("count", "int", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            # Must not produce "required in spec but nullable in Dart" error
            required_errors = [i for i in issues if i.get("name") == "Example"
                               and i["level"] == "error"
                               and "required" in i.get("message", "").lower()]
            self.assertEqual(required_errors, [], f"Expected no required/nullable error for type=['integer','null']: {required_errors}")

    def test_verify_type_openapi31_list_type_union_warns_object(self) -> None:
        """OpenAPI 3.1 type: ['string', 'integer'] (2+ non-null) is treated as a union; Object? should warn."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {
                            "value": {"type": ["string", "integer"]},
                        },
                    },
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("value", "Object", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            warnings = [i for i in issues if i.get("name") == "Example" and i["level"] == "warning"]
            self.assertTrue(any("union" in i["message"].lower() or "sealed" in i["message"].lower() for i in warnings),
                            f"Expected union/sealed warning for Object? with type=['string','integer']: {warnings}")

    def test_verify_type_websocket_string_items_no_crash(self) -> None:
        """OpenAPI schema with array items as a bare string (e.g. 'string') must not crash.

        This covers the same normalization path as WebSocket schemas, which also
        express array item types as bare strings rather than schema objects.
        """
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "properties": {
                            "tags": {"type": "array", "items": "string"},
                        },
                    },
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("tags", "List<String>", True)]),
                },
            )
            # Must not raise; result should contain no type-mismatch issues for Example
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            errors = [i for i in issues if i.get("name") == "Example" and i["level"] == "error"]
            self.assertEqual(errors, [], f"Expected no errors for List<String> with items='string': {errors}")

    def test_verify_field_types_null_file_no_crash(self) -> None:
        """_verify_field_types on a skip entry with schema but file=null must not crash."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Orphan": {
                        "type": "object",
                        "properties": {"id": {"type": "string"}},
                    },
                },
                manifest_types={
                    "Orphan": {"spec": "main", "kind": "skip", "dart_class": None, "file": None, "schema": "Orphan"},
                },
                dart_files={},
            )
            # Must not raise; skip entry with null file returns no issues
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            errors = [i for i in issues if i.get("name") == "Orphan" and i["level"] == "error"]
            self.assertEqual(errors, [], f"Expected no errors for skip entry with null file: {errors}")

    def test_verify_type_websocket_schema_ref_items_resolves(self) -> None:
        """Websocket bare-string array items that are schema references (e.g. 'Tool') resolve via $ref path."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Tool": {"type": "object", "properties": {"name": {"type": "string"}}},
                    "Example": {
                        "type": "object",
                        "properties": {
                            "tools": {"type": "array", "items": "Tool"},
                        },
                    },
                },
                manifest_types={
                    "Tool": {"spec": "main", "kind": "object", "dart_class": "Tool", "file": "lib/src/models/common/tool.dart", "schema": "Tool"},
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/tool.dart": self._make_dart_class("Tool", [("name", "String", True)]),
                    # Object? — should produce a type warning since spec expects List<Tool>
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("tools", "Object", True)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            # Should warn that tools is Object but spec expects List<Tool>
            type_issues = [i for i in issues if i.get("name") == "Example" and i["level"] in ("warning", "info")
                           and "tools" in i.get("message", "")]
            self.assertTrue(len(type_issues) >= 1,
                            f"Expected type issue for Object? when spec ref items='Tool': {issues}")

    def test_verify_type_openapi31_nullable_required_no_spurious_optional_info(self) -> None:
        """type: ['integer', 'null'] in required must not produce 'optional but non-nullable' info for a non-nullable Dart field."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "required": ["count"],
                        "properties": {
                            "count": {"type": ["integer", "null"]},
                        },
                    },
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("count", "int", False)]),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            # Must not produce "optional in spec but non-nullable in Dart" info
            optional_infos = [i for i in issues if i.get("name") == "Example"
                              and i["level"] == "info"
                              and "optional" in i.get("message", "").lower()]
            self.assertEqual(optional_infos, [], f"Expected no spurious optional-info for nullable required field: {optional_infos}")

    def test_scaffold_from_json_array_null_list_type(self) -> None:
        """_scaffold_from_json_expression must handle type: ['array', 'null'] without crashing."""
        from api_toolkit.operations import _scaffold_from_json_expression
        type_mappings = {"string": "String", "integer": "int", "array": "List"}
        prop = {
            "type": ["array", "null"],
            "items": {"type": "string"},
            "required": False,
        }
        result = _scaffold_from_json_expression("tags", prop, type_mappings)
        # Must not crash and should delegate to array scaffold
        self.assertIn("List", result)

    def test_scaffold_to_json_array_null_list_type(self) -> None:
        """_scaffold_to_json_expression must handle type: ['array', 'null'] without crashing."""
        from api_toolkit.operations import _scaffold_to_json_expression
        type_mappings = {"string": "String", "integer": "int", "array": "List"}
        prop = {
            "type": ["array", "null"],
            "items": {"type": "string"},
            "required": False,
        }
        result = _scaffold_to_json_expression("tags", prop, type_mappings)
        # Must not crash and should return the field name (simple array of primitives)
        self.assertIsInstance(result, str)
        self.assertNotEqual(result, "TODO()")

    def test_dart_type_from_prop_bare_string_items_no_crash(self) -> None:
        """_dart_type_from_prop must not crash when items is a bare string (WebSocket schema style)."""
        from api_toolkit.operations import _dart_type_from_prop
        type_mappings = {"string": "String", "integer": "int", "array": "List"}
        # Primitive bare-string items (e.g. items: "string")
        result = _dart_type_from_prop(type_mappings, {"type": "array", "items": "string"})
        self.assertIn("String", result)
        # Schema-ref bare-string items (e.g. items: "Tool")
        result2 = _dart_type_from_prop(type_mappings, {"type": "array", "items": "Tool"})
        self.assertIn("Tool", result2)

    def test_scaffold_array_from_json_bare_string_items_no_crash(self) -> None:
        """_scaffold_array_from_json must not crash when items is a bare string (WebSocket schema style)."""
        from api_toolkit.operations import _scaffold_array_from_json
        type_mappings = {"string": "String", "integer": "int", "array": "List"}
        # Primitive bare-string items
        result = _scaffold_array_from_json("tags", {"type": "array", "items": "string", "required": True}, type_mappings)
        self.assertIsInstance(result, str)
        self.assertNotEqual(result, "TODO()")
        # Schema-ref bare-string items
        result2 = _scaffold_array_from_json("tools", {"type": "array", "items": "Tool", "required": True}, type_mappings)
        self.assertIn("Tool", result2)

    def test_dart_type_from_prop_list_type_no_crash(self) -> None:
        """_dart_type_from_prop must not crash when prop['type'] is an OpenAPI 3.1 list."""
        from api_toolkit.operations import _dart_type_from_prop
        type_mappings = {"string": "String", "integer": "int", "array": "List"}
        # Nullable scalar: ['integer', 'null'] -> single non-null type -> int
        result = _dart_type_from_prop(type_mappings, {"type": ["integer", "null"]})
        self.assertEqual(result, "int")
        # Multi-type union: ['string', 'integer'] -> no unique type -> fallback
        result2 = _dart_type_from_prop(type_mappings, {"type": ["string", "integer"]})
        # Must not crash; exact fallback value is dynamic or None-mapped
        self.assertIsInstance(result2, str)

    def test_scaffold_to_json_bare_string_items_no_crash(self) -> None:
        """_scaffold_to_json_expression must not crash when items is a bare string (WebSocket schema style)."""
        from api_toolkit.operations import _scaffold_to_json_expression
        type_mappings = {"string": "String", "integer": "int", "array": "List"}
        # Primitive bare-string items
        result = _scaffold_to_json_expression("tags", {"type": "array", "items": "string", "required": True}, type_mappings)
        self.assertIsInstance(result, str)
        self.assertNotEqual(result, "TODO()")
        # Schema-ref bare-string items
        result2 = _scaffold_to_json_expression("tools", {"type": "array", "items": "Tool", "required": True}, type_mappings)
        self.assertIsInstance(result2, str)

    def test_resolve_openapi31_type_non_string_returns_none(self) -> None:
        """_resolve_openapi31_type must return None for non-string non-list input (e.g. None itself)."""
        from api_toolkit.operations import _resolve_openapi31_type
        self.assertIsNone(_resolve_openapi31_type(None))
        self.assertEqual(_resolve_openapi31_type("string"), "string")
        self.assertEqual(_resolve_openapi31_type(["integer", "null"]), "integer")
        self.assertIsNone(_resolve_openapi31_type(["string", "integer"]))  # multi-type → None

    def test_verify_anyof_null_sets_nullable_not_required_false(self) -> None:
        """anyOf: [SomeType, null] must not produce 'optional but non-nullable' info for required fields."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            config_dir = self._setup_type_check_env(root,
                spec_schemas={
                    "Example": {
                        "type": "object",
                        "required": ["value"],
                        "properties": {
                            "value": {"anyOf": [{"$ref": "#/components/schemas/Foo"}, {"type": "null"}]},
                        },
                    },
                    "Foo": {"type": "object"},
                },
                manifest_types={
                    "Example": {"spec": "main", "kind": "object", "dart_class": "Example", "file": "lib/src/models/common/example.dart", "schema": "Example"},
                    "Foo": {"spec": "main", "kind": "object", "dart_class": "Foo", "file": "lib/src/models/common/foo.dart", "schema": "Foo"},
                },
                dart_files={
                    "lib/src/models/common/example.dart": self._make_dart_class("Example", [("value", "Foo", False)]),
                    "lib/src/models/common/foo.dart": self._make_dart_class("Foo", []),
                },
            )
            _, payload = command_verify(
                SimpleNamespace(config_dir=config_dir, spec_name=None, checks="implementation", scope="all", type_name=None, baseline=None, git_ref=None)
            )
            issues = payload["results"]["implementation"]["issues"]
            # Must not produce "optional in spec but non-nullable in Dart" info
            optional_infos = [i for i in issues if i.get("name") == "Example"
                              and i["level"] == "info"
                              and "optional" in i.get("message", "").lower()]
            self.assertEqual(optional_infos, [], f"anyOf nullable required field should not produce optional info: {optional_infos}")


    def test_scaffold_nonnull_required_but_nullable(self) -> None:
        """_is_scaffold_nonnull returns False for required+nullable; scaffold generates nullable Dart types."""
        from api_toolkit.operations import (
            _is_scaffold_nonnull, _scaffold_from_json_expression, _scaffold_class_source,
        )
        type_mappings = {"string": "String", "integer": "int", "array": "List"}

        # required=True, nullable=False → non-nullable
        self.assertTrue(_is_scaffold_nonnull({"required": True, "nullable": False}))
        # required=True, nullable=True → nullable (required-but-nullable field)
        self.assertFalse(_is_scaffold_nonnull({"required": True, "nullable": True}))
        # required=False → nullable regardless
        self.assertFalse(_is_scaffold_nonnull({"required": False}))
        self.assertFalse(_is_scaffold_nonnull({}))

        # fromJson for a required-but-nullable scalar should add "?" suffix
        prop = {"type": "string", "required": True, "nullable": True}
        expr = _scaffold_from_json_expression("value", prop, type_mappings)
        self.assertIn("?", expr, f"Expected nullable cast in: {expr}")

        # fromJson for a required non-nullable scalar should NOT have "?" suffix
        prop_nonnull = {"type": "string", "required": True, "nullable": False}
        expr_nonnull = _scaffold_from_json_expression("value", prop_nonnull, type_mappings)
        self.assertNotIn("?", expr_nonnull, f"Expected non-nullable cast in: {expr_nonnull}")

        # _scaffold_class_source field declaration
        props = {
            "value": {"type": "string", "required": True, "nullable": True},
            "count": {"type": "integer", "required": True, "nullable": False},
        }
        source = _scaffold_class_source("Example", props, type_mappings)
        self.assertIn("String? value", source, f"required+nullable field should be String?: {source}")
        self.assertIn("int count", source, f"required+non-nullable field should be int: {source}")
        # copyWith for required+nullable should use "as String?" not "! as String"
        self.assertIn("as String?", source, f"copyWith for nullable field should use 'as String?': {source}")

    def test_dart_type_from_prop_items_list_type_no_crash(self) -> None:
        """_dart_type_from_prop must not crash when items['type'] is an OpenAPI 3.1 list."""
        from api_toolkit.operations import _dart_type_from_prop
        type_mappings = {"string": "String", "integer": "int", "array": "List"}
        # items.type is a list (e.g. ["string", "null"]) — must not crash with TypeError
        result = _dart_type_from_prop(type_mappings, {"type": "array", "items": {"type": ["string", "null"]}})
        self.assertIn("String", result)
        # Multi-type items → no unique type → fallback to dynamic
        result2 = _dart_type_from_prop(type_mappings, {"type": "array", "items": {"type": ["string", "integer"]}})
        self.assertIn("dynamic", result2)

    def test_scaffold_array_from_json_items_list_type_no_crash(self) -> None:
        """_scaffold_array_from_json must not crash when items['type'] is an OpenAPI 3.1 list."""
        from api_toolkit.operations import _scaffold_array_from_json
        type_mappings = {"string": "String", "integer": "int", "array": "List"}
        # items.type = ["string", "null"] — must not crash
        prop = {"type": "array", "items": {"type": ["string", "null"]}, "required": True}
        result = _scaffold_array_from_json("tags", prop, type_mappings)
        self.assertIsInstance(result, str)
        self.assertIn("String", result)

    def test_scaffold_to_json_nullable_ref_uses_null_aware_operator(self) -> None:
        """_scaffold_to_json_expression must use ?. for nullable ref and array-of-ref fields."""
        from api_toolkit.operations import _scaffold_to_json_expression, _scaffold_class_source
        type_mappings = {"string": "String", "integer": "int", "array": "List"}

        # Non-nullable ref → plain .toJson()
        prop_nonnull = {"ref": "Foo", "required": True, "nullable": False}
        self.assertEqual(_scaffold_to_json_expression("item", prop_nonnull, type_mappings), "item.toJson()")

        # Required+nullable ref → null-aware ?.toJson()
        prop_nullable = {"ref": "Foo", "required": True, "nullable": True}
        result = _scaffold_to_json_expression("item", prop_nullable, type_mappings)
        self.assertIn("?.", result, f"Expected null-aware operator for required+nullable ref: {result}")

        # Non-nullable array of refs → plain .map(...)
        prop_arr_nonnull = {"type": "array", "items": {"$ref": "#/components/schemas/Foo"}, "required": True, "nullable": False}
        result_arr = _scaffold_to_json_expression("items", prop_arr_nonnull, type_mappings)
        self.assertIn("items.map", result_arr, f"Expected non-null map for non-nullable array: {result_arr}")
        self.assertNotIn("?.", result_arr)

        # Required+nullable array of refs → null-aware ?.map(...)
        prop_arr_nullable = {"type": "array", "items": {"$ref": "#/components/schemas/Foo"}, "required": True, "nullable": True}
        result_arr_null = _scaffold_to_json_expression("items", prop_arr_nullable, type_mappings)
        self.assertIn("?.", result_arr_null, f"Expected null-aware map for nullable array of refs: {result_arr_null}")

        # Verify the full class source emits null-safe toJson for required+nullable ref
        props = {"item": {"ref": "Foo", "required": True, "nullable": True}}
        source = _scaffold_class_source("Example", props, type_mappings)
        self.assertIn("?.toJson()", source, f"class toJson should use ?.toJson() for required+nullable ref: {source}")


    def test_verify_open_object_errors_missing_overflow_field(self) -> None:
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
                            "additionalProperties": True,
                            "properties": {
                                "id": {"type": "string"},
                            },
                            "required": ["id"],
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
            self.assertTrue(
                any("no overflow field" in issue["message"] for issue in issues),
                f"Expected overflow field error, got: {issues}",
            )

    def test_verify_open_object_no_error_with_extra_field(self) -> None:
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
                            "additionalProperties": True,
                            "properties": {
                                "id": {"type": "string"},
                            },
                            "required": ["id"],
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
                "  final String id;\n"
                "  final Map<String, dynamic>? extra;\n\n"
                "  const Example({required this.id, this.extra});\n"
                "  factory Example.fromJson(Map<String, dynamic> json) => Example(id: json['id'] as String, extra: json);\n"
                "  Map<String, dynamic> toJson() => {'id': id};\n"
                "  Example copyWith({String? id, Map<String, dynamic>? extra}) => Example(id: id ?? this.id, extra: extra ?? this.extra);\n"
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

            self.assertEqual(exit_code, 0)
            issues = payload["results"]["implementation"]["issues"]
            overflow_issues = [i for i in issues if "no overflow field" in i.get("message", "")]
            self.assertEqual(overflow_issues, [], f"Expected no overflow errors, got: {overflow_issues}")

    def test_verify_closed_object_no_overflow_error(self) -> None:
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
                            "additionalProperties": False,
                            "properties": {
                                "id": {"type": "string"},
                            },
                            "required": ["id"],
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

            self.assertEqual(exit_code, 0)
            issues = payload["results"]["implementation"]["issues"]
            overflow_issues = [i for i in issues if "no overflow field" in i.get("message", "")]
            self.assertEqual(overflow_issues, [], f"Expected no overflow errors, got: {overflow_issues}")

    def test_scaffold_open_object_includes_extra_field(self) -> None:
        """_scaffold_class_source with is_open=True generates an extra field with full support."""
        from api_toolkit.operations import _scaffold_class_source
        type_mappings = {"string": "String", "integer": "int"}
        props = {
            "id": {"type": "string", "required": True},
            "name": {"type": "string", "required": False},
        }

        # is_open=True must include extra field and supporting code
        source_open = _scaffold_class_source("Example", props, type_mappings, is_open=True)
        self.assertIn("Map<String, dynamic>? extra", source_open,
                       f"Expected extra field declaration in open source: {source_open}")
        self.assertIn("this.extra", source_open,
                       f"Expected this.extra in constructor: {source_open}")
        self.assertIn("_knownKeys", source_open,
                       f"Expected _knownKeys in fromJson: {source_open}")
        self.assertIn("...extra!", source_open,
                       f"Expected ...extra! spread in toJson: {source_open}")
        self.assertIn("Object? extra = _unsetCopyWithValue", source_open,
                       f"Expected extra in copyWith parameters: {source_open}")
        self.assertIn("extra: extra == _unsetCopyWithValue", source_open,
                       f"Expected extra in copyWith body: {source_open}")
        self.assertIn("extra: $extra", source_open,
                       f"Expected extra in toString: {source_open}")

        # is_open=False (default) must NOT include any extra field
        source_closed = _scaffold_class_source("Example", props, type_mappings)
        self.assertNotIn("Map<String, dynamic>? extra", source_closed,
                         f"Closed source should not have extra field: {source_closed}")
        self.assertNotIn("_knownKeys", source_closed,
                         f"Closed source should not have _knownKeys: {source_closed}")
        self.assertNotIn("...extra!", source_closed,
                         f"Closed source should not have ...extra!: {source_closed}")


if __name__ == "__main__":
    unittest.main()
