#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path


def _bootstrap_import_path() -> None:
    script_dir = Path(__file__).resolve().parent
    toolkit_root = script_dir.parent
    if str(toolkit_root) not in sys.path:
        sys.path.insert(0, str(toolkit_root))


_bootstrap_import_path()

from api_toolkit.cli import main  # noqa: E402


if __name__ == "__main__":
    raise SystemExit(main())
