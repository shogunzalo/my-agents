# The workflow

How the agents, skills, and standards combine into a development lifecycle. The shape
is the lifecycle from [standards/dev-flow.md](./standards/dev-flow.md) —
**Think → Plan → Build → Review → Test → Ship → Reflect** — with a review gate before
anything lands.

```
              ┌────────────┐
   request →  │ dispatcher │  route: pick the lane, order the hand-offs
              └─────┬──────┘
                    │ delegation plan (the top level executes it)
                    ▼
  Think ──▶ grill-me ┐
                     ├─▶ Plan ──▶ software-architect / spec-driven
                     ▼                     │ spec (no code)
             (user-journeys for UI)        ▼
                                    ┌──────────────┐
                                    │  senior-dev  │  Build — house style, tsc green
                                    └──────┬───────┘
                                           │ working code
                              ┌────────────┴────────────┐
                              ▼                          ▼
                     ┌───────────────┐          ┌──────────────┐
                     │ qa-engineer   │          │ code-reviewer│  Test ∥ Review
                     │ (TDD + gate)  │          │ (read-only)  │
                     └──────┬────────┘          └──────┬───────┘
                            └───────────┬──────────────┘
                                        │ findings
                                        ▼
                     senior-dev fixes ─▶ re-review ─▶ Ship (ci-cd, on push) ─▶ Reflect
```

Subagents can't fan out, so the **dispatcher** produces the plan and the top level
(you, or the main session) runs each step. For a UI surface, add **product-designer**
(visual identity) and **ux-engineer** (journeys/flows/mobile/a11y) to the plan.

## The three layers

- **[standards/](./standards/)** — the source of truth. Every agent reads the relevant
  standard at the start of a task instead of carrying its own copy of the rules.
- **[skills/](./skills/)** — the procedures that execute a standard (the `tdd` skill
  runs the loop `testing.md` mandates). Disciplines auto-apply within a lane;
  orchestrators (`spec-driven`, `grill-me`) are invoked explicitly.
- **[agents/](./agents/)** — the specialists that own a lane.

## When to use which lane

Not every task needs the full pipeline. Pick by scope (the **dispatcher** does this
for you when you're unsure):

- **Trivial change / one-liner:** senior-dev alone (or inline). No architect.
- **New feature or non-trivial refactor:** the full lifecycle.
- **"Is this code OK?" / pre-commit:** code-reviewer on the working diff.
- **"Cover this with tests" / TDD:** qa-engineer.
- **"How should I build X?":** software-architect — a spec to hand off later.
- **"How will people actually use this?":** the `user-journeys` skill (feeds the spec).
- **New UI surface:** product-designer (identity) + ux-engineer (flows/a11y).
- **A site that needs to be found:** seo-geo, standalone.

## Running a feature end-to-end

A recipe you can paste into a session (adapt the target):

1. **Route.** `@dispatcher I want to add <feature> to <repo>. Give me the delegation
   plan.` → an ordered plan naming who does what.
2. **Design.** `@software-architect design <feature> in <repo>. Read the codebase
   first; produce a task breakdown with the complexity audit and a testing strategy.`
   → a spec. Read it, adjust, approve.
3. **Implement.** `@senior-dev implement tasks 1–3 from the spec above.` → code, with
   the real typecheck run and reported.
4. **Test + review in parallel** (one message, so they run concurrently):
   - `@qa-engineer add tests for the new module — TDD where it fits, match the repo's tier.`
   - `@code-reviewer review the working diff. Correctness first, then secrets and house conventions.`
5. **Fix.** Feed the review findings to `@senior-dev`. Re-review if the changes were
   substantial.
6. **Ship — only when you say so.** No agent pushes or opens PRs. When ready:
   `commit and push` — the deploy pipeline takes it from there
   ([standards/cloud.md](./standards/cloud.md)).

## Clean hand-offs

- **dispatcher → everyone:** an explicit ordered plan with gates, so no step starts
  before its input is ready.
- **architect → senior-dev:** the spec names exact files, data shapes, edge cases, and
  acceptance criteria — no telepathy needed. The architect never writes code, so
  there's no half-baked implementation to untangle.
- **senior-dev → qa-engineer:** senior-dev owns the code; qa-engineer owns the tests.
  Splitting them keeps tests honest and lets test-writing run in parallel with review.
- **senior-dev → code-reviewer:** the reviewer is read-only and verifies by running
  the tooling, so findings are grounded, not vibes. Fixes route back to senior-dev.
- **memory:** the opus agents each keep a user-scope `~/.claude/agent-memory/<agent>/`
  dir, so per-repo conventions they discover compound over time. Durable *principles*,
  though, belong in [standards/](./standards/), not scattered memory.
