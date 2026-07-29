#!/usr/bin/env python3
"""PreToolUse hook: prevent commits attributed to a different Codex model."""

from __future__ import annotations

import argparse
import json
import re
import shlex
import sys
from collections.abc import Iterator, Mapping
from typing import Any, NoReturn

_BOT_EMAIL_RE = re.compile(r"(?i)^.*\[bot\]@users\.noreply\.github\.com$")


class _ArgumentParser(argparse.ArgumentParser):
    """Argument parser that treats malformed shell fragments as non-matches."""

    def error(self, message: str) -> NoReturn:
        raise ValueError(message)


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


def _extract_command(payload: Mapping[str, Any]) -> str | None:
    """Return a Bash command from a PreToolUse payload."""
    if payload.get("tool_name") != "Bash":
        return None
    tool_input = payload.get("tool_input")
    if not isinstance(tool_input, Mapping):
        return None
    command = tool_input.get("command")
    return command if isinstance(command, str) else None


def _extract_model(payload: Mapping[str, Any]) -> str | None:
    """Return the active model slug from hook input."""
    model = payload.get("model")
    if not isinstance(model, str) or not model.strip():
        return None
    return model.strip()


def _split_commands(command: str) -> Iterator[str]:
    """Split pipe and semicolon command lists without splitting quoted text."""
    quote: str | None = None
    escaped = False
    start = 0
    for index, character in enumerate(command):
        if escaped:
            escaped = False
            continue
        if character == "\\" and quote is not None:
            escaped = True
            continue
        if character in {'"', "'"}:
            quote = None if quote == character else character if quote is None else quote
            continue
        if quote is None and character in {"|", ";"}:
            segment = command[start:index].strip()
            if segment:
                yield segment
            start = index + 1
    segment = command[start:].strip()
    if segment:
        yield segment


def _parse_git_segment(segment: str) -> tuple[list[str], list[str]] | None:
    """Parse a Git segment into global config values and remaining arguments."""
    try:
        arguments = shlex.split(segment, posix=True)
    except ValueError:
        return None
    if not arguments or arguments[0].lower() not in {"git", "git.exe"}:
        return None

    parser = _ArgumentParser(add_help=False, allow_abbrev=False)
    parser.add_argument("-c", dest="config", action="append", default=[])
    try:
        namespace, remaining = parser.parse_known_args(arguments[1:])
    except ValueError:
        return None
    return namespace.config, remaining


def _extract_git_identity(command: str) -> tuple[str, str] | None:
    """Return identity overrides from a single bot-attributed Git commit."""
    for segment in _split_commands(command):
        parsed = _parse_git_segment(segment)
        if parsed is None:
            continue
        config_arguments, remaining = parsed
        if "commit" not in remaining:
            continue

        config = _parse_git_config(config_arguments)
        name = config.get("user.name")
        email = config.get("user.email")
        if name is not None and email is not None and _BOT_EMAIL_RE.fullmatch(email):
            return name, email
    return None


def _parse_git_config(arguments: list[str]) -> dict[str, str]:
    """Convert Git -c key=value arguments into a case-insensitive mapping."""
    config: dict[str, str] = {}
    for argument in arguments:
        key, separator, value = argument.partition("=")
        if separator:
            config[key.casefold()] = value
    return config


def _attributed_model(user_name: str) -> str | None:
    """Return the model portion of '<model> - <harness>'."""
    model, separator, harness = user_name.rpartition(" - ")
    if not separator or not model.strip() or not harness.strip():
        return None
    return model.strip()


def _normalize_model(value: str) -> str:
    """Normalize display names and model slugs for comparison."""
    return "".join(character.casefold() for character in value if character.isalnum())


def _emit(output: Mapping[str, Any]) -> None:
    """Write one hook result as JSON."""
    sys.stdout.write(json.dumps(output, ensure_ascii=False))


def _deny(reason: str) -> None:
    """Emit the documented PreToolUse denial shape."""
    _emit({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    })


def main() -> int:
    payload = _parse_payload(_read_stdin())
    if payload is None:
        return 0

    command = _extract_command(payload)
    identity = _extract_git_identity(command) if command is not None else None
    if identity is None:
        return 0

    actual_model = _extract_model(payload)
    if actual_model is None:
        _deny("Commit denied: the current model name is unavailable in the hook input.")
        return 0

    claimed_model = _attributed_model(identity[0])
    if claimed_model is None or _normalize_model(claimed_model) != _normalize_model(actual_model):
        _deny(
            f"Commit denied: the current model is {actual_model}; "
            f"user.name claims {claimed_model or identity[0]}."
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
