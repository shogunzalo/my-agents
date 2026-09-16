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

## When to use

- Building a new feature or fixing a bug where you can express "done" as a test.
- Any interaction/UI feature — write the test for the **real user action**, not just
  the leaf helper.
- The user says "TDD", "test-first", "red-green-refactor", or "write the failing test
  first".

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

## Anti-patterns

- Testing internals / implementation details → tests break on refactor and prove
  nothing about behavior.
- Tautological tests (assert the mock returned what you told it to).
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
