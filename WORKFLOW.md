# The agentic workflow

How the four agents combine into a development lifecycle that matches how this fleet
actually gets built. The shape is a pipeline with a review gate:

```
        ┌──────────────────┐
  idea →│ software-architect│  plan + complexity audit + test/CI strategy
        └────────┬─────────┘
                 │ spec (no code)
                 ▼
        ┌──────────────────┐
        │    senior-dev     │  implement in house style, keep tsc green
        └────────┬─────────┘
                 │ working code
        ┌────────┴─────────┐
        ▼                  ▼
 ┌─────────────┐   ┌──────────────┐
 │ unit-tester │   │ code-reviewer│   tests + adversarial review, in parallel
 └──────┬──────┘   └──────┬───────┘
        └────────┬────────┘
                 │ findings
                 ▼
           senior-dev fixes → re-review → commit (when you say so)
```

## When to use which lane

Not every task needs all four. Pick by scope:

- **Trivial change / one-liner:** just senior-dev (or do it inline). No architect.
- **New feature or non-trivial refactor:** the full pipeline.
- **"Is this code OK?" / pre-commit:** code-reviewer alone on the working diff.
- **"Cover this with tests":** unit-tester alone.
- **"How should I build X?":** architect alone — you get a spec you can hand off later.

## Running a feature end-to-end

A concrete recipe you can paste into a session (adapt the target):

1. **Design.** `@software-architect design <feature> in <repo>. Read the codebase
   first; produce a task breakdown with the complexity audit, a testing strategy, and
   the Cloud Run CI implications.`
   → You get a spec. Read it, adjust, approve.

2. **Implement.** `@senior-dev implement tasks 1–3 from the spec above.`
   → senior-dev writes the code, runs `npx tsc --noEmit`, reports what it ran.

3. **Test + review in parallel** (launch both in one message so they run concurrently):
   - `@unit-tester add tests for the new module — Vitest + coverage, match the repo's tier.`
   - `@code-reviewer review the working diff. Correctness first, then secrets and
     house conventions.`

4. **Fix.** Feed the review findings back to `@senior-dev` to apply. Re-run
   code-reviewer on the new diff if the changes were substantial.

5. **Commit — only when you say so.** No agent pushes or opens PRs. When you're ready:
   `commit and push` (you trigger it explicitly; the deploy CI takes it from there).

## How the agents hand off cleanly

- **architect → senior-dev:** the spec names exact files, data shapes, edge cases, and
  acceptance criteria, so senior-dev needs no telepathy. The architect never writes
  code, so there's no half-baked implementation to untangle.
- **senior-dev → unit-tester:** senior-dev owns the code; unit-tester owns the tests.
  Splitting them keeps tests honest (the author of the code isn't grading their own
  homework) and lets test-writing run in parallel with review.
- **senior-dev → code-reviewer:** the reviewer is read-only and verifies by running the
  tooling, so its findings are grounded, not vibes. Fixes route back to senior-dev.
- **memory:** architect, unit-tester, and code-reviewer each keep a persistent
  `~/.claude/agent-memory/<agent>/` dir, so per-repo conventions they discover
  (module boundaries, test fixtures, where secrets leaked) compound over time.

## Fit to the real lifecycle

Mapping the pipeline onto what this fleet does today, and where the agents move the needle:

| Phase | Fleet reality | Which agent helps |
|-------|---------------|-------------------|
| Architect | Strong on flagships (Synta, hunter-clanker have real diagrams), absent on POCs | **software-architect** brings the spec + complexity audit to every task |
| Implement | The bulk of the work; many v0/POC exports of varying maturity | **senior-dev** enforces the house style so POCs don't drift |
| Test | Bimodal — world-class in Synta, **absent in most repos** | **unit-tester** — the biggest single lever; establishes a first suite |
| Review | Light — no linters configured anywhere in the fleet | **code-reviewer** is the missing lint/review gate, plus secret-leak defense |
| Deploy | Strong & standardized — Cloud Run via GHA, WIF | agents know the topology and won't add a deploy step that skips the test gate |

## Relationship to the Ralph loop

For fully autonomous, one-story-at-a-time grinding, this fleet also uses the **Ralph**
loop (`prd.json` + `progress.txt` + `scripts/ralph/`, seen in `hunter-clanker-back` and
`investestbot`). The two are complementary:

- **Ralph** is the outer loop: pick the next PRD story, implement it, mark it done, repeat.
- **These agents** are what Ralph (or you) should call *within* a story — architect the
  story, implement, test, review — instead of doing everything in one undifferentiated
  pass. A Ralph session that delegates its implement/test/review steps to these agents
  gets the same division-of-labor benefits with the autonomy of the loop.
