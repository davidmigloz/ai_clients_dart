from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
TOOLKIT_ROOT = ROOT / ".agents" / "shared" / "api-toolkit"

if str(TOOLKIT_ROOT) not in sys.path:
    sys.path.insert(0, str(TOOLKIT_ROOT))

from api_toolkit.config import load_toolkit_config
from api_toolkit.operations import command_describe, command_verify


CONFIG_DIRS = [
    ROOT / "packages" / "anthropic_sdk_dart" / ".agents" / "skills" / "openapi-anthropic" / "config",
    ROOT / "packages" / "chromadb" / ".agents" / "skills" / "openapi-chromadb" / "config",
    ROOT / "packages" / "googleai_dart" / ".agents" / "skills" / "openapi-googleai" / "config",
    ROOT / "packages" / "googleai_dart" / ".agents" / "skills" / "websocket-googleai" / "config",
    ROOT / "packages" / "mistralai_dart" / ".agents" / "skills" / "openapi-mistral" / "config",
    ROOT / "packages" / "ollama_dart" / ".agents" / "skills" / "openapi-ollama" / "config",
    ROOT / "packages" / "open_responses" / ".agents" / "skills" / "openapi-open-responses" / "config",
    ROOT / "packages" / "openai_dart" / ".agents" / "skills" / "openapi-openai" / "config",
]

BANNED_REFERENCES = [
    ".claude",
    ".agents/shared/openapi-toolkit",
    ".agents/shared/websocket-toolkit",
    "verify_model_properties.py",
    "verify_schema_deep.py",
    "generate_model.py",
    "generate_enum.py",
    "generate_message.py",
    "generate_config.py",
]

DEAD_SPEC_KEYS = {
    "discovery_patterns",
    "discovery_names",
    "message_types",
}


class MigratedSkillContractTests(unittest.TestCase):
    def test_migrated_configs_use_four_file_contract(self) -> None:
        expected = {"documentation.json", "manifest.json", "package.json", "specs.json"}
        for config_dir in CONFIG_DIRS:
            self.assertTrue(config_dir.exists(), msg=f"Missing config dir: {config_dir}")
            files = {path.name for path in config_dir.iterdir() if path.is_file()}
            self.assertEqual(files, expected, msg=f"Unexpected config files in {config_dir}")

    def test_all_real_configs_load_under_new_toolkit(self) -> None:
        for config_dir in CONFIG_DIRS:
            config = load_toolkit_config(config_dir)
            self.assertIn(config.manifest.surface, {"openapi", "websocket"})
            self.assertEqual(config.config_dir, config_dir.resolve())
            self.assertGreaterEqual(len(config.specs), 1)

    def test_all_manifest_paths_are_package_root_relative(self) -> None:
        for config_dir in CONFIG_DIRS:
            manifest = load_toolkit_config(config_dir).manifest
            for entry in manifest.types.values():
                self.assertFalse(
                    entry.file.startswith("packages/"),
                    msg=f"{config_dir}: manifest path must be package-root-relative for {entry.key}",
                )

    def test_no_real_specs_json_contains_dead_legacy_keys(self) -> None:
        for config_dir in CONFIG_DIRS:
            raw = (config_dir / "specs.json").read_text()
            for key in DEAD_SPEC_KEYS:
                self.assertNotIn(f'"{key}"', raw, msg=f"{config_dir}: unexpected legacy key {key}")
            if config_dir.name == "config" and "websocket-googleai" in str(config_dir):
                specs = load_toolkit_config(config_dir)
                self.assertTrue(specs.specs["live"].websocket_endpoints)
                self.assertIn("experimental", command_describe(type("Args", (), {"config_dir": config_dir, "spec_name": "live", "type_name": None})())[1]["selected_spec"])

    def test_openapi_googleai_contains_main_and_interactions_entries(self) -> None:
        config_dir = ROOT / "packages" / "googleai_dart" / ".agents" / "skills" / "openapi-googleai" / "config"
        config = load_toolkit_config(config_dir)
        specs = {entry.spec for entry in config.manifest.types.values()}
        self.assertIn("main", specs)
        self.assertIn("interactions", specs)
        self.assertIn("interactions:Tool", config.manifest.types)

    def test_describe_filters_real_interactions_entries(self) -> None:
        config_dir = ROOT / "packages" / "googleai_dart" / ".agents" / "skills" / "openapi-googleai" / "config"
        _, payload = command_describe(type("Args", (), {"config_dir": config_dir, "spec_name": "interactions", "type_name": None})())
        self.assertTrue(payload["types"])
        self.assertTrue(all(item["spec"] == "interactions" for item in payload["types"].values()))

    def test_real_preflight_config_loads_for_supported_packages(self) -> None:
        for package in ("openai_dart", "anthropic_sdk_dart"):
            config_dir = ROOT / "packages" / package / ".agents" / "skills" / (
                "openapi-openai" if package == "openai_dart" else "openapi-anthropic"
            ) / "config"
            config = load_toolkit_config(config_dir)
            self.assertIn("stats_url", config.preflight)
            self.assertIn("stats_field", config.preflight)

    def test_websocket_schema_lives_under_package_specs(self) -> None:
        package_specs_dir = ROOT / "packages" / "googleai_dart" / "specs"
        self.assertTrue((package_specs_dir / "live-api-schema.source.json").exists())
        self.assertTrue((package_specs_dir / "live-api-schema.json").exists())
        self.assertFalse(
            (ROOT / "packages" / "googleai_dart" / ".agents" / "skills" / "websocket-googleai" / "config" / "schema.json").exists()
        )

    def test_active_docs_and_skill_files_have_no_legacy_references(self) -> None:
        scan_roots = [
            ROOT / ".agents" / "shared" / "api-toolkit",
            ROOT / "docs" / "new_dart_api_client.md",
            *(ROOT / "packages").glob("*/.agents/skills"),
        ]
        offenders: list[str] = []
        for root in scan_roots:
            candidates = [root] if root.is_file() else [path for path in root.rglob("*") if path.is_file()]
            for path in candidates:
                if path.is_relative_to(TOOLKIT_ROOT / "tests"):
                    continue
                if path.suffix not in {".md", ".json", ".yaml", ".yml", ".py"}:
                    continue
                text = path.read_text()
                for banned in BANNED_REFERENCES:
                    if banned in text:
                        offenders.append(f"{path.relative_to(ROOT)} -> {banned}")
        self.assertEqual(offenders, [])

    def test_full_verify_passes_for_all_real_skills(self) -> None:
        for config_dir in CONFIG_DIRS:
            exit_code, payload = command_verify(
                type(
                    "Args",
                    (),
                    {
                        "config_dir": config_dir,
                        "spec_name": None,
                        "checks": "all",
                        "scope": "all",
                        "type_name": None,
                        "baseline": None,
                        "git_ref": None,
                    },
                )()
            )
            self.assertEqual(exit_code, 0, msg=f"{config_dir}: {payload['summary']}")

    def test_openapi_googleai_full_verify_passes_for_each_spec(self) -> None:
        config_dir = ROOT / "packages" / "googleai_dart" / ".agents" / "skills" / "openapi-googleai" / "config"
        for spec_name in ("main", "interactions"):
            exit_code, payload = command_verify(
                type(
                    "Args",
                    (),
                    {
                        "config_dir": config_dir,
                        "spec_name": spec_name,
                        "checks": "all",
                        "scope": "all",
                        "type_name": None,
                        "baseline": None,
                        "git_ref": None,
                    },
                )()
            )
            self.assertEqual(exit_code, 0, msg=f"{spec_name}: {payload['summary']}")


if __name__ == "__main__":
    unittest.main()
