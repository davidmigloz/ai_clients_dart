import importlib.util
import io
import unittest
from contextlib import redirect_stderr
from pathlib import Path
from unittest.mock import patch


def _load_module(module_path: Path, module_name: str):
    spec = importlib.util.spec_from_file_location(module_name, module_path)
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    spec.loader.exec_module(module)  # type: ignore[attr-defined]
    return module


MODULE_PATH = Path(__file__).resolve().parents[1] / "scripts" / "fetch_spec.py"
fetch_spec = _load_module(MODULE_PATH, "fetch_spec_script")


class FetchSpecPreflightTests(unittest.TestCase):
    def test_parse_stats_field_extracts_openapi_url(self):
        stats = """
openapi_spec_url: https://storage.googleapis.com/stainless-sdk-openapi-specs/openai%2Fopenai-deadbeef.yml
api_coverage: 100
"""
        parsed = fetch_spec.parse_stats_field(stats, "openapi_spec_url")
        self.assertEqual(
            parsed,
            "https://storage.googleapis.com/stainless-sdk-openapi-specs/openai%2Fopenai-deadbeef.yml",
        )

    def test_run_preflight_prints_offline_guidance_when_network_fails(self):
        config = {
            "specs": {
                "main": {
                    "url": "https://storage.googleapis.com/stainless-sdk-openapi-specs/openai%2Fopenai-oldhash.yml"
                }
            },
            "preflight": {
                "stats_url": "https://raw.githubusercontent.com/openai/openai-python/refs/heads/main/.stats.yml",
                "stats_field": "openapi_spec_url",
            },
        }
        config_dir = Path("packages/openai_dart/.agents/skills/openapi-openai/config")
        stderr = io.StringIO()

        with patch.object(
            fetch_spec,
            "fetch_text_url",
            return_value=(None, "Network error: temporary failure"),
        ):
            with redirect_stderr(stderr):
                is_online = fetch_spec.run_preflight(config, config_dir, None)

        self.assertFalse(is_online)
        rendered = stderr.getvalue()
        self.assertIn("OFFLINE MODE", rendered)
        self.assertIn("fetch_spec.py --config-dir", rendered)


if __name__ == "__main__":
    unittest.main()
