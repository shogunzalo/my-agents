---
name: commit-strategy
description: Disciplined git commits for a bisectable history. Use when staging and
  committing work, when the user says "commit this", "clean up the history", or
  "squash before PR", or whenever you are about to write a commit message or branch
  off main.
---

# Commit strategy — small, focused, bisectable

Puts the commit & branch section of [standards/dev-flow.md](../../../standards/dev-flow.md)
and the git-safety rules of [standards/house-rules.md](../../../standards/house-rules.md)
into practice. A commit is a unit of *review and revert*, not a save button — history
should let a future reader bisect to the exact change that broke something.

## When to use

- Before starting work (pull/rebase) and whenever you stage a change to commit.
- The user says "commit", "squash", "clean up history", or "get this ready for a PR".
- You created WIP checkpoints and now need a reviewable, bisectable series.

## Workflow

1. **Pull/rebase first.** Branch off an up-to-date main (`git pull --rebase`) — the
   avoidable merge conflict is the one you didn't pull for. Never work on a stale base.
2. **Stage deliberately.** One logical change per commit. Use `git add -p` to split
   unrelated edits; don't sweep the whole tree into one commit. If you can't name the
   commit in one imperative line, it's doing too much — split it.
3. **Write the message in imperative English.** `fix: prevent double-submit on retry`,
   not "fixed" / "fixes" / a Spanish or emoji-laden line. Use conventional-commit
   prefixes (`feat:` `fix:` `refactor:` `test:` `chore:`) where the repo already does.
   Explain *why* in the body when the change isn't self-evident; the diff already shows
   the *what*.
4. **Checkpoint freely, then curate.** WIP commits are fine locally. Before a PR,
   squash/reorder (`git rebase`, non-interactive flags in this environment) into a
   clean series where **each commit builds and passes the pre-commit gate** — so
   `git bisect` lands on a real, isolated change.
5. **Stop at the local branch.** Never push, force-push, or open a PR unless explicitly
   asked (house-rules). Leave the curated branch and report it.

## Anti-patterns

- One giant "implement feature" commit that mixes refactor, feature, and formatting —
  unreviewable and unbisectable.
- Committing formatting/reflow churn alongside behavior, burying the real change.
- Past-tense, vague, non-English, or emoji messages ("update stuff", "wip", "arreglos").
- Force-pushing or opening a PR on your own initiative.
- Committing secrets, `.env` files, stray `yarn.lock`/`pnpm-lock.yaml`, or debug detritus.
- Leaving WIP checkpoints in the history sent for review instead of squashing noise.

## Checklist

- [ ] Pulled/rebased onto an up-to-date main before starting.
- [ ] Each commit is one logical change, staged with `-p` where needed.
- [ ] Messages are imperative English with the repo's conventional prefix; *why* in body.
- [ ] WIP checkpoints squashed; every commit in the series builds and passes the gate.
- [ ] No secrets, stray lockfiles, or debug detritus committed.
- [ ] Did not push/force-push/PR unless the user asked.
