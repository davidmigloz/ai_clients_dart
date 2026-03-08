from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from .config import EXIT_FAILURE, EXIT_SUCCESS, EXIT_USAGE, ToolkitError, choose_format
from .operations import (
    command_audit,
    command_create,
    command_describe,
    command_fetch,
    command_review,
    command_scaffold,
    command_verify,
)


def _add_common_output_args(parser: argparse.ArgumentParser, *, include_fields: bool = False) -> None:
    parser.add_argument("--format", choices=["json", "text"])
    if include_fields:
        parser.add_argument(
            "--fields",
            help="Comma-separated top-level fields to keep in JSON/text output",
        )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Unified API toolkit for agent-first workflows")
    subparsers = parser.add_subparsers(dest="command", required=True)

    create_parser = subparsers.add_parser("create", help="Bootstrap a new OpenAPI client package")
    create_parser.add_argument("--package-name", required=True)
    create_parser.add_argument("--display-name", required=True)
    create_parser.add_argument("--spec-url")
    create_parser.add_argument("--spec-file", type=Path)
    create_parser.add_argument("--shortname")
    create_parser.add_argument("--auth-env-var", action="append", default=[])
    create_parser.add_argument("--repo-root", type=Path)
    create_parser.add_argument("--output-root", default="packages")
    create_parser.add_argument("--dry-run", action="store_true")
    _add_common_output_args(create_parser, include_fields=True)

    fetch_parser = subparsers.add_parser("fetch", help="Fetch the latest spec/schema")
    fetch_parser.add_argument("--config-dir", type=Path, required=True)
    fetch_parser.add_argument("--spec-name")
    fetch_parser.add_argument("--dry-run", action="store_true")
    fetch_parser.add_argument("--preflight-only", action="store_true")
    _add_common_output_args(fetch_parser, include_fields=True)

    review_parser = subparsers.add_parser("review", help="Analyze spec changes and implementation gaps")
    review_parser.add_argument("--config-dir", type=Path, required=True)
    review_parser.add_argument("--spec-name")
    review_parser.add_argument("--baseline", type=Path)
    review_parser.add_argument("--git-ref")
    review_parser.add_argument("--changelog-out", type=Path)
    review_parser.add_argument("--plan-out", type=Path)
    _add_common_output_args(review_parser, include_fields=True)

    describe_parser = subparsers.add_parser("describe", help="Describe config/spec/manifest state")
    describe_parser.add_argument("--config-dir", type=Path, required=True)
    describe_parser.add_argument("--spec-name")
    describe_parser.add_argument("--type-name")
    _add_common_output_args(describe_parser, include_fields=True)

    scaffold_parser = subparsers.add_parser("scaffold", help="Scaffold schema, enum, message, config, or barrel code")
    scaffold_parser.add_argument("--config-dir", type=Path, required=True)
    scaffold_parser.add_argument("--target", required=True, choices=["schema", "enum", "message", "config", "barrel"])
    scaffold_parser.add_argument("--name", required=True)
    scaffold_parser.add_argument("--spec-name")
    scaffold_parser.add_argument("--output", type=Path)
    scaffold_parser.add_argument("--dry-run", action="store_true")
    _add_common_output_args(scaffold_parser, include_fields=True)

    audit_parser = subparsers.add_parser("audit", help="Run advisory OpenAPI schema and reference audits")
    audit_parser.add_argument("--config-dir", type=Path, required=True)
    audit_parser.add_argument("--spec-name")
    audit_parser.add_argument("--checks", default="all", choices=["schema", "reference", "all"])
    audit_parser.add_argument("--scope", default="all", choices=["matched", "unmatched", "all"])
    audit_parser.add_argument("--schema")
    audit_parser.add_argument("--include-excluded", action="store_true")
    _add_common_output_args(audit_parser, include_fields=True)

    verify_parser = subparsers.add_parser("verify", help="Run toolkit verification checks")
    verify_parser.add_argument("--config-dir", type=Path, required=True)
    verify_parser.add_argument("--spec-name")
    verify_parser.add_argument("--checks", default="all", choices=["implementation", "exports", "docs", "all"])
    verify_parser.add_argument("--scope", default="all", choices=["changed", "critical", "all", "type"])
    verify_parser.add_argument("--type-name")
    verify_parser.add_argument("--baseline", type=Path)
    verify_parser.add_argument("--git-ref")
    _add_common_output_args(verify_parser, include_fields=True)

    return parser


def _filter_payload(payload: dict[str, Any], fields: str | None) -> dict[str, Any]:
    if not fields:
        return payload
    keep = {field.strip() for field in fields.split(",") if field.strip()}
    return {key: value for key, value in payload.items() if key in keep}


def _render_text(payload: dict[str, Any]) -> str:
    lines: list[str] = []
    for key, value in payload.items():
        if isinstance(value, dict):
            lines.append(f"{key}:")
            for sub_key, sub_value in value.items():
                lines.append(f"  {sub_key}: {sub_value}")
        elif isinstance(value, list):
            lines.append(f"{key}:")
            for item in value:
                lines.append(f"  - {item}")
        else:
            lines.append(f"{key}: {value}")
    return "\n".join(lines)


def _emit(payload: dict[str, Any], output_format: str, fields: str | None) -> None:
    filtered = _filter_payload(payload, fields)
    if output_format == "json":
        print(json.dumps(filtered, indent=2, sort_keys=True))
    else:
        print(_render_text(filtered))


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    try:
        output_format = choose_format(getattr(args, "format", None))
        if args.command == "create":
            exit_code, payload = command_create(args)
        elif args.command == "fetch":
            exit_code, payload = command_fetch(args)
        elif args.command == "review":
            exit_code, payload = command_review(args)
        elif args.command == "describe":
            exit_code, payload = command_describe(args)
        elif args.command == "scaffold":
            exit_code, payload = command_scaffold(args)
        elif args.command == "audit":
            exit_code, payload = command_audit(args)
        elif args.command == "verify":
            exit_code, payload = command_verify(args)
        else:  # pragma: no cover - argparse prevents this
            raise ToolkitError(f"Unknown command '{args.command}'")
        _emit(payload, output_format, getattr(args, "fields", None))
        return exit_code
    except ToolkitError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return exc.exit_code
    except Exception as exc:  # pragma: no cover - safety net
        print(f"ERROR: {exc}", file=sys.stderr)
        return EXIT_FAILURE


if __name__ == "__main__":  # pragma: no cover
    raise SystemExit(main())
