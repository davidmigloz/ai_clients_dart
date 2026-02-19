import importlib.util
import json
import os
import tempfile
import unittest
from pathlib import Path


def _load_module(module_path: Path, module_name: str):
    spec = importlib.util.spec_from_file_location(module_name, module_path)
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    spec.loader.exec_module(module)  # type: ignore[attr-defined]
    return module


MODULE_PATH = (
    Path(__file__).resolve().parents[1] / "scripts" / "verify_coverage.py"
)
verify_coverage = _load_module(MODULE_PATH, "verify_coverage_script")


class VerifyCoverageAutoLocateTests(unittest.TestCase):
    def test_uses_local_spec_when_latest_snapshot_missing(self):
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            package_root = root / "packages" / "openai_dart"
            config_dir = package_root / ".agents" / "skills" / "openapi-openai" / "config"
            config_dir.mkdir(parents=True)

            local_specs_dir = package_root / "specs"
            local_specs_dir.mkdir(parents=True)
            local_spec = local_specs_dir / "openapi.json"
            local_spec.write_text(json.dumps({"openapi": "3.0.0", "paths": {}}))

            specs_config = {
                "specs": {"main": {"local_file": "openapi.json"}},
                "output_dir": str(root / "tmp" / "openapi-openai-dart"),
                "specs_dir": "packages/openai_dart/specs",
            }
            (config_dir / "specs.json").write_text(json.dumps(specs_config))

            previous_cwd = Path.cwd()
            try:
                os.chdir(root)
                located = verify_coverage.auto_locate_spec(config_dir)
                if located is not None and not located.is_absolute():
                    located = (Path.cwd() / located).resolve()
            finally:
                os.chdir(previous_cwd)

            self.assertIsNotNone(located)
            self.assertTrue(located.samefile(local_spec))

    def test_prefers_latest_snapshot_when_present(self):
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            package_root = root / "packages" / "openai_dart"
            config_dir = package_root / ".agents" / "skills" / "openapi-openai" / "config"
            config_dir.mkdir(parents=True)

            local_specs_dir = package_root / "specs"
            local_specs_dir.mkdir(parents=True)
            local_spec = local_specs_dir / "openapi.json"
            local_spec.write_text(json.dumps({"openapi": "3.0.0", "paths": {}}))

            output_dir = root / "tmp" / "openapi-openai-dart"
            output_dir.mkdir(parents=True)
            latest_spec = output_dir / "latest-main.json"
            latest_spec.write_text(json.dumps({"openapi": "3.1.0", "paths": {}}))

            specs_config = {
                "specs": {"main": {"local_file": "openapi.json"}},
                "output_dir": str(output_dir),
                "specs_dir": "packages/openai_dart/specs",
            }
            (config_dir / "specs.json").write_text(json.dumps(specs_config))

            located = verify_coverage.auto_locate_spec(config_dir)
            self.assertIsNotNone(located)
            self.assertEqual(located.resolve(), latest_spec.resolve())


if __name__ == "__main__":
    unittest.main()
