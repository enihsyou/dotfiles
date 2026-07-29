#!/usr/bin/env python3
"""SessionStart hook: inject the active Codex model slug into context."""

from __future__ import annotations

import json
import sys
from collections.abc import Mapping
from typing import Any

_MAX_MODEL_LEN = 256


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


def _emit(output: Mapping[str, Any]) -> None:
    """Write one hook result as JSON."""
    sys.stdout.write(json.dumps(output, ensure_ascii=False))


def main() -> int:
    payload = _parse_payload(_read_stdin())
    model = _extract_model(payload) if payload is not None else None
    hook_output: dict[str, Any] = {"hookEventName": "SessionStart"}
    if model is not None:
        hook_output["additionalContext"] = f"The active model is {model}."
    _emit({"hookSpecificOutput": hook_output})
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
