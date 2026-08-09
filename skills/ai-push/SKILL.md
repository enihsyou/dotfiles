---
name: ai-push
description: Push Git commits to a GitHub remote with the Arapacati installation token. Use only when the user explicitly asks an AI assistant to perform git push.
---

# AI Agent Git Push

Push code to a GitHub remote using the GitHub App **Arapacati** installation token.

## Authentication

Only perform this workflow when the user explicitly asks the AI Agent to run `git push` against a GitHub remote. Embed the short-lived Arapacati installation access token in the remote URL to bypass Git Credential Manager prompts that can hang on Windows.

Generate the token and run `git push` in one command using command substitution. Do not expose the token by generating it in a separate command or storing it in the shell history.

### 1. Get Installation Token

```bash
python <skill_base_dir>/../gh-apps/scripts/gh-apps.py --app arapacati token
```

Normally, `<skill_base_dir>` resolves to `~/.agents/skills/ai-push`; try the shared `gh-apps` skill path first when available.

### 2. Push with the Token

Replace `TOKEN` with the command substitution that generates the installation token:

```bash
git -c credential.helper= push https://x-access-token:TOKEN@github.com/owner/repo.git branch
```

Disable the credential helper (`-c credential.helper=`) so it cannot intercept the URL and hang on a prompt.

### 3. Skip Submodules

Pass `--no-recurse-submodules` to avoid failures from submodules (for example, a detached HEAD). Submodule state is independent of the main repository commit and normally does not need to be pushed together.
