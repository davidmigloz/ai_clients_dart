from __future__ import annotations

import sys
import unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from api_toolkit.cli import main
from api_toolkit.config import EXIT_FAILURE, ToolkitError


class CliTests(unittest.TestCase):
    def test_main_routes_generate_llms_txt_command(self) -> None:
        with patch("api_toolkit.cli.command_generate_llms_txt", return_value=(0, {"command": "generate-llms-txt"})):
            exit_code = main(["generate-llms-txt", "--repo-root", "/tmp"])

        self.assertEqual(exit_code, 0)

    def test_main_routes_audit_command(self) -> None:
        with patch("api_toolkit.cli.command_audit", return_value=(0, {"command": "audit"})):
            exit_code = main(["audit", "--config-dir", "/tmp"])

        self.assertEqual(exit_code, 0)

    def test_main_returns_exit_failure_for_unexpected_exceptions(self) -> None:
        with patch("api_toolkit.cli.command_describe", side_effect=RuntimeError("boom")):
            exit_code = main(["describe", "--config-dir", "/tmp"])

        self.assertEqual(exit_code, EXIT_FAILURE)

    def test_main_returns_toolkit_error_exit_code(self) -> None:
        with patch("api_toolkit.cli.command_describe", side_effect=ToolkitError("bad config", exit_code=7)):
            exit_code = main(["describe", "--config-dir", "/tmp"])

        self.assertEqual(exit_code, 7)


if __name__ == "__main__":
    unittest.main()
