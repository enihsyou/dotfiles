---
name: ai-push
description: Push Git commits to a GitHub remote with the Arapacati installation token. Use only when the user explicitly asks an AI assistant to perform git push.
---

# AI Agent Git Push

Only push when the user explicitly asks for it. Run the bundled script from the repository directory instead of assembling authentication or Git commands:

```bash
python <skill_base_dir>/scripts/git-push.py origin HEAD
```

`<skill_base_dir>` normally resolves to `~/.agents/skills/ai-push`. Use `--repo PATH` to select another repository. The first positional argument is the remote name (default: `origin`); remaining positional arguments are refspecs (default: `HEAD`). Add `--set-upstream` or `--force-with-lease` only when appropriate for the authorized push.

The script obtains an Arapacati token through `~/.agents/skills/gh-apps/scripts/gh-apps.py`, supplies temporary HTTPS authentication, disables credential helpers and prompts, and skips submodules. It accepts GitHub HTTPS and SSH remotes without changing repository configuration. Do not obtain, print, or embed the token yourself. If the script fails, report the failure and stop rather than retrying with another identity.
