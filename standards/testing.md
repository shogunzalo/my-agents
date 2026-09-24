# Testing — proving it works

Tests exist to prove the behavior the user actually invokes — not to decorate the
pure helper that was easy to test. Pro-tests; **outcome over ceremony.** The signal
that matters is whether a test could catch a real bug, so a green suite an agent
produced counts for nothing until that's established — see
[agent-guardrails.md](./agent-guardrails.md), which keeps AI-written tests honest.

## The core rule: test the real behavior

> "A test that doesn't cover the behavior the user actually invokes proves nothing.
> The tests should have shown that this works."

Classic failure: a drag-and-drop feature had only its pure `input → parsed` helper
unit-tested; the real bug (drop zone too narrow, so the browser opened the file
instead) reached prod. For an interaction feature, **write a test that simulates the
real user action end-to-end** (fire the actual drop event; assert the item is created
AND the browser default is prevented) — not only the leaf helper. Prefer writing that
failing test first.

Corollary: **don't mock the local env.** Keep local infra working and test against
it; don't stand up a fake where a real running service would do. Prefer real server
over in-memory substitute over DB mock.

## The test pyramid

- **Wide base of unit tests** on the pure domain core (fast, deterministic — the
  clock and randomness are injected, so no flakiness).
- **A solid middle of integration tests** across the seams that matter: real server
  + real DB (or a faithful adapter), API contracts, persistence.
- **A thin top of end-to-end / UI-interaction tests** for the flows a user actually
  performs.
- **Test at pre-agreed seams** (public interfaces), not internals. Tests are specs;
  avoid tautological or implementation-coupled tests that pass even when the feature
  is broken.

## TDD — a tool, not the default

The default for non-trivial work is **design up front, then implement, then test**
(the `software-architect` decides architecture, contracts, and edge cases before code
— upfront design correlates with better outcomes than design that emerges one test at
a time in an agent loop). Reach for test-first where it genuinely pays — reproducing a
bug before the fix, pinning tricky pure logic, a contract you can state as a test — not
as a reflex on every change. An agent running the full red→green→refactor loop
unsupervised costs several times the tokens for no clear quality edge, and tends to
fake the red step, overshoot the test, or write tautological tests
([agent-guardrails.md](./agent-guardrails.md)).

When you do run it:

1. **Red:** write the smallest failing test for the next behavior; confirm it fails
   *for the right reason* — and have a human read *why* it went red, because that's the
   only thing the red actually proves.
2. **Green:** minimal implementation to pass. No overshoot beyond the current test.
3. **Refactor:** clean up with the test as a safety net.

One vertical slice at a time; the `tdd` skill in `skills/` executes this loop.

## The quality ladder

Run the project's **real** gate, in ascending order of rigor. Not every repo needs
every rung, but **leave every repo at least one tier better** than you found it.

1. **Typecheck** — the universal minimum. Run the *real* one (`tsc -b` /
   `npm run typecheck`); `npx tsc --noEmit` on a solution-style tsconfig
   (`"files": []` + `references`) silently checks nothing.
2. **Coverage** — Vitest + v8. A strong gate targets ≥95% on core logic.
3. **BDD** — Cucumber, with scenarios in the product's locale for top-tier repos.
4. **API integration** — Vitest + supertest against a real running server.
5. **Mutation** — Stryker (≥85% on top-tier repos) to prove the tests actually catch
   bugs, not just execute lines. This is the **primary regression-quality signal**:
   prefer monitoring and improving the mutation score over prescribing elaborate TDD
   ceremony and hoping the tests bite. High line-coverage with a low mutation score is
   coverage theater ([agent-guardrails.md](./agent-guardrails.md)).

**Refactor by review, not by loop.** Don't trust an incremental TDD loop to keep the
design clean on its own. Give the agent static analysis, run periodic reviews of
structure and modularity, and watch the **number of files touched per change** as a
coupling smell — the `code-reviewer` flags these.

## Per-language toolchains

- **TypeScript:** Vitest + v8 coverage + supertest; fast-check for property tests on
  the top tier; Cucumber (BDD) + Stryker (mutation) at the top. Jest only in legacy
  repos that already use it.
- **Python:** pytest + pytest-asyncio via **uv**; ruff. Hexagonal test split.
- **Rust:** in-crate `#[test]` + `tests/` integration.

## Data / seed / migration QA

- A seed must be **coherent** (statuses/relationships mutually consistent),
  **referentially intact**, and **deterministic** (fixed clock).
- Run it against a **clean DB** and verify row counts + representative joins.
- **Some ORMs block destructive commands (e.g. migrate-reset) when invoked by an AI
  agent** and demand the *user's* explicit consent. An agent authorization is **not**
  user consent — don't fake it. Fall back to an **idempotent, self-cleaning seed**
  (delete prior-version rows by a deterministic id prefix) so a re-seed converges
  without a destructive reset. Ask the user directly if a true reset is required.
- Scope verification queries to the rows the seed **owns** (by id prefix), not a
  blanket `COUNT(*)` over a shared dev DB.

## Performance testing

- When latency/throughput is a real requirement, load-test the seam under realistic
  concurrency (**Gatling**, k6, or `autocannon` for HTTP). Assert against a budget,
  don't eyeball.
- Keep perf budgets as **fitness functions** ([architecture.md](./architecture.md))
  in CI where they matter — bundle size, p95 latency, query counts.

## Pre-commit

Typecheck + relevant tests green before a commit is done
([dev-flow.md](./dev-flow.md) → pre-commit gate). Wire it as an actual hook/CI job,
not memory.

## Related

- [agent-guardrails.md](./agent-guardrails.md) (keeping AI-written tests honest) ·
- [dev-flow.md](./dev-flow.md) (TDD in the lifecycle) ·
  [architecture.md](./architecture.md) (deterministic core, fitness functions) ·
  [environment.md](./environment.md) (right runtime, real gate).
