# Testing — proving it works

Tests exist to prove the behavior the user actually invokes — not to decorate the
pure helper that was easy to test. Pro-tests, pro-TDD.

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

## TDD (red → green → refactor)

1. **Red:** write the smallest failing test for the next behavior; confirm it fails
   *for the right reason*.
2. **Green:** minimal implementation to pass.
3. **Refactor:** clean up with the test as a safety net.

Show the red → green transition in the report. One vertical slice at a time. The
`tdd` skill in `skills/` executes this loop.

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
   bugs, not just execute lines.

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

- [dev-flow.md](./dev-flow.md) (TDD in the lifecycle) ·
  [architecture.md](./architecture.md) (deterministic core, fitness functions) ·
  [environment.md](./environment.md) (right runtime, real gate).
