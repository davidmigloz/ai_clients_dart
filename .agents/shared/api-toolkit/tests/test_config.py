from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import api_toolkit.config as toolkit_config
from api_toolkit.config import AuthConfig, default_output_dir, fetch_remote_document, load_toolkit_config


class ConfigTests(unittest.TestCase):
    def _write_minimal_config(self, root: Path) -> Path:
        package_root = root / "packages" / "sample_dart"
        config_dir = package_root / ".agents" / "skills" / "openapi-sample" / "config"
        config_dir.mkdir(parents=True)
        (root / "pubspec.yaml").write_text("name: workspace\nworkspace:\n  - packages/sample_dart\n")
        (package_root / "pubspec.yaml").write_text("name: sample_dart\n")
        (config_dir / "package.json").write_text(
            json.dumps(
                {
                    "name": "sample_dart",
                    "display_name": "Sample",
                },
                indent=2,
            )
        )
        (config_dir / "specs.json").write_text(
            json.dumps(
                {
                    "specs": {
                        "main": {
                            "name": "Sample API",
                            "local_file": "openapi.json",
                            "fetch_mode": "local_file",
                            "source_file": "specs/openapi.json",
                        }
                    },
                    "specs_dir": "packages/sample_dart/specs",
                },
                indent=2,
            )
        )
        (config_dir / "manifest.json").write_text(
            json.dumps({"surface": "openapi", "type_mappings": {}, "placement": {}, "coverage": {}, "types": {}}, indent=2)
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
        return config_dir

    def test_default_output_dir_uses_tempfile_gettempdir(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            with patch.object(toolkit_config.tempfile, "gettempdir", return_value=tmp_dir):
                self.assertEqual(default_output_dir("sample_dart"), (Path(tmp_dir) / "sample_dart-api-toolkit").resolve())

    def test_load_toolkit_config_uses_tempdir_default_output_dir(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            with patch.object(toolkit_config.tempfile, "gettempdir", return_value=tmp_dir):
                config_dir = self._write_minimal_config(Path(tmp_dir))
                config = load_toolkit_config(config_dir)
                self.assertEqual(config.output_dir, (Path(tmp_dir) / "sample_dart-api-toolkit").resolve())

    def test_fetch_remote_document_uses_header_auth_without_mutating_url(self) -> None:
        with patch("api_toolkit.config.urlopen") as mock_urlopen:
            response = MagicMock()
            response.read.return_value = b'{"openapi":"3.1.0"}'
            mock_urlopen.return_value.__enter__.return_value = response

            document, error = fetch_remote_document(
                "https://generativelanguage.googleapis.com/$discovery/OPENAPI3_0?version=v1beta",
                "secret-key",
                AuthConfig(location="header", name="x-goog-api-key", prefix=""),
            )

            self.assertEqual(document, '{"openapi":"3.1.0"}')
            self.assertIsNone(error)
            request = mock_urlopen.call_args.args[0]
            headers = {key.lower(): value for key, value in request.header_items()}
            self.assertEqual(request.full_url, "https://generativelanguage.googleapis.com/$discovery/OPENAPI3_0?version=v1beta")
            self.assertEqual(headers["x-goog-api-key"], "secret-key")
            self.assertEqual(mock_urlopen.call_args.kwargs["timeout"], 30)

    def test_fetch_remote_document_urlencodes_query_auth(self) -> None:
        with patch("api_toolkit.config.urlopen") as mock_urlopen:
            response = MagicMock()
            response.read.return_value = b'{"openapi":"3.1.0"}'
            mock_urlopen.return_value.__enter__.return_value = response

            document, error = fetch_remote_document(
                "https://example.com/openapi.json?version=v1",
                "abc/123 +=",
                AuthConfig(location="query", name="key", prefix=""),
            )

            self.assertEqual(document, '{"openapi":"3.1.0"}')
            self.assertIsNone(error)
            request = mock_urlopen.call_args.args[0]
            self.assertIn("version=v1", request.full_url)
            self.assertIn("key=abc%2F123+%2B%3D", request.full_url)
            self.assertEqual(mock_urlopen.call_args.kwargs["timeout"], 30)


if __name__ == "__main__":
    unittest.main()
