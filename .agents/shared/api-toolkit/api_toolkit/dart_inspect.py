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


@dataclass(slots=True)
class DartDeclaration:
    kind: str
    code: str
    literals: set[str]


def _decode_dart_literal(value: str, raw: bool) -> str | None:
    if raw:
        return value
    result: list[str] = []
    index = 0
    escapes = {"n": "\n", "r": "\r", "t": "\t", "b": "\b", "f": "\f", "v": "\v"}
    while index < len(value):
        char = value[index]
        if char == "$" and index + 1 < len(value) and (value[index + 1] == "{" or re.match(r"[A-Za-z_]", value[index + 1])):
            return None
        if char != "\\":
            result.append(char)
            index += 1
            continue
        index += 1
        if index >= len(value):
            return None
        escaped = value[index]
        index += 1
        if escaped == "u":
            if index < len(value) and value[index] == "{":
                end = value.find("}", index + 1)
                if end == -1:
                    return None
                digits = value[index + 1:end]
                index = end + 1
            else:
                digits = value[index:index + 4]
                index += 4
            try:
                result.append(chr(int(digits, 16)))
            except (ValueError, OverflowError):
                return None
        else:
            result.append(escapes.get(escaped, escaped))
    return "".join(result)


def _dart_comment_end(content: str, start: int) -> int:
    if content.startswith("//", start):
        end = content.find("\n", start)
        return len(content) if end == -1 else end
    depth = 1
    index = start + 2
    while index < len(content) and depth:
        if content.startswith("/*", index):
            depth += 1
            index += 2
        elif content.startswith("*/", index):
            depth -= 1
            index += 2
        else:
            index += 1
    return index


def _dart_string_end(content: str, quote_index: int, raw: bool) -> tuple[int, int]:
    quote = content[quote_index]
    delimiter = quote * (3 if content.startswith(quote * 3, quote_index) else 1)
    index = quote_index + len(delimiter)
    while index < len(content):
        if content.startswith(delimiter, index):
            return index, index + len(delimiter)
        if not raw and content[index] == "\\":
            index += 2
        elif not raw and content.startswith("${", index):
            index = _dart_interpolation_end(content, index + 2)
        else:
            index += 1
    return len(content), len(content)


def _dart_interpolation_end(content: str, index: int) -> int:
    depth = 1
    while index < len(content) and depth:
        if content.startswith(("//", "/*"), index):
            index = _dart_comment_end(content, index)
            continue
        raw = content[index] == "r" and index + 1 < len(content) and content[index + 1] in "'\""
        quote_index = index + 1 if raw else index
        if content[quote_index] in "'\"":
            _, index = _dart_string_end(content, quote_index, raw)
        else:
            depth += (content[index] == "{") - (content[index] == "}")
            index += 1
    return index


def dart_enum_constant_names(code: str) -> set[str]:
    """Read identifiers in the constant list, never fields/method parameters."""
    opening = code.find("{")
    if opening == -1:
        return set()
    segments: list[str] = []
    start = opening + 1
    parentheses = brackets = braces = angles = 0
    for index in range(start, len(code)):
        char = code[index]
        if not (parentheses or brackets or braces or angles):
            if char in ";}":
                segments.append(code[start:index])
                break
            if char == ",":
                segments.append(code[start:index])
                start = index + 1
                continue
        parentheses += (char == "(") - (char == ")")
        brackets += (char == "[") - (char == "]")
        braces += (char == "{") - (char == "}")
        if not (parentheses or brackets or braces):
            angles += (char == "<") - (char == ">")
    names = set()
    for segment in segments:
        # Constant metadata may precede the actual enum identifier. Its string
        # arguments were already masked, and ordinary annotations are balanced.
        rest = segment.strip()
        while rest.startswith("@"):
            annotation = re.match(r"@[\w.]+\s*", rest)
            if annotation is None:
                break
            end = annotation.end()
            if end < len(rest) and rest[end] == "(":
                depth = 1
                end += 1
                while end < len(rest) and depth:
                    depth += (rest[end] == "(") - (rest[end] == ")")
                    end += 1
            rest = rest[end:].lstrip()
        match = re.match(r"[A-Za-z_]\w*", rest)
        if match:
            names.add(match.group())
    return names


def _dart_code_and_literals(content: str) -> tuple[str, list[tuple[int, str]]]:
    """Mask comments/strings for boundaries and retain fixed wire literals.

    This lexical scan is not a Dart parser. Comments, doc examples and braces
    inside string literals cannot fabricate declarations or supply enum values.
    """
    masked = list(content)
    literals: list[tuple[int, str]] = []
    index = 0
    while index < len(content):
        start = index
        if content.startswith(("//", "/*"), index):
            index = _dart_comment_end(content, index)
        else:
            raw = content[index] == "r" and index + 1 < len(content) and content[index + 1] in "'\""
            quote_index = index + 1 if raw else index
            if content[quote_index] not in "'\"":
                index += 1
                continue
            delimiter_size = 3 if content.startswith(content[quote_index] * 3, quote_index) else 1
            value_start = quote_index + delimiter_size
            value_end, index = _dart_string_end(content, quote_index, raw)
            value = _decode_dart_literal(content[value_start:value_end], raw)
            if value is not None:
                literals.append((start, value))
        for position in range(start, index):
            if masked[position] != "\n":
                masked[position] = " "
    return "".join(masked), literals


def _associated_codec_ranges(code: str, class_name: str) -> list[tuple[int, int]]:
    """Find typed top-level codec functions/extensions for one declaration."""
    depths = []
    depth = 0
    for char in code:
        depths.append(depth)
        depth += (char == "{") - (char == "}")
    ranges: list[tuple[int, int]] = []

    def block_end(start: int) -> int:
        level = 0
        for position in range(start, len(code)):
            level += (code[position] == "{") - (code[position] == "}")
            if level == 0:
                return position + 1
        return len(code)

    for match in re.finditer(r"(?m)^[ \t]*(?:[\w<>?,.]+\s+)+\w+\s*\(", code):
        if depths[match.start()] != 0:
            continue
        opening = code.find("(", match.start())
        level = 1
        closing = opening + 1
        while closing < len(code) and level:
            level += (code[closing] == "(") - (code[closing] == ")")
            closing += 1
        signature = code[match.start():closing]
        if not re.search(rf"\b{re.escape(class_name)}\b", signature):
            continue
        body = re.match(r"\s*(?:async\*?\s*)?(=>|\{)", code[closing:])
        if body is None:
            continue
        start = closing + body.start(1)
        if body.group(1) == "{":
            end = block_end(start)
        else:
            end = code.find(";", start)
            end = len(code) if end == -1 else end + 1
        ranges.append((match.start(), end))
    for match in re.finditer(rf"\bextension(?:\s+\w+)?\s+on\s+{re.escape(class_name)}\s*\{{", code):
        if depths[match.start()] == 0:
            ranges.append((match.start(), block_end(code.find("{", match.start()))))
    return ranges


def extract_dart_declaration(content: str, class_name: str) -> DartDeclaration | None:
    """Read only one actual class/enum's code and fixed string literals."""
    code, literals = _dart_code_and_literals(content)
    match = re.search(rf"\b(?:(sealed)\s+)?(class|enum)\s+{re.escape(class_name)}\b", code)
    if not match:
        return None
    start = code.find("{", match.end())
    if start == -1 or ";" in code[match.end():start]:
        return None
    depth = 0
    end = len(code)
    for position in range(start, len(code)):
        if code[position] == "{":
            depth += 1
        elif code[position] == "}":
            depth -= 1
            if depth == 0:
                end = position + 1
                break
    ranges = [(match.start(), end), *_associated_codec_ranges(code, class_name)]
    return DartDeclaration(
        kind="sealed" if match.group(1) else match.group(2),
        code="\n".join(code[begin:finish] for begin, finish in ranges),
        literals={value for position, value in literals if any(begin <= position < finish for begin, finish in ranges)},
    )


def read_text(path: Path) -> str:
    return path.read_text() if path.exists() else ""


def find_declared_classes(path: Path) -> list[str]:
    code, _ = _dart_code_and_literals(read_text(path))
    return CLASS_PATTERN.findall(code)


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
    # Capitalize each trailing segment's first character and lowercase the rest —
    # like str.title() but WITHOUT treating digits as word boundaries, so a letter
    # is never uppercased just because a digit precedes it: "1h" stays "1h"
    # (matching Dart field names like `ephemeral1hInputTokens`) and "v2beta"
    # becomes "V2beta", where str.title() would yield "1H"/"V2Beta". Behaviour is
    # identical to str.title() only for segments with no digit-adjacent letters.
    return parts[0] + "".join(p[:1].upper() + p[1:].lower() for p in parts[1:])


def snake_case(name: str) -> str:
    if "_" in name:
        return name
    result = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", name).lower()
    return result


def to_pascal_case(name: str) -> str:
    words = re.split(r"[_\s-]+", name)
    return "".join(word[:1].upper() + word[1:] for word in words if word)
