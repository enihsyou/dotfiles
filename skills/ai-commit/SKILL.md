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

Normalize the model name by removing suffixes such as `[1m]` or
`(latest)`. Convert known dashed model IDs to their display names, including
`gpt-5.6-luna` to `GPT-5.6 Luna` and `gpt-6-luna` to `GPT-6 Luna`. Do not
invent extra identity text.

### Codex model discovery

Commit attribution always uses the main/root agent's model, even when a
subagent performs the commit. The hook's `Model` value describes the current
agent: it is the main model in the root agent and the subagent model in a
subagent.

Resolve the author model using this decision flow:

```text
model = missing
rollout = missing

if context contains Root/current rollout:
    current_agent = main
else if context contains both Root rollout and Current rollout:
    current_agent = subagent
else:
    current_agent = unknown

if current_agent is main:
    model = injected Model, unless it is "unavailable"
    rollout = injected Root/current rollout
else if current_agent is subagent:
    ignore injected Model  # it identifies the subagent's model
    rollout = injected Root rollout
    model = last_turn_context(rollout).model, if available

if model is missing:
    if rollout is missing or unusable:
        session_id = final directory name of the writable visualization path
                     ~/.codex/visualizations/YYYY/MM/DD/<session-id>
        rollout = locate rollout-*-<session_id>.jsonl under ~/.codex/sessions
        if not found, search ~/.codex/session_index.jsonl and ~/.codex/sessions
    model = last_turn_context(rollout).model, if available

if model is still missing:
    make no more tool calls solely to identify it
    use the best author model guess from existing context
    disclose in the final response that author information may be inaccurate
```

When reading a rollout, use the main agent's file and its final `turn_context`:

   ```bash
   jq -sr 'map(select(.type == "turn_context")) | last | .payload.model' <rollout-file>
   ```

Use the resulting model ID for the author name after applying the normalization
rules above. Prefer the final `turn_context` over `model_provider`, base
instructions, or earlier turns whenever a rollout is available.

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
git commit --author="GPT-6 Luna - Codex <292837902+arapacati[bot]@users.noreply.github.com>" --no-gpg-sign --trailer="Co-Authored-By: User Name <user@example.com>" -m "Commit subject"
```

## Response style

Keep progress narration to one short preflight update and, if useful, one short
pre-commit update. The final response normally needs only the commit hash,
subject, committed scope, and whether it was pushed. Mention exceptional
conditions only when they occurred.
