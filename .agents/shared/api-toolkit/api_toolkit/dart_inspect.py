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
    brace_index = content.find("{", start)
    if brace_index == -1:
        arrow_index = content.find("=>", start)
        if arrow_index == -1 and "=>" in match.group(0):
            arrow_index = content.rfind("=>", match.start(), match.end())
        if arrow_index == -1:
            return ""
        semicolon_index = content.find(";", arrow_index)
        if semicolon_index == -1:
            newline_index = content.find("\n", arrow_index)
            end_index = newline_index if newline_index != -1 else len(content)
            return content[arrow_index:end_index]
        return content[arrow_index:semicolon_index]
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
