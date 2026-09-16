---
name: code-review
description: Read-only review discipline for a diff, branch, or set of files. Use
  before a change lands, after implementing a feature, when auditing a repo, or when
  the user says "review this", "code review", "look over the diff", or "what's wrong
  with this". Reviews in strict priority order and verifies claims by running the real
  gate — it reports ranked findings, it does not rewrite.
---

# Code review — ranked, verified, read-only

Puts the Review stage of [standards/dev-flow.md](../../../standards/dev-flow.md) into
practice, gated by [standards/testing.md](../../../standards/testing.md) (run the real
gate) and [standards/architecture.md](../../../standards/architecture.md)
(SOLID / dependency direction / complexity). Review finds and *reports* problems; it
never edits the code.

## When to use

- Before a change lands, after `senior-dev`/implementation, or when auditing an
  existing repo.
- The user says "review this", "code review", "look over the diff/PR", "what's wrong
  with this", or "is this ready to merge".

## Priority order (report in this order)

1. **Correctness bugs** — logic errors, race conditions, off-by-one, unhandled
   null/error paths. Each finding names a **concrete failure scenario** ("with an empty
   cart, `total()` divides by zero"), not a vague worry.
2. **Secrets & security** — leaked keys/tokens, injection, missing authz, unsafe
   deserialization, PII in logs.
3. **House-convention violations** — the repo's own patterns and the standards (naming,
   error handling, no `any`, tokens-not-hardcoded-hex, surgical-change rule).
4. **SOLID / complexity** — dependency direction (core importing infra), shallow
   modules, god functions, duplication that should reuse an existing utility.
5. **Test / CI / migration safety** — missing test for the real behavior, a tautological
   test, a destructive or non-idempotent migration, a broken quality gate.

## Workflow

1. **Get the diff.** Scope to the change under review (`git diff`, the PR, the named
   files) — review the delta and its blast radius, not the whole repo.
2. **Read for intent first.** Understand what the change is trying to do before judging
   how; a "bug" against a misread intent is noise.
3. **Verify, don't guess.** Run the **real** gate — the actual typecheck (`tsc -b` /
   `npm run typecheck`, never `tsc --noEmit` on a solution-style tsconfig) and the
   relevant tests. Reproduce a suspected bug rather than asserting it.
4. **Label confidence.** Mark each finding **CONFIRMED** (you ran it and saw it fail /
   traced it concretely) or **PLAUSIBLE** (reasoned but unverified). Never present a
   guess as a fact.
5. **Rank and report.** Order by the priority list; for each: file:line, the concrete
   failure or violation, and a suggested direction. Note what you checked and found
   clean.
6. **Stay read-only.** Do not rewrite the code. The report is the deliverable; the
   author (or a follow-up build step) applies fixes.

## Anti-patterns

- Rewriting the code instead of reporting — review is read-only; edits skip the
  author's judgment and blur what changed.
- "This might be slow / could break" with no concrete scenario, file:line, or repro.
- Asserting a bug you never ran — guessing dressed as CONFIRMED.
- Style nits and bikeshedding ranked above a correctness or security finding.
- Skipping the real gate and trusting a green-looking `tsc --noEmit` that checked
  nothing.
- Reviewing the whole repo when only a diff was asked for → noise buries the signal.

## Checklist

- [ ] Findings ordered: correctness → security → house-convention → SOLID/complexity →
      test/CI/migration.
- [ ] Every correctness finding has a concrete failure scenario + file:line.
- [ ] The real typecheck and relevant tests were actually run.
- [ ] Each finding labeled CONFIRMED or PLAUSIBLE.
- [ ] No secrets, unsafe migrations, or missing real-behavior tests slipped through.
- [ ] Report only — no code rewritten.
