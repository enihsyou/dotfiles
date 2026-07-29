"""Resolve readable model names from the online models.dev catalog."""

from __future__ import annotations

import json
import tempfile
import time
import urllib.request
from collections.abc import Mapping
from pathlib import Path

CATALOG_URL = "https://models.dev/models.json"
CATALOG_TTL_SECONDS = 7 * 24 * 60 * 60
DOWNLOAD_TIMEOUT_SECONDS = 3

MODEL_BRAND_NAMES = {
    "gpt-4": "GPT-4",
    "gpt-4o": "GPT-4o",
    "gpt-4o-mini": "GPT-4o Mini",
    "gpt-4.1": "GPT-4.1",
    "gpt-4.1-mini": "GPT-4.1 Mini",
    "gpt-4.1-nano": "GPT-4.1 Nano",
    "gpt-4.5": "GPT-4.5",
    "gpt-5": "GPT-5",
    "gpt-5-mini": "GPT-5 Mini",
    "gpt-5-nano": "GPT-5 Nano",
    "gpt-5.1": "GPT-5.1",
    "gpt-5.1-codex": "GPT-5.1 Codex",
    "gpt-5.2": "GPT-5.2",
    "gpt-5.2-codex": "GPT-5.2 Codex",
    "gpt-5.3-codex": "GPT-5.3 Codex",
    "gpt-5.4": "GPT-5.4",
    "gpt-5.4-codex": "GPT-5.4 Codex",
    "gpt-5.6-luna": "GPT-5.6 Luna",
    "gpt-5.6-sol": "GPT-5.6 Sol",
    "gpt-5.6-terra": "GPT-5.6 Terra",
}


def _cache_path() -> Path:
    """Return the persistent cache path in the system temporary directory."""
    return Path(tempfile.gettempdir()) / "codex-models.dev-models.json"


def _parse_catalog(raw: str) -> dict[str, str] | None:
    """Extract unique slugs and display names from a models.dev response."""
    try:
        catalog = json.loads(raw)
    except (json.JSONDecodeError, TypeError, ValueError):
        return None
    if not isinstance(catalog, Mapping):
        return None

    names: dict[str, str] = {}
    for model_id, details in catalog.items():
        if not isinstance(model_id, str) or "/" not in model_id:
            continue
        slug = model_id.rsplit("/", 1)[1].strip().casefold()
        name = details.get("name") if isinstance(details, Mapping) else None
        if not slug or not isinstance(name, str) or not name.strip():
            continue
        display_name = name.strip()
        previous_name = names.get(slug)
        if previous_name is not None and previous_name != display_name:
            return None
        names[slug] = display_name
    return names


def _read_cached_model_names() -> dict[str, str] | None:
    """Read a catalog only when its seven-day cache entry is still valid."""
    path = _cache_path()
    try:
        if time.time() - path.stat().st_mtime >= CATALOG_TTL_SECONDS:
            return None
        return _parse_catalog(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError):
        return None


def _download_model_names() -> dict[str, str] | None:
    """Download and cache the catalog, returning None for any network failure."""
    try:
        req = urllib.request.Request(CATALOG_URL, headers={"User-Agent": "codex"})
        with urllib.request.urlopen(req, timeout=DOWNLOAD_TIMEOUT_SECONDS) as response:
            raw = response.read().decode("utf-8")
        names = _parse_catalog(raw)
        if names is None:
            return None
        try:
            _cache_path().write_text(raw, encoding="utf-8")
        except OSError:
            pass
        return names
    except (OSError, UnicodeError, ValueError):
        return None


def _load_online_model_names() -> dict[str, str] | None:
    """Use the valid cache first, then refresh it from models.dev."""
    cached_names = _read_cached_model_names()
    return cached_names if cached_names is not None else _download_model_names()


def model_brand_name(model: str) -> str:
    """Resolve a slug through online, hardcoded, and raw-name fallbacks."""
    online_names = _load_online_model_names()
    return (online_names or {}).get(model.casefold()) or MODEL_BRAND_NAMES.get(
        model.casefold(), model
    )
