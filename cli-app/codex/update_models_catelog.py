#!/usr/bin/env python3
"""Add precise model identities to Codex's cached system prompts."""

from __future__ import annotations

import json
import re
import shutil
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import model_catalog

CODEX_HOME = Path.home() / ".codex"
MODEL_CACHE = CODEX_HOME / "models_cache.json"
IDENTITY_PATTERN = re.compile(
    r"^(You are Codex, .+?based on )GPT(?:[-\.\d]+)?\."
)


def backup(path: Path, timestamp: str) -> Path | None:
    """Copy an existing target aside before the script replaces it."""
    if not path.exists():
        return None
    backup_path = path.with_name(f"{path.name}.{timestamp}.bak")
    shutil.copy2(path, backup_path)
    return backup_path


def load_catalog(path: Path) -> dict[str, Any]:
    """Load the upstream cache and validate its top-level object shape."""
    with path.open(encoding="utf-8") as file:
        catalog = json.load(file)
    if not isinstance(catalog, dict):
        raise TypeError(f"{path} does not contain a catalog object")
    return catalog


def update_instruction(slug: str, instruction: str) -> str:
    """Replace one generic Codex identity line with the readable model name."""
    replacement = rf"\1{model_catalog.model_brand_name(slug)}."
    updated, count = IDENTITY_PATTERN.subn(replacement, instruction, count=1)
    if count != 1:
        raise ValueError(f"{slug}: expected one generic Codex identity line, found {count}")
    return updated


def update_identity(model: dict[str, Any]) -> None:
    """Replace the generic identity in the model message instruction template."""
    slug = model.get("slug")
    if not isinstance(slug, str):
        raise TypeError("each model needs a string slug field")
    if slug in ("gpt-reserve",):
        return
    model_messages = model.get("model_messages")
    if not isinstance(model_messages, dict):
        raise TypeError("each model needs an object model_messages field")
    template = model_messages.get("instructions_template")
    if not isinstance(template, str):
        raise TypeError("each model needs string model_messages.instructions_template")
    model_messages["instructions_template"] = update_instruction(slug, template)


def build_catalog(catalog: dict[str, Any]) -> dict[str, Any]:
    """Add each model's identity to its system prompt."""
    models = catalog.get("models")
    if not isinstance(models, list):
        raise TypeError("catalog does not contain a models list")
    for model in models:
        if not isinstance(model, dict):
            raise TypeError("models list contains a non-object entry")
        update_identity(model)
    return catalog


def main() -> int:
    """Back up the model cache, then update it in place."""
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    catalog = build_catalog(load_catalog(MODEL_CACHE))
    cache_backup = backup(MODEL_CACHE, timestamp)
    MODEL_CACHE.write_text(
        json.dumps(catalog, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    if cache_backup is not None:
        print(f"Backed up {cache_backup}")
    print(f"Updated {MODEL_CACHE}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
