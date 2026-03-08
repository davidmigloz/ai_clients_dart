from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
TOOLKIT_ROOT = ROOT / ".agents" / "shared" / "api-toolkit"

if str(TOOLKIT_ROOT) not in sys.path:
    sys.path.insert(0, str(TOOLKIT_ROOT))

from api_toolkit.config import load_toolkit_config


OPENAPI_CONFIG_DIRS = [
    ROOT / "packages" / "anthropic_sdk_dart" / ".agents" / "skills" / "openapi-anthropic" / "config",
    ROOT / "packages" / "chromadb" / ".agents" / "skills" / "openapi-chromadb" / "config",
    ROOT / "packages" / "googleai_dart" / ".agents" / "skills" / "openapi-googleai" / "config",
    ROOT / "packages" / "mistralai_dart" / ".agents" / "skills" / "openapi-mistral" / "config",
    ROOT / "packages" / "ollama_dart" / ".agents" / "skills" / "openapi-ollama" / "config",
    ROOT / "packages" / "open_responses" / ".agents" / "skills" / "openapi-open-responses" / "config",
    ROOT / "packages" / "openai_dart" / ".agents" / "skills" / "openapi-openai" / "config",
]


EXPECTED_AUDIT_REFERENCE_CONFIG = {
    "anthropic_sdk_dart/openapi-anthropic:main": {
        "repo": "anthropics/anthropic-sdk-python",
        "resources_adapter": "python_stainless_resources",
        "resources_path": "src/anthropic/resources",
        "types_adapter": "python_init_exports",
        "types_path": "src/anthropic/types/__init__.py",
    },
    "chromadb/openapi-chromadb:main": {
        "repo": "chroma-core/chroma",
        "resources_adapter": "python_client_methods",
        "resources_path": "chromadb/api/client.py",
        "types_adapter": "python_recursive_classes",
        "types_path": "chromadb/api/models",
    },
    "googleai_dart/openapi-googleai:interactions": {
        "repo": "googleapis/python-genai",
        "resources_adapter": "python_client_members",
        "resources_path": "google/genai/client.py",
        "types_adapter": "python_init_exports",
        "types_path": "google/genai/_interactions/types/__init__.py",
    },
    "googleai_dart/openapi-googleai:main": {
        "repo": "googleapis/python-genai",
        "resources_adapter": "python_client_members",
        "resources_path": "google/genai/client.py",
        "types_adapter": "python_single_file_classes",
        "types_path": "google/genai/types.py",
    },
    "mistralai_dart/openapi-mistral:main": {
        "repo": "mistralai/client-python",
        "resources_adapter": "python_client_members",
        "resources_path": "src/mistralai/client/sdk.py",
        "types_adapter": "python_recursive_classes",
        "types_path": "src/mistralai/client/models",
    },
    "ollama_dart/openapi-ollama:main": {
        "repo": "ollama/ollama-python",
        "resources_adapter": "python_client_methods",
        "resources_path": "ollama/_client.py",
        "types_adapter": "python_single_file_classes",
        "types_path": "ollama/_types.py",
    },
    "open_responses/openapi-open-responses:main": {
        "repo": "openai/openai-python",
        "resources_adapter": "python_stainless_resources",
        "resources_path": "src/openai/resources/responses",
        "types_adapter": "python_init_exports",
        "types_path": "src/openai/types/responses/__init__.py",
    },
    "openai_dart/openapi-openai:main": {
        "repo": "openai/openai-python",
        "resources_adapter": "python_stainless_resources",
        "resources_path": "src/openai/resources",
        "types_adapter": "python_init_exports",
        "types_path": "src/openai/types/__init__.py",
    },
}


class AuditContractTests(unittest.TestCase):
    def test_all_real_openapi_specs_have_audit_config(self) -> None:
        for config_dir in OPENAPI_CONFIG_DIRS:
            config = load_toolkit_config(config_dir)
            for name, spec in config.specs.items():
                with self.subTest(config_dir=config_dir, spec=name):
                    self.assertIsNotNone(spec.audit)
                    self.assertIsNotNone(spec.audit.reference_impl)

    def test_real_audit_reference_configs_match_snapshot(self) -> None:
        actual: dict[str, dict[str, str | None]] = {}
        for config_dir in OPENAPI_CONFIG_DIRS:
            config = load_toolkit_config(config_dir)
            package_key = f"{config.package.name}/{config_dir.parent.name}"
            for name, spec in sorted(config.specs.items()):
                reference = spec.audit.reference_impl
                actual[f"{package_key}:{name}"] = {
                    "repo": reference.repo if reference else None,
                    "resources_adapter": reference.resources.adapter if reference and reference.resources else None,
                    "resources_path": reference.resources.path if reference and reference.resources else None,
                    "types_adapter": reference.types.adapter if reference and reference.types else None,
                    "types_path": reference.types.path if reference and reference.types else None,
                }

        self.assertEqual(actual, EXPECTED_AUDIT_REFERENCE_CONFIG)

    def test_open_responses_is_pinned_to_responses_reference_scope(self) -> None:
        config_dir = ROOT / "packages" / "open_responses" / ".agents" / "skills" / "openapi-open-responses" / "config"
        config = load_toolkit_config(config_dir)
        reference = config.specs["main"].audit.reference_impl

        self.assertEqual(reference.repo, "openai/openai-python")
        self.assertEqual(reference.resources.path, "src/openai/resources/responses")
        self.assertEqual(reference.types.path, "src/openai/types/responses/__init__.py")


if __name__ == "__main__":
    unittest.main()
