"""Tests for the PreToolUse commit-model validation hook."""

from __future__ import annotations

import io
import json
import sys
import unittest
from contextlib import redirect_stdout
from typing import Any
from unittest.mock import patch

import model_catalog
import validate_commit_model

BOT_EMAIL = "292837902+arapacati[bot]@users.noreply.github.com"


class ValidateCommitModelHookTests(unittest.TestCase):
    """Verify commit identity matching and denial behavior."""

    def setUp(self) -> None:
        """Keep hook tests offline and provide a deterministic catalog fallback."""
        self.online_catalog = patch.object(
            model_catalog,
            "_load_online_model_names",
            return_value={},
        )
        self.online_catalog.start()
        self.addCleanup(self.online_catalog.stop)

    def _run_hook(
        self,
        model: str,
        user_name: str,
        command_name: str = "commit",
    ) -> dict[str, Any] | None:
        """Run the hook and decode its optional JSON response."""
        command = (
            f'git -c user.name="{user_name}" -c user.email="{BOT_EMAIL}" {command_name} -m "test"'
        )
        payload = {
            "model": model,
            "tool_name": "Bash",
            "tool_input": {"command": command},
        }
        stdin = io.StringIO(json.dumps(payload))
        stdout = io.StringIO()
        with redirect_stdout(stdout), patch.object(sys, "stdin", stdin):
            exit_code = validate_commit_model.main()
        self.assertEqual(exit_code, 0)
        output = stdout.getvalue()
        return json.loads(output) if output else None

    def test_brand_name_matches_known_slug(self) -> None:
        """The readable brand name should match its model slug."""
        self.assertIsNone(self._run_hook("gpt-5.6-sol", "GPT-5.6 Sol - Codex"))

    def test_slug_matches_known_model(self) -> None:
        """The raw slug remains accepted for compatibility with existing commits."""
        self.assertIsNone(self._run_hook("gpt-5.6-sol", "gpt-5.6-sol - Codex"))

    def test_online_catalog_name_is_used_for_validation(self) -> None:
        """The validator should accept the display name supplied by the catalog."""
        with patch.object(
            model_catalog,
            "_load_online_model_names",
            return_value={"gpt-5.6-sol": "Online Sol"},
        ):
            self.assertIsNone(self._run_hook("gpt-5.6-sol", "Online Sol - Codex"))

    def test_mismatched_model_is_denied(self) -> None:
        """A different model in user.name should produce a denial response."""
        response = self._run_hook(
            "gpt-5.6-sol",
            "GPT-5.6 Luna - Codex",
        )
        assert response is not None
        specific_output = response["hookSpecificOutput"]
        self.assertEqual(specific_output["permissionDecision"], "deny")
        self.assertIn("GPT-5.6 Sol", specific_output["permissionDecisionReason"])

    def test_non_commit_command_is_ignored(self) -> None:
        """Bot-attributed commands other than git commit should pass through."""
        response = self._run_hook(
            "gpt-5.6-sol",
            "GPT-5.6 Luna - Codex",
            command_name="status",
        )
        self.assertIsNone(response)


if __name__ == "__main__":
    unittest.main()
