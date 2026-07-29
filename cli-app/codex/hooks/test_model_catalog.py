"""Tests for parsing and resolving the models.dev catalog."""

from __future__ import annotations

import unittest
from unittest.mock import patch

import model_catalog


class ModelCatalogTests(unittest.TestCase):
    """Verify catalog parsing and fallback precedence without network access."""

    def test_parse_catalog_uses_slug_after_provider_prefix(self) -> None:
        """Provider prefixes should not become part of the model slug."""
        raw = '{"openai/demo-model": {"name": "Demo Model"}}'
        self.assertEqual(model_catalog._parse_catalog(raw), {"demo-model": "Demo Model"})

    def test_conflicting_duplicate_slug_invalidates_catalog(self) -> None:
        """Conflicting names for one slug should reject the entire catalog."""
        raw = (
            '{"openai/demo": {"name": "First"}, '
            '"other/demo": {"name": "Second"}}'
        )
        self.assertIsNone(model_catalog._parse_catalog(raw))

    def test_fallback_order_is_online_then_hardcoded_then_raw(self) -> None:
        """Online names win, followed by the static map and finally the slug."""
        with patch.object(
            model_catalog,
            "_load_online_model_names",
            return_value={"gpt-5.6-sol": "Online Sol"},
        ):
            self.assertEqual(model_catalog.model_brand_name("gpt-5.6-sol"), "Online Sol")

        with patch.object(model_catalog, "_load_online_model_names", return_value={}):
            self.assertEqual(model_catalog.model_brand_name("gpt-5.6-sol"), "GPT-5.6 Sol")
            self.assertEqual(model_catalog.model_brand_name("unknown"), "unknown")


if __name__ == "__main__":
    unittest.main()
