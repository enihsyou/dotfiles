"""Tests for the SessionStart model-name injection hook."""

from __future__ import annotations

import io
import json
import sys
import unittest
from contextlib import redirect_stdout
from typing import Any
from unittest.mock import patch

import inject_model_name
import model_catalog


class InjectModelNameHookTests(unittest.TestCase):
    """Verify model validation, branding, and hook output shape."""

    def setUp(self) -> None:
        """Keep hook tests offline and provide a deterministic catalog fallback."""
        self.online_catalog = patch.object(
            model_catalog,
            "_load_online_model_names",
            return_value={},
        )
        self.online_catalog.start()
        self.addCleanup(self.online_catalog.stop)

    def _run_hook(self, payload: object) -> dict[str, Any]:
        """Run the hook with JSON input and return its JSON response."""
        stdin = io.StringIO(json.dumps(payload))
        stdout = io.StringIO()
        with redirect_stdout(stdout), patch.object(sys, "stdin", stdin):
            exit_code = inject_model_name.main()
        self.assertEqual(exit_code, 0)
        return json.loads(stdout.getvalue())

    def test_known_slug_uses_brand_name_and_keeps_slug(self) -> None:
        """Known GPT slugs should produce a readable brand and raw slug."""
        response = self._run_hook({"model": "gpt-5.6-sol"})
        context = response["hookSpecificOutput"]["additionalContext"]
        self.assertEqual(
            context,
            "The active model is GPT-5.6 Sol (slug: gpt-5.6-sol).",
        )

    def test_unknown_slug_is_preserved(self) -> None:
        """Unknown model identifiers should remain usable without a mapping."""
        response = self._run_hook({"model": "custom-model"})
        context = response["hookSpecificOutput"]["additionalContext"]
        self.assertEqual(context, "The active model is custom-model (slug: custom-model).")

    def test_online_catalog_name_has_priority(self) -> None:
        """A valid online catalog entry should override the hardcoded mapping."""
        with patch.object(
            model_catalog,
            "_load_online_model_names",
            return_value={"gpt-5.6-sol": "Online Sol"},
        ):
            response = self._run_hook({"model": "gpt-5.6-sol"})
        context = response["hookSpecificOutput"]["additionalContext"]
        self.assertEqual(context, "The active model is Online Sol (slug: gpt-5.6-sol).")

    def test_invalid_payload_has_no_context(self) -> None:
        """Malformed model values should not be injected into the context."""
        response = self._run_hook({"model": "invalid\nmodel"})
        self.assertEqual(
            response,
            {"hookSpecificOutput": {"hookEventName": "SessionStart"}},
        )


if __name__ == "__main__":
    unittest.main()
