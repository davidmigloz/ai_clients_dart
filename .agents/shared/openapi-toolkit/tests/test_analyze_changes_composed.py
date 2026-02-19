import importlib.util
import unittest
from pathlib import Path


def _load_module(module_path: Path, module_name: str):
    spec = importlib.util.spec_from_file_location(module_name, module_path)
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    spec.loader.exec_module(module)  # type: ignore[attr-defined]
    return module


MODULE_PATH = (
    Path(__file__).resolve().parents[1] / "scripts" / "analyze_changes.py"
)
analyze_changes = _load_module(MODULE_PATH, "analyze_changes_script")


def _modified_schema_changes(analysis: dict, schema_name: str) -> list[dict]:
    for entry in analysis["schemas"]["modified"]:
        if entry["schema"]["name"] == schema_name:
            return entry["changes"]
    return []


class AnalyzeChangesComposedSchemaTests(unittest.TestCase):
    def test_detects_property_changes_inside_allof(self):
        old_spec = {
            "openapi": "3.1.0",
            "info": {"version": "1"},
            "paths": {},
            "components": {
                "schemas": {
                    "Base": {
                        "type": "object",
                        "properties": {"id": {"type": "string"}},
                        "required": ["id"],
                    },
                    "Wrapper": {
                        "allOf": [
                            {"$ref": "#/components/schemas/Base"},
                            {"type": "object", "properties": {"name": {"type": "string"}}},
                        ]
                    },
                }
            },
        }
        new_spec = {
            "openapi": "3.1.0",
            "info": {"version": "2"},
            "paths": {},
            "components": {
                "schemas": {
                    "Base": {
                        "type": "object",
                        "properties": {"id": {"type": "string"}},
                        "required": ["id"],
                    },
                    "Wrapper": {
                        "allOf": [
                            {"$ref": "#/components/schemas/Base"},
                            {
                                "type": "object",
                                "properties": {
                                    "name": {"type": "string"},
                                    "age": {"type": "integer"},
                                },
                                "required": ["age"],
                            },
                        ]
                    },
                }
            },
        }

        analysis = analyze_changes.analyze_specs(old_spec, new_spec)
        changes = _modified_schema_changes(analysis, "Wrapper")
        change_types = {change["type"] for change in changes}
        self.assertIn("property_added", change_types)
        self.assertTrue(any(change.get("property") == "age" for change in changes))

    def test_flags_added_union_members(self):
        old_spec = {
            "openapi": "3.1.0",
            "info": {"version": "1"},
            "paths": {},
            "components": {
                "schemas": {
                    "VariantA": {"type": "object"},
                    "VariantB": {"type": "object"},
                    "VariantC": {"type": "object"},
                    "ToolUnion": {
                        "oneOf": [
                            {"$ref": "#/components/schemas/VariantA"},
                            {"$ref": "#/components/schemas/VariantB"},
                        ]
                    },
                }
            },
        }
        new_spec = {
            "openapi": "3.1.0",
            "info": {"version": "2"},
            "paths": {},
            "components": {
                "schemas": {
                    "VariantA": {"type": "object"},
                    "VariantB": {"type": "object"},
                    "VariantC": {"type": "object"},
                    "ToolUnion": {
                        "oneOf": [
                            {"$ref": "#/components/schemas/VariantA"},
                            {"$ref": "#/components/schemas/VariantB"},
                            {"$ref": "#/components/schemas/VariantC"},
                        ]
                    },
                }
            },
        }

        analysis = analyze_changes.analyze_specs(old_spec, new_spec)
        changes = _modified_schema_changes(analysis, "ToolUnion")
        self.assertTrue(
            any(
                change["type"] == "union_member_added"
                and change.get("member") == "VariantC"
                for change in changes
            )
        )


if __name__ == "__main__":
    unittest.main()
