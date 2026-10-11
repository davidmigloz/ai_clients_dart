from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from api_toolkit.operations import _render_readme_scaffold, _verify_readme


class ReadmeUsageTests(unittest.TestCase):
    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.package = Path(temporary.name)
        (self.package / "example").mkdir()
        for name in ("example.dart", "one.dart", "two.dart"):
            (self.package / "example" / name).write_text("void main() {}\n")
        self.scaffold = _render_readme_scaffold(
            self.package,
            package_name="sample_dart",
            display_name="Sample",
            version="0.1.0",
            api_url=None,
        )

    def verify(self, usage: str) -> tuple[int, dict]:
        before, remainder = self.scaffold.split("## Usage\n", 1)
        after = remainder.split("## Error Handling\n", 1)[1]
        (self.package / "README.md").write_text(
            before + "## Usage\n\n" + usage + "\n\n## Error Handling\n" + after
        )
        return _verify_readme(SimpleNamespace(package_root=self.package))

    def test_scaffold_uses_collapsed_task_summaries(self) -> None:
        (self.package / "README.md").write_text(self.scaffold)
        code, result = _verify_readme(SimpleNamespace(package_root=self.package))
        self.assertEqual(code, 0)
        self.assertEqual(result["issues"], [])
        self.assertEqual(result["summary"]["usage_subsections"], 1)
        self.assertIn("### Common tasks", self.scaffold)
        self.assertIn("<summary><b>How do I make my first request?</b></summary>", self.scaffold)

    def test_groups_and_link_only_topics_are_counted_individually(self) -> None:
        code, result = self.verify("""
### Responses API

<details>
<summary><b>Create a response</b></summary>

Use the response text.

```dart
void main() {}
```

→ [Full example](example/one.dart)

</details>

<details>
<summary>Stream a response</summary>

Display output as it arrives.

→ [Full example](example/two.dart)

</details>

### Advanced workflows

<details>
<summary>Reuse a connection</summary>

Use the full example for connection lifecycle handling.

→ [Full example](example/one.dart)

</details>
""")
        self.assertEqual(code, 0)
        self.assertEqual(result["issues"], [])
        self.assertEqual(result["summary"]["usage_subsections"], 3)

    def test_legacy_heading_and_show_example_remain_supported(self) -> None:
        code, result = self.verify("""
### How do I make a request?

<details>
<summary><b>Show example</b></summary>

→ [Full example](example/one.dart)

</details>
""")
        self.assertEqual(code, 0)
        self.assertEqual(result["issues"], [])
        self.assertEqual(result["summary"]["usage_subsections"], 1)

    def test_sibling_example_does_not_hide_topic_without_a_link(self) -> None:
        code, result = self.verify("""
### Common tasks
<details><summary>Create</summary>

→ [Full example](example/one.dart)

</details>
<details><summary>Stream</summary>

This topic has no example link.

</details>
""")
        self.assertEqual(code, 0)
        self.assertEqual(result["summary"]["usage_subsections"], 2)
        self.assertEqual([issue["name"] for issue in result["issues"]], ["Stream"])
        self.assertIn("link to an example", result["issues"][0]["message"])

    def test_all_missing_files_are_reported_per_topic(self) -> None:
        code, result = self.verify("""
<details><summary>Create</summary>

[One](example/missing-one.dart) and [Two](example/missing-two.dart)

</details>
<details><summary>Stream</summary>

[Three](example/missing-three.dart)

</details>
""")
        self.assertEqual(code, 1)
        self.assertEqual([issue["name"] for issue in result["issues"]], ["Create", "Create", "Stream"])
        self.assertTrue(all(issue["level"] == "error" for issue in result["issues"]))
        self.assertEqual(result["summary"]["errors"], 3)

    def test_expanded_topics_and_examples_outside_disclosures_are_warned(self) -> None:
        for usage in (
            "### Request\n\n[Full example](example/one.dart)",
            "[Full example](example/one.dart)",
            "### Requests\n<details><summary>Create</summary>\n\n"
            "[Full example](example/one.dart)\n\n</details>\n\n"
            "```dart\nvoid main() {}\n```\n\n[Other](example/two.dart)",
        ):
            with self.subTest(usage=usage):
                code, result = self.verify(usage)
                self.assertEqual(code, 0)
                self.assertEqual(len(result["issues"]), 1)
                self.assertIn("should be collapsible", result["issues"][0]["message"])

    def test_open_attribute_warns_even_when_its_value_is_false(self) -> None:
        for attribute in ("open", 'open="false"'):
            with self.subTest(attribute=attribute):
                code, result = self.verify(
                    f"<details {attribute}><summary>Stream</summary>\n\n"
                    "[Full example](example/one.dart)\n\n</details>"
                )
                self.assertEqual(code, 0)
                self.assertEqual(len(result["issues"]), 1)
                self.assertIn("collapsed by default", result["issues"][0]["message"])

    def test_missing_or_empty_summary_is_reported(self) -> None:
        for summary in ("", "<summary>  </summary>"):
            with self.subTest(summary=summary):
                code, result = self.verify(
                    f"<details>{summary}\n\n[Full example](example/one.dart)\n\n</details>"
                )
                self.assertEqual(code, 0)
                self.assertEqual(len(result["issues"]), 1)
                self.assertIn("nonempty summary", result["issues"][0]["message"])

    def test_unbalanced_details_are_reported(self) -> None:
        for usage, message in (
            ("<details><summary>Request</summary>\n\n[Full example](example/one.dart)", "missing its closing"),
            ("</details>", "Unmatched </details>"),
        ):
            with self.subTest(usage=usage):
                code, result = self.verify(usage)
                self.assertEqual(code, 0)
                self.assertEqual(len(result["issues"]), 1)
                self.assertIn(message, result["issues"][0]["message"])

    def test_unclosed_summary_is_reported(self) -> None:
        code, result = self.verify(
            "<details><summary>Request\n\n[Full example](example/one.dart)\n\n</details>"
        )
        self.assertEqual(code, 0)
        self.assertEqual(len(result["issues"]), 1)
        self.assertIn("missing its closing </summary>", result["issues"][0]["message"])

    def test_nested_groups_validate_leaf_topics(self) -> None:
        code, result = self.verify("""
<details><summary>Advanced workflows</summary>
<details><summary>First task</summary>

[Full example](example/one.dart)

</details>
<details><summary>Second task</summary>

[Full example](example/two.dart)

</details>
</details>
""")
        self.assertEqual(code, 0)
        self.assertEqual(result["issues"], [])
        self.assertEqual(result["summary"]["usage_subsections"], 2)

    def test_code_and_comments_do_not_create_fake_topics_or_links(self) -> None:
        code, result = self.verify("""
Use `<details open>` for a disclosure. Literal `[Fake](example/missing.dart)` is code.

<!--
### Fake group
<details open><summary>Fake topic</summary>
[Fake](example/missing.dart)
-->

<details><summary>Real topic</summary>

```dart
// <details open><summary>Not markup</summary>
// [Fake](example/missing.dart)
// ### Not a group
```

<!-- [Another fake link](example/missing.dart) -->

[Full example](example/one.dart)

</details>
""")
        self.assertEqual(code, 0)
        self.assertEqual(result["issues"], [])
        self.assertEqual(result["summary"]["usage_subsections"], 1)

    def test_flat_topics_with_multiline_summaries_and_same_line_tags(self) -> None:
        code, result = self.verify("""
<DETAILS class="example"><SUMMARY>
<b>Create &amp; read</b>
</SUMMARY>

[Full example](./example/one.dart)

</DETAILS ><details><summary>Stream</summary>

[Full example](example/two.dart)

</details>
""")
        self.assertEqual(code, 0)
        self.assertEqual(result["issues"], [])
        self.assertEqual(result["summary"]["usage_subsections"], 2)


if __name__ == "__main__":
    unittest.main()
