#!/usr/bin/env python3
"""Push to GitHub using a short-lived Arapacati installation token."""

import argparse
import base64
import os
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlsplit


def github_https_url(url: str) -> str:
    if url.startswith("git@github.com:"):
        path = url.removeprefix("git@github.com:")
    else:
        parsed = urlsplit(url)
        if (
            parsed.scheme not in {"https", "ssh"}
            or parsed.hostname != "github.com"
            or parsed.password
            or parsed.port is not None
            or parsed.query
            or parsed.fragment
        ):
            raise ValueError("remote must use a GitHub HTTPS or SSH URL")
        path = parsed.path.lstrip("/")
    if not re.fullmatch(r"[\w.-]+/[\w.-]+/?", path, flags=re.ASCII):
        raise ValueError("remote must identify a GitHub owner/repository")
    return f"https://github.com/{path}"


def get_token() -> str:
    script = Path.home() / ".agents/skills/gh-apps/scripts/gh-apps.py"
    if not script.is_file():
        raise ValueError(f"token script not found: {script}")
    result = subprocess.run(
        [sys.executable, str(script), "--app", "arapacati", "token"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode:
        raise ValueError("could not obtain an Arapacati installation token; check gh-apps configuration")
    token = result.stdout.strip()
    if not token or any(character.isspace() for character in token):
        raise ValueError("gh-apps returned an invalid token")
    return token


def push(args: argparse.Namespace) -> int:
    if not re.fullmatch(r"[\w.-]+", args.remote, flags=re.ASCII) or args.remote.startswith("-"):
        raise ValueError("provide a configured remote name")
    remote = subprocess.run(
        ["git", "remote", "get-url", "--push", "--all", args.remote],
        cwd=args.repo,
        capture_output=True,
        text=True,
        check=False,
    )
    if remote.returncode:
        raise ValueError(remote.stderr.strip() or "could not resolve push remote")
    urls = remote.stdout.splitlines()
    if len(urls) != 1:
        raise ValueError("remote must have exactly one push URL")
    url = github_https_url(urls[0])
    token = get_token()
    encoded = base64.b64encode(f"x-access-token:{token}".encode()).decode()
    env = {key: value for key, value in os.environ.items() if not key.startswith("GIT_TRACE")}
    env.pop("GIT_CURL_VERBOSE", None)
    env.update(GIT_TERMINAL_PROMPT="0", AI_PUSH_AUTH=f"Authorization: Basic {encoded}")
    command = [
        "git", "-c", "credential.helper=",
        "-c", "http.extraHeader=",
        "-c", "http.https://github.com/.extraHeader=",
        "--config-env=http.https://github.com/.extraHeader=AI_PUSH_AUTH",
        "-c", f"url.{url}.insteadOf={urls[0]}",
        "push", "--no-recurse-submodules",
    ]
    if args.set_upstream:
        command.append("--set-upstream")
    if args.force_with_lease:
        command.append("--force-with-lease")
    command.extend(["--", args.remote, *(args.refspecs or ["HEAD"])])
    return subprocess.run(command, cwd=args.repo, env=env, check=False).returncode


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", default=".", help="repository directory (default: current directory)")
    parser.add_argument("--set-upstream", "-u", action="store_true")
    parser.add_argument("--force-with-lease", action="store_true")
    parser.add_argument("remote", nargs="?", default="origin")
    parser.add_argument("refspecs", nargs="*")
    args = parser.parse_args()
    try:
        return push(args)
    except (OSError, ValueError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
