from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path


@dataclass(slots=True)
class DartField:
    name: str
    dart_type: str
    is_nullable: bool
    line_number: int


FIELD_PATTERN = re.compile(r"^\s*final\s+([\w<>?,.\s]+?)\s+(\w+)\s*;", re.MULTILINE)
GETTER_PATTERN = re.compile(r"^\s*([\w<>?,.\s]+?)\s+get\s+(\w+)\s*(?:=>|{)", re.MULTILINE)
CLASS_PATTERN = re.compile(r"(?:sealed\s+class|class|enum)\s+(\w+)")
FROM_JSON_KEY_RE = re.compile(r"""\bjson\s*\[\s*(['"])([^'"]+)\1\s*\]""")


def read_text(path: Path) -> str:
    return path.read_text() if path.exists() else ""


def find_declared_classes(path: Path) -> list[str]:
    return CLASS_PATTERN.findall(read_text(path))


def extract_class_block(content: str, class_name: str) -> str:
    start = re.search(rf"\b(?:sealed\s+class|class|enum)\s+{re.escape(class_name)}\b", content)
    if not start:
        return ""
    index = start.start()
    brace_index = content.find("{", index)
    if brace_index == -1:
        return content[index:]
    depth = 0
    for position in range(brace_index, len(content)):
        char = content[position]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return content[index : position + 1]
    return content[index:]


def extract_fields(path: Path, class_name: str | None = None) -> dict[str, DartField]:
    content = read_text(path)
    if class_name:
        content = extract_class_block(content, class_name)
    fields: dict[str, DartField] = {}
    for pattern in (FIELD_PATTERN, GETTER_PATTERN):
        for match in pattern.finditer(content):
            full_type = match.group(1).strip()
            name = match.group(2)
            is_nullable = full_type.endswith("?")
            fields.setdefault(
                name,
                DartField(
                    name=name,
                    dart_type=full_type.rstrip("?").strip(),
                    is_nullable=is_nullable,
                    line_number=content[: match.start()].count("\n") + 1,
                ),
            )
    return fields


def contains_all_names(content: str, names: set[str]) -> set[str]:
    missing = set()
    for name in names:
        if not re.search(rf"\b{re.escape(name)}\b", content):
            missing.add(name)
    return missing


def extract_method_body(content: str, method_pattern: str) -> str:
    match = re.search(method_pattern, content, re.DOTALL)
    if not match:
        return ""
    start = match.end()

    # If the pattern already consumed '=>', find the terminating semicolon
    if "=>" in match.group(0):
        # Include the '=>' in the returned body for consistency
        arrow_pos = match.group(0).rfind("=>")
        body_start = match.start() + arrow_pos
        semicolon_index = content.find(";", start)
        if semicolon_index != -1:
            return content[body_start:semicolon_index]
        newline_index = content.find("\n", start)
        end_index = newline_index if newline_index != -1 else len(content)
        return content[body_start:end_index]

    brace_index = content.find("{", start)
    arrow_index = content.find("=>", start)

    # If '=>' comes before '{' (or no '{' at all), it's an arrow expression
    if arrow_index != -1 and (brace_index == -1 or arrow_index < brace_index):
        semicolon_index = content.find(";", arrow_index)
        if semicolon_index != -1:
            return content[arrow_index:semicolon_index]
        newline_index = content.find("\n", arrow_index)
        end_index = newline_index if newline_index != -1 else len(content)
        return content[arrow_index:end_index]

    # Block body — track brace depth
    if brace_index == -1:
        return ""
    depth = 0
    for position in range(brace_index, len(content)):
        char = content[position]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return content[brace_index : position + 1]
    return ""


def extract_from_json_keys(content: str, class_name: str) -> set[str]:
    class_block = extract_class_block(content, class_name)
    if not class_block:
        return set()
    body = extract_method_body(class_block, rf"factory\s+{re.escape(class_name)}\.fromJson")
    if not body:
        return set()
    return {match.group(2) for match in FROM_JSON_KEY_RE.finditer(body)}


def extract_public_methods(path: Path, class_name: str | None = None) -> set[str]:
    content = read_text(path)
    if class_name:
        content = extract_class_block(content, class_name)
    if not content:
        return set()
    methods: set[str] = set()
    brace_depth = 0
    for line in content.splitlines():
        stripped = line.strip()
        if brace_depth == 1:
            if not stripped or stripped.startswith(
                ("class ", "sealed class ", "enum ", "static ", "factory ", "const ", "@")
            ):
                brace_depth += line.count("{") - line.count("}")
                continue
            if " get " not in stripped and not stripped.startswith("get "):
                match = re.match(r"(?:[\w<>,?.]+\s+)+([a-zA-Z]\w*)\s*\(", stripped)
                if match:
                    name = match.group(1)
                    if not name.startswith("_") and name not in {"get", "set"} and (
                        not class_name or name != class_name
                    ):
                        methods.add(name)
        brace_depth += line.count("{") - line.count("}")
    return methods


def extract_named_factories(path: Path, class_name: str | None = None) -> set[str]:
    content = read_text(path)
    if class_name:
        content = extract_class_block(content, class_name)
    if not content:
        return set()
    # Match named factory constructors: factory ClassName.factoryName(
    return {m.group(1) for m in re.finditer(r"\bfactory\s+\w+\.(\w+)\s*[(<]", content)}


def camel_case(name: str) -> str:
    if "_" not in name:
        return name[0].lower() + name[1:] if name and name[0].isupper() else name
    parts = name.split("_")
    return parts[0] + "".join(part.title() for part in parts[1:])


def snake_case(name: str) -> str:
    if "_" in name:
        return name
    result = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", name).lower()
    return result


def to_pascal_case(name: str) -> str:
    words = re.split(r"[_\s-]+", name)
    return "".join(word[:1].upper() + word[1:] for word in words if word)
