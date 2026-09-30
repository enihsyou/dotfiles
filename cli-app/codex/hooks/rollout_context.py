"""Expose the root and current-agent Codex rollout paths to the model."""

import json
import os
import sys
from collections.abc import Mapping
from pathlib import Path

SESSION_START = "SessionStart"
SUBAGENT_START = "SubagentStart"


def _read_payload() -> Mapping[str, object]:
    payload = json.load(sys.stdin)
    if not isinstance(payload, Mapping):
        raise TypeError("Codex hook input must be a JSON object")
    return payload


def _text(payload: Mapping[str, object], field: str) -> str | None:
    value = payload.get(field)
    if isinstance(value, str) and value.strip():
        return value.strip()
    return None


def _codex_home() -> Path:
    configured_home = os.environ.get("CODEX_HOME")
    if configured_home:
        return Path(configured_home).expanduser()
    return Path.home() / ".codex"


def _transcript_path(payload: Mapping[str, object]) -> Path | None:
    value = _text(payload, "transcript_path")
    if value is None:
        return None

    path = Path(value).expanduser()
    if path.is_absolute():
        return path

    working_directory = _text(payload, "cwd")
    base = Path(working_directory) if working_directory else Path.cwd()
    return base / path


def _matching_rollouts(directory: Path, session_id: str) -> list[Path]:
    if not directory.is_dir():
        return []

    suffix = f"-{session_id}.jsonl"
    return [
        path
        for path in directory.glob("rollout-*.jsonl")
        if path.is_file() and path.name.endswith(suffix)
    ]


def _find_root_rollout(
    sessions_directory: Path,
    session_id: str | None,
    current_rollout: Path | None,
) -> Path | None:
    if session_id is None:
        return None

    if current_rollout is not None and current_rollout.name.endswith(
        f"-{session_id}.jsonl"
    ):
        return current_rollout

    if current_rollout is not None:
        same_day_matches = _matching_rollouts(current_rollout.parent, session_id)
        if same_day_matches:
            return max(same_day_matches, key=lambda path: path.stat().st_mtime_ns)

    matches = [
        path
        for path in sessions_directory.rglob("rollout-*.jsonl")
        if path.is_file() and path.name.endswith(f"-{session_id}.jsonl")
    ] if sessions_directory.is_dir() else []
    if not matches:
        return None
    return max(matches, key=lambda path: path.stat().st_mtime_ns)


def _display_path(path: Path | None, missing: str) -> str:
    return f"`{path}`" if path is not None else missing


def _format_context(payload: Mapping[str, object], codex_home: Path) -> str:
    event_name = _text(payload, "hook_event_name")
    model = _text(payload, "model") or "unavailable"
    session_id = _text(payload, "session_id")
    current_rollout = _transcript_path(payload)
    sessions_directory = codex_home / "sessions"
    root_rollout = _find_root_rollout(
        sessions_directory,
        session_id,
        current_rollout,
    )
    if event_name == SESSION_START and root_rollout is None:
        root_rollout = current_rollout

    if event_name == SESSION_START:
        return "\n".join(
            [
                "Root/current rollout: "
                + _display_path(
                    root_rollout,
                    f"not found under `{sessions_directory}`",
                ),
                f"Model: `{model}`",
            ]
        )

    return "\n".join(
        [
            "Root rollout: "
            + _display_path(
                root_rollout,
                f"not found under `{sessions_directory}`",
            ),
            "Current rollout: "
            + _display_path(current_rollout, "not provided by the hook"),
            f"Model: `{model}`",
        ]
    )


def main() -> int:
    payload = _read_payload()
    event_name = _text(payload, "hook_event_name")
    if event_name not in {SESSION_START, SUBAGENT_START}:
        return 0

    result = {
        "hookSpecificOutput": {
            "hookEventName": event_name,
            "additionalContext": _format_context(payload, _codex_home()),
        }
    }
    json.dump(result, sys.stdout, ensure_ascii=False)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
