# Dev flow — the lifecycle

The path from intent to shipped code. The goal is to **bypass the "vibe coding"
phase and get structured, predictable code**: design intent is captured in durable
artifacts, changes are small and deliberate, and every stage has a gate.

```
Think → Plan → Build → Review → Test → Ship → Reflect
```

Each stage maps to agents and skills (harness engineering): the human owns Think and
the design of Plan; agents do the tactical work inside each stage.

## 1. Think — surface intent before code

Before writing anything, interview the problem. Turn a vague request into verifiable
success criteria. Surface assumptions and tradeoffs; **don't hide confusion.**

- Ask the forcing questions: what's the actual user action? what's the smallest
  slice that proves it? what could break? what's explicitly out of scope?
- Output: a short shared understanding (a "grill me" step), not code.

## 2. Plan — spec-driven, not vibe-driven

Write the design down before implementing. For anything non-trivial, produce a
short **spec / plan artifact** that a fresh reader (or agent) can execute:

- Overview, the approach, the data models / API contracts, edge cases, acceptance
  criteria, dependency order.
- Persist **shared vocabulary** — a ubiquitous language for the domain (see
  architecture.md → DDD) — so agents and humans use the same words and stop wasting
  tokens re-explaining. Record decisions and their alternatives (lightweight ADRs).
- **Simplicity first:** no features beyond what was asked, no speculative
  abstractions. Name a scale trigger, don't pre-build for it.

## 3. Build — surgical implementation

- **Make surgical changes.** Edit only what the task requires. Don't reformat or
  "improve" adjacent code; don't remove anything except what your change made
  obsolete. Write code that looks like it was already there — match surrounding
  density, naming, and idiom.
- **Reuse before you abstract.** Find the existing utility/pattern first.
- Vertical slices: one behavior at a time, test-first where it pays (see
  [testing.md](./testing.md) and the `tdd` skill).

## 4. Review — before it lands

Run the `code-reviewer` (or `/code-review`) on the diff. Priority order:
correctness bugs (with a concrete failure scenario) → secrets/security → house-rule
violations → SOLID/complexity → test/CI/migration safety. Review is **read-only**:
it reports ranked findings, it does not rewrite.

## 5. Test — prove it works

- **TDD by default** (red → green → refactor). Write the failing test first, confirm
  it fails for the right reason.
- **Test the real behavior, not just the easy pure helper.** (A shipped drag-and-drop
  bug reached prod because only the pure parser was tested — *"the tests should have
  shown that this works."*) For an interaction feature, simulate the real user action
  end-to-end.
- Gate at the project's real quality bar — see [testing.md](./testing.md).

## 6. Ship — through the pipeline, never by hand

- **Deploys go through CI/CD on push to main. Never manual `gcloud run deploy` /
  `firebase deploy`.** *"When we push to main we deploy... Fix pipeline failures by
  committing forward, not by deploying manually."* A deploy that only works from one
  authed laptop is not a real deploy path.
- One-time infra bootstrap (service accounts, WIF, secrets) may be CLI; the deploy
  itself is code in the repo. See [cloud.md](./cloud.md).

## 7. Reflect — capture the learning

- After a fix, add the regression test that would have caught it.
- If a correction revealed a durable preference or a repo gotcha, write it down
  (agent memory or the relevant standard) so the next session doesn't relearn it.

---

## Commit & branch strategy

- **Branch off an up-to-date main** (`git pull`/rebase first — always).
- **Small, focused commits.** Imperative mood, English, no emojis. Explain *why* in
  the body when the change isn't obvious. WIP checkpoints are fine locally; keep
  history bisectable by squashing noise before a PR.
- **Conventional-commit prefixes** (`feat:`, `fix:`, `refactor:`, `test:`, `chore:`)
  where a repo already uses them.
- **Never push/force-push/PR unless asked** (house-rules.md).

## Pre-commit gate

The minimum bar before a commit is considered done:

1. The **real** typecheck passes (`tsc -b` / `npm run typecheck` — not
   `tsc --noEmit` on a solution-style tsconfig, which checks nothing). See
   [environment.md](./environment.md) for the node-version footgun.
2. Relevant tests pass, run against the real toolchain.
3. No secrets, no stray lockfiles, no debug detritus.

Prefer wiring this as an actual pre-commit hook / CI job rather than relying on
memory.

## Related

- [testing.md](./testing.md) · [architecture.md](./architecture.md) · [cloud.md](./cloud.md)
- Skills that execute these stages live in `skills/` (the `tdd` skill is the first).
