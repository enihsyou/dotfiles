---
name: ai-commit
description: Git commit with proper attribution using GitHub App Arapacati. Use when creating commits as an AI assistant.
---

# AI Agent Git Commit

Commit code using GitHub App **Arapacati** identity with proper attribution.

## App Details

| Field | Value |
|---|---|
| App Name | Arapacati |
| App ID | 4029389 |
| App Email | `292837902+arapacati[bot]@users.noreply.github.com` |

## Steps

### 1. Set Author Identity

| Field | Value |
|-------|-------|
| user.name | `<Model Name> - <Harness Name>` |
| user.email | `<bot_user_id>+<bot_name>[bot]@users.noreply.github.com` |

user.name use the actual model and harness tool in use, for examples:
- `MiMo V2.5 - Claude Code`
- `Claude Opus 4.8 - OpenCode`
- `GPT-4o - Cursor`
- `Gemini 2.5 Pro - Windsurf`

### 2. Add Co-Author Trailer

Append the real user as co-author:

```bash
--trailer "Co-Authored-By: $(git config user.name) <$(git config user.email)>"
```

### 3. Skip GPG Sign

pass `--no-gpg-sign` to disable GPG signing, as the bot won't have access to the user's GPG keys.

## Full Command Example

```bash
git -c user.name="MiMo V2.5 - Claude Code" -c user.email="292837902+arapacati[bot]@users.noreply.github.com" --trailer "Co-Authored-By: 九条涼果 <enihsyou@gmail.com>" commit --no-gpg-sign -m "Your commit message here"
```
