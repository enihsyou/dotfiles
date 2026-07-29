#!/usr/bin/env python3
"""SessionStart hook: inject the active Codex model slug into context."""

from __future__ import annotations

import json
import sys
from collections.abc import Mapping
from typing import Any

_MAX_MODEL_LEN = 256
_MODEL_BRAND_NAMES = {
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
}


def _read_stdin() -> str:
    """Read the complete hook input from stdin."""
    try:
        return sys.stdin.read()
    except (OSError, UnicodeError):
        return ""


def _parse_payload(raw: str) -> Mapping[str, Any] | None:
    """Parse a JSON object from hook input."""
    if not raw.strip():
        return None
    try:
        payload = json.loads(raw)
    except (json.JSONDecodeError, ValueError):
        return None
    return payload if isinstance(payload, Mapping) else None


def _extract_model(payload: Mapping[str, Any]) -> str | None:
    """Return a safe, non-empty model slug."""
    model = payload.get("model")
    if not isinstance(model, str):
        return None
    model = model.strip()
    if not model or len(model) > _MAX_MODEL_LEN:
        return None
    if any(ord(character) < 0x20 or ord(character) == 0x7F for character in model):
        return None
    return model


def _model_brand_name(model: str) -> str:
    """Convert a model slug to its stable brand name when known."""
    return _MODEL_BRAND_NAMES.get(model.casefold(), model)


def _emit(output: Mapping[str, Any]) -> None:
    """Write one hook result as JSON."""
    sys.stdout.write(json.dumps(output, ensure_ascii=False))


def main() -> int:
    payload = _parse_payload(_read_stdin())
    model = _extract_model(payload) if payload is not None else None
    hook_output: dict[str, Any] = {"hookEventName": "SessionStart"}
    if model is not None:
        hook_output["additionalContext"] = (
            f"The active model is {_model_brand_name(model)} (slug: {model})."
        )
    _emit({"hookSpecificOutput": hook_output})
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
