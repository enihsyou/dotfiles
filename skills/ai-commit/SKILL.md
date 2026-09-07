---
name: ai-commit
description: Create a Git commit as an AI assistant using the Arapacati identity and the real user as co-author.
---

# AI Commit

Create the requested commit only. Do not push unless the user explicitly asks.

## Identity

- Author email: `292837902+arapacati[bot]@users.noreply.github.com`
- Author name: `<Model Name> - <Harness Name>`
- Co-author: the repository's `git config user.name` and `git config user.email`
- Always pass `--no-gpg-sign`

Normalize the model name by removing host suffixes such as `[1m]` or
`(latest)`. Convert known dashed model IDs to their display names, for example
`gpt-5.6-luna` to `GPT-5.6 Luna`. Do not invent extra identity text.

## Minimal workflow

For a straightforward commit, use at most three command invocations:

1. **Preflight:** in one invocation, read `git status --short`, the relevant
   diff, and `git config user.name` / `git config user.email`. Determine the
   commit message from the diff unless the user supplied one.
2. **Commit:** stage only when the request includes unstaged paths that must be
   committed, then commit. Staging and committing may share one invocation once
   the exact path scope is known. If the user asks to commit the current staged
   changes, do not run `git add`.
3. **Result:** in one invocation, read the new commit's hash, subject, author,
   trailer, committed path list, and current short status. Report these
   concisely.

Do not split independent read-only Git queries into separate tool calls. Do not
repeat the same status, diff, path list, or metadata check unless an earlier
command failed or changed the relevant state.

## Scope and safety

- Preserve unrelated worktree and staged changes.
- Before committing, inspect the actual content being committed, not only file
  names.
- If the requested scope and the staged scope differ, resolve that mismatch
  before committing. Use pathspecs for an explicit file set.
- Run `git diff --cached --check` when staging files or when whitespace risk is
  apparent. It is optional for an already-staged, clearly scoped, low-risk
  commit.
- Do not run `git commit -h` to discover `--trailer`; it is a supported option.
- Add extra diagnostics only after a failure or when scope, identity, or message
  is ambiguous.

## Commit command

Use explicit resolved values rather than shell substitution in the final
command:

```bash
git commit --author="GPT-5.6 Luna - Codex <292837902+arapacati[bot]@users.noreply.github.com>" --no-gpg-sign --trailer="Co-Authored-By: User Name <user@example.com>" -m "Commit subject"
```

## Response style

Keep progress narration to one short preflight update and, if useful, one short
pre-commit update. The final response normally needs only the commit hash,
subject, committed scope, and whether it was pushed. Mention exceptional
conditions only when they occurred.
