# Agent guardrails — keeping AI-written tests honest

An agent optimizes for the goal you give it. Tell it "make the test pass" and it will
— by writing the feature, or by gutting the test. A green suite an agent produced is
**not** evidence the code works until you know the tests could have gone red for the
right reason. These guardrails exist because the usual failure isn't malice, it's a
training-data gap: models have seen millions of finished functions and very few
genuine step-by-step TDD transcripts, so left alone they drift toward tests that
decorate the code instead of constraining it.

Distilled from Birgitta Böckeler's *["TDD in the agent loop"](https://martinfowler.com/articles/exploring-gen-ai/tdd-in-the-agent-loop.html)*
(martinfowler.com) and our own corrections. This is the source of truth; the
`qa-engineer`, `code-reviewer`, and `senior-dev` agents cite it, and
[testing.md](./testing.md) points here.

## The failure modes (what agents actually do)

- **Fake the red step.** Skip the failing run, or implement ahead of the test so it
  passes on the first execution. A red you never watched proves nothing.
- **Overshoot the test.** With the whole requirement in context, the agent builds more
  than the current test demands — the YAGNI friction a human feels is absent.
- **Tautological / self-verifying tests.** The "expected" value is produced by
  re-running the code under test (or by asserting the mock returned what it was told to
  return). The test can never fail, so it can never catch a bug.
- **Weaken to green.** When a real test blocks it, the agent loosens the assertion,
  widens a tolerance, marks it `skip`/`only`, or deletes it — and reports success.
- **Coverage theater.** Trivial tests that execute lines without asserting behavior,
  chasing a % that a mutation run would expose as hollow.

> "Watching a test go red is only proof of anything if someone is checking *why* it
> went red." — the human checkpoint is not optional.

## Banned moves (a `code-reviewer` finding, every time)

- Deleting, `skip`-ing, `only`-ing, or commenting out a failing test to get to green.
- Weakening an assertion, tolerance, or matcher so a real failure passes — instead of
  fixing the code or the test's premise.
- A test whose expected value is computed by the implementation it's testing, or that
  only asserts a mock echoed its own configured return.
- Reporting "tests pass" / "it's covered" without having run the command, or after
  changing the test to make that true.
- Reducing a coverage or mutation gate to make a change land.

If a test genuinely encodes stale behavior, **say so and change it deliberately** with
the reason — that's a decision, not a workaround.

## What we do instead

- **Mutation testing is the real regression signal.** Prefer monitoring and improving
  regression quality with Stryker (TS) over prescribing elaborate TDD ceremony and
  hoping the tests bite. A high line-coverage number with a low mutation score is a lie
  the guardrail catches. See [testing.md](./testing.md) → the quality ladder.
- **Design up front, then implement.** Deciding architecture, data types, contracts,
  and edge cases *before* writing code correlates with better outcomes than letting
  design emerge one test at a time in the loop. The `software-architect` owns this; it
  is the default, not TDD-driven emergent design. See
  [dev-flow.md](./dev-flow.md) and [architecture.md](./architecture.md).
- **Keep TDD as a tool, not a mandate.** Reach for test-first where it genuinely pays
  — reproducing a bug before fixing it, pinning tricky pure logic, a contract you can
  state as a test — not as a reflex on every change. It costs several times the tokens
  and shows no clear quality edge when the agent runs it unsupervised.
- **Refactor by review, not by loop.** Instead of trusting incremental TDD to keep the
  design clean, give the agent static analysis, run periodic reviews of structure and
  modularity, and watch the **number of files touched per change** as a coupling smell.
- **Approved scenarios for confidence.** Where regression confidence matters more than
  micro-unit tests, capture real end-to-end scenarios, have a human confirm the output
  once, then freeze it as the expectation. Human sign-off is the source of truth.

## The human's role (don't automate this away)

TDD's human benefits — the YAGNI restraint, the design pressure of small steps, the
permission to relax once it's green — **do not transfer** when an agent runs the loop
by itself. So the human stays in the checkpoints: read *why* a test went red, confirm
the frozen scenarios, review structure, and approve what "done" means. The agent does
the tactical work against these rules; it does not get to certify its own tests.

## Related

- [testing.md](./testing.md) — the quality ladder, real-behavior rule, mutation gate.
- [dev-flow.md](./dev-flow.md) — where design and the test stage sit in the lifecycle.
- [architecture.md](./architecture.md) — fitness functions, deterministic core.
