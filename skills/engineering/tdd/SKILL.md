---
name: tdd
description: Test-driven development. Use when building a
  feature or fixing a bug test-first, when the user mentions "red-green-refactor" or
  TDD, or when adding tests that must exercise real behavior (not just a pure helper).
---

# TDD — red → green → refactor

Puts [standards/testing.md](../../../standards/testing.md) into practice. The point
of TDD here is not ceremony — it's forcing small, deliberate steps so the code stays
structured instead of vibe-coded, and so tests prove the behavior the user actually
invokes.

**TDD is a tool, not the default.** The default for non-trivial work is design up front
→ implement → test, with mutation testing as the regression signal (see
[testing.md](../../../standards/testing.md)). Run the full loop when it *earns its
place* — the cases below — because an agent running it unsupervised costs several times
the tokens for no clear quality edge, and drifts into the failure modes in
[agent-guardrails.md](../../../standards/agent-guardrails.md). A human should read *why*
each red went red — that is the only thing the red proves.

## When to use

- Fixing a bug: write the failing test that reproduces it **first**, then fix — so the
  regression is pinned.
- Tricky pure logic or a contract you can state crisply as a test up front.
- Any interaction/UI feature — write the test for the **real user action**, not just
  the leaf helper.
- The user says "TDD", "test-first", "red-green-refactor", or "write the failing test
  first".

## When NOT to use

- Broad new features where the design isn't settled — design up front first
  (`software-architect`), then implement, then test. Emergent TDD design has not shown
  a quality edge in the agent loop.
- As a reflex on every change, or to hit a coverage number. That's ceremony and token
  burn, not confidence.

## Workflow

1. **Pick the smallest next behavior.** One vertical slice. If you can't name the
   behavior in a sentence, it's too big — split it.
2. **Red.** Write the failing test at a real seam (public interface), then run it and
   **confirm it fails for the right reason** (the assertion, not a typo or missing
   import). Show the red output.
3. **Green.** Write the minimal code to pass. No extra features, no speculative
   abstraction (simplicity first).
4. **Refactor.** Clean up with the test as a safety net. Re-run — still green.
5. **Repeat** for the next slice.

Report the red → green transition explicitly (the failing run, then the passing run).

## The real-behavior rule (non-negotiable)

Test what the user actually does, end-to-end at the relevant seam — not only the pure
function that was easy to test.

- Drag-and-drop → fire an actual drop event; assert the item is created AND the
  browser default was prevented.
- An endpoint → hit the real running server (supertest), assert status + body + side
  effect (row written), not just the handler in isolation.
- Don't mock local infra when a real running service is available (see testing.md).

## Toolchain

- **TypeScript:** Vitest + v8 coverage; supertest for API; fast-check for properties;
  Cucumber (es-CL) + Stryker on gold-tier repos.
- **Python:** pytest + pytest-asyncio via uv. **Rust:** in-crate `#[test]` + `tests/`.
- Run the **real** gate on **Node ≥20** (`nvm use 20` / the repo `.nvmrc`) — `npx tsc
  --noEmit` on a solution-style tsconfig checks nothing; use `tsc -b` /
  `npm run typecheck`. See [standards/environment.md](../../../standards/environment.md).

## Anti-patterns (the [guardrails](../../../standards/agent-guardrails.md), in short)

- **Faking the red** — skipping the failing run, or implementing ahead of the test so
  it passes on the first execution. A red you never watched proves nothing.
- **Overshooting the test** — building more than the current test demands because the
  whole requirement is in context.
- **Tautological / self-verifying tests** — expected value produced by the code under
  test, or asserting a mock echoed what you told it to return.
- **Weaken-to-green** — loosening an assertion/tolerance, or `skip`/`only`/deleting a
  failing test, to make it pass. Fix the code, or change the test deliberately with a
  reason.
- Testing internals / implementation details → tests break on refactor and prove
  nothing about behavior.
- Testing only the pure helper and shipping the untested integration → the bug
  reaches prod.
- Writing the test *after* the code and calling it TDD.
- Chasing a coverage number with trivial tests that don't fail on real bugs (that's
  what mutation testing catches).

## Checklist

- [ ] Failing test written first, confirmed failing for the right reason.
- [ ] Test targets a real seam / the real user action.
- [ ] Minimal implementation; no speculative scope.
- [ ] Refactored; still green.
- [ ] Real typecheck + tests pass on the right Node version.
- [ ] For a bug fix: the regression test that would have caught it now exists.
