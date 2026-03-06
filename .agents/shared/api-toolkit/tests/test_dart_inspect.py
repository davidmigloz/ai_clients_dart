from __future__ import annotations

import os
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in os.sys.path:
    os.sys.path.insert(0, str(ROOT))

from api_toolkit.dart_inspect import extract_class_block, extract_fields, extract_method_body


class DartInspectTests(unittest.TestCase):
    def test_extract_class_block_returns_matching_class_only(self) -> None:
        content = (
            "class Before {\n"
            "  const Before();\n"
            "}\n"
            "\n"
            "sealed class Example {\n"
            "  final String id;\n"
            "  const Example(this.id);\n"
            "}\n"
            "\n"
            "enum Choice {\n"
            "  yes,\n"
            "  no,\n"
            "}\n"
        )

        block = extract_class_block(content, "Example")

        self.assertTrue(block.startswith("sealed class Example"))
        self.assertIn("final String id;", block)
        self.assertNotIn("class Before", block)
        self.assertNotIn("enum Choice", block)

    def test_extract_class_block_supports_enum_boundaries(self) -> None:
        content = (
            "class Before {}\n"
            "\n"
            "enum Transport {\n"
            "  car,\n"
            "  train,\n"
            "}\n"
            "\n"
            "class After {}\n"
        )

        block = extract_class_block(content, "Transport")

        self.assertEqual(block, "enum Transport {\n  car,\n  train,\n}")

    def test_extract_class_block_returns_empty_string_when_class_is_missing(self) -> None:
        content = (
            "class Example {\n"
            "  final String id;\n"
            "  const Example(this.id);\n"
            "}\n"
        )

        block = extract_class_block(content, "Missing")

        self.assertEqual(block, "")

    def test_extract_fields_includes_getters_and_nullability_with_class_scope(self) -> None:
        content = (
            "class Outside {\n"
            "  final bool ignored;\n"
            "  const Outside(this.ignored);\n"
            "}\n"
            "\n"
            "class Example {\n"
            "  final String id;\n"
            "  final int? count;\n"
            "  List<String>? get tags => _tags;\n"
            "  const Example(this.id, this.count);\n"
            "}\n"
        )

        with tempfile.TemporaryDirectory() as tmp_dir:
            path = Path(tmp_dir) / "example.dart"
            path.write_text(content)

            fields = extract_fields(path, "Example")

        self.assertEqual(set(fields), {"id", "count", "tags"})
        self.assertEqual(fields["id"].dart_type, "String")
        self.assertFalse(fields["id"].is_nullable)
        self.assertEqual(fields["count"].dart_type, "int")
        self.assertTrue(fields["count"].is_nullable)
        self.assertEqual(fields["tags"].dart_type, "List<String>")
        self.assertTrue(fields["tags"].is_nullable)

    def test_extract_fields_returns_empty_when_class_is_missing(self) -> None:
        content = (
            "class Example {\n"
            "  final String id;\n"
            "  const Example(this.id);\n"
            "}\n"
        )

        with tempfile.TemporaryDirectory() as tmp_dir:
            path = Path(tmp_dir) / "example.dart"
            path.write_text(content)

            fields = extract_fields(path, "Missing")

        self.assertEqual(fields, {})

    def test_extract_method_body_supports_brace_methods(self) -> None:
        content = (
            "class Example {\n"
            "  Map<String, dynamic> toJson() {\n"
            "    return {'id': id};\n"
            "  }\n"
            "}\n"
        )

        body = extract_method_body(content, r"Map<String,\s*dynamic>\s+toJson")

        self.assertEqual(body, "{\n    return {'id': id};\n  }")

    def test_extract_method_body_supports_arrow_methods(self) -> None:
        content = (
            "class Example {\n"
            "  int get hashCode => Object.hash(id);\n"
            "}\n"
        )

        body = extract_method_body(content, r"hashCode\s*=>")

        self.assertEqual(body, "=> Object.hash(id)")

    def test_extract_method_body_handles_arrow_method_without_trailing_semicolon(self) -> None:
        content = (
            "class Example {\n"
            "  String toString() => 'Example(id: $id)'\n"
            "}\n"
        )

        body = extract_method_body(content, r"toString\s*\(\)")

        self.assertEqual(body, "=> 'Example(id: $id)'")


if __name__ == "__main__":
    unittest.main()
