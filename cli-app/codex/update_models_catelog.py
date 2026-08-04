#!/usr/bin/env python3
"""Build Codex's local model catalog with precise model identities."""

from __future__ import annotations

import json
import re
import shutil
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import model_catalog
import tomllib

CODEX_HOME = Path.home() / ".codex"
SOURCE_CATALOG = CODEX_HOME / "models_cache.json"
TARGET_CATALOG = CODEX_HOME / "models_better.json"
CONFIG_PATH = CODEX_HOME / "config.toml"
IDENTITY_PATTERN = re.compile(
    r"^(You are Codex, (?:an |a coding )?agent based on )GPT-5(?:\.\d+(?:-\w+)*)?\."
)


def backup(path: Path, timestamp: str) -> Path | None:
    """Copy an existing target aside before the script replaces it."""
    if not path.exists():
        return None
    backup_path = path.with_name(f"{path.name}.{timestamp}.bak")
    shutil.copy2(path, backup_path)
    return backup_path


def load_catalog(path: Path) -> dict[str, Any]:
    """Load the upstream cache and validate the model list shape."""
    with path.open(encoding="utf-8") as file:
        catalog = json.load(file)
    if not isinstance(catalog, dict) or not isinstance(catalog.get("models"), list):
        raise TypeError(f"{path} does not contain a models list")
    return catalog


def update_instruction(slug: str, instruction: str) -> str:
    """Replace one generic Codex identity line with the readable model name."""
    replacement = rf"\1{model_catalog.model_brand_name(slug)}."
    updated, count = IDENTITY_PATTERN.subn(replacement, instruction, count=1)
    if count != 1:
        raise ValueError(f"{slug}: expected one generic Codex identity line, found {count}")
    return updated


def update_identity(model: dict[str, Any]) -> None:
    """Replace generic identities in both model instruction fields."""
    slug = model.get("slug")
    base_instructions = model.get("base_instructions")
    model_messages = model.get("model_messages")
    if not isinstance(slug, str) or not isinstance(base_instructions, str):
        raise TypeError("each model needs string slug and base_instructions fields")
    if not isinstance(model_messages, dict):
        raise TypeError("each model needs an object model_messages field")
    template = model_messages.get("instructions_template")
    if not isinstance(template, str):
        raise TypeError("each model needs string model_messages.instructions_template")
    model["base_instructions"] = update_instruction(slug, base_instructions)
    model_messages["instructions_template"] = update_instruction(slug, template)
    if slug == "gpt-5.6-luna":
        model["multi_agent_version"] = "v2"


def build_catalog(catalog: dict[str, Any]) -> dict[str, Any]:
    """Apply model identities and Luna's multi-agent-version change."""
    for model in catalog["models"]:
        if not isinstance(model, dict):
            raise TypeError("models list contains a non-object entry")
        update_identity(model)
    return catalog


def set_root_string_key(content: str, key: str, value: str) -> str:
    """Set one root TOML string key while preserving all tables and comments."""
    lines = content.splitlines(keepends=True)
    root_end = next(
        (index for index, line in enumerate(lines) if line.lstrip().startswith("[")),
        len(lines),
    )
    new_line = f'{key} = "{value}"\n'
    for index, line in enumerate(lines[:root_end]):
        name, separator, _ = line.partition("=")
        if separator and name.strip() == key:
            lines[index] = new_line
            return "".join(lines)
    lines.insert(root_end, new_line)
    return "".join(lines)


def update_config() -> None:
    """Validate the TOML and set model_catalog_json without changing hook blocks."""
    content = CONFIG_PATH.read_text(encoding="utf-8")
    tomllib.loads(content)
    updated = set_root_string_key(content, "model_catalog_json", TARGET_CATALOG.as_posix())
    tomllib.loads(updated)
    CONFIG_PATH.write_text(updated, encoding="utf-8", newline="\n")


def show_catalog_diff() -> None:
    """Display the source and generated model-catalog difference with delta."""
    try:
        subprocess.run(["delta", str(SOURCE_CATALOG), str(TARGET_CATALOG)], check=False)
    except OSError as error:
        print(f"Unable to run delta: {error}")


def main() -> int:
    """Back up replaceable files, then write the catalog and its Codex setting."""
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    catalog = build_catalog(load_catalog(SOURCE_CATALOG))
    catalog_backup = backup(TARGET_CATALOG, timestamp)
    config_backup = backup(CONFIG_PATH, timestamp)
    TARGET_CATALOG.write_text(
        json.dumps(catalog, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    update_config()
    for item in (catalog_backup, config_backup):
        if item is not None:
            print(f"Backed up {item}")
    print(f"Wrote {TARGET_CATALOG}")
    print(f"Updated {CONFIG_PATH}")
    show_catalog_diff()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
