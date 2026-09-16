# skills/ — composable SWE procedures

Skills are on-demand instruction files that put a [standard](../standards/) into
practice. Where a standard says *what* the rule is, a skill is the *procedure* an
agent follows to execute it.

## Format

Each skill is a self-contained folder with a `SKILL.md`. Frontmatter is the Claude
Code two-field standard — **the `description` is the auto-load trigger**, so it must
say *when* to reach for the skill, including trigger phrases:

```markdown
---
name: tdd
description: Test-driven development. Use when building features or fixing bugs
  test-first, when the user mentions "red-green-refactor", or wants integration tests.
---

# TDD
## When to use
## Workflow
## Anti-patterns
## Checklist
```

## Two kinds of skill

- **Model-invoked disciplines** — auto-fire on a task pattern; reusable engineering
  habits. `tdd`, `code-review`, `diagnosing-bugs`, `domain-modeling`, etc.
- **User-invoked orchestrators** — explicit `/slash` commands that sequence a
  workflow. `/spec`, `/ship`, `/grill-me`, etc.

## Layout

```
skills/
├── engineering/   disciplines: tdd, clean-architecture, ddd, code-review
├── delivery/      commit-strategy, ci-cd, iac-terraform, perf-testing
├── product/       user-journeys
└── workflow/      orchestrators: spec-driven, grill-me
```

Skills chain: a grill/journey feeds a spec, the spec feeds the build, the build feeds
review, review feeds test, test feeds ship. Installed to `~/.claude/skills/` by
`install.sh`.

## The roster

| Skill | Kind | Puts into practice |
|-------|------|--------------------|
| `engineering/tdd` | discipline | testing.md — red→green→refactor, real-behavior tests |
| `engineering/clean-architecture` | discipline | architecture.md — ports & adapters, pure core, outbox |
| `engineering/ddd` | discipline | architecture.md — ubiquitous language, aggregates, contexts |
| `engineering/code-review` | discipline | testing.md + architecture.md — the review priority order |
| `delivery/commit-strategy` | discipline | dev-flow.md + house-rules.md — commits, branches, git safety |
| `delivery/ci-cd` | discipline | cloud.md + dev-flow.md — deploy on push, never by hand |
| `delivery/iac-terraform` | discipline | cloud.md — reproducible infra as code |
| `delivery/perf-testing` | discipline | testing.md — load tests against a budget |
| `product/user-journeys` | discipline | dev-flow.md — the real usage flow before code |
| `workflow/spec-driven` | orchestrator | dev-flow.md — intent → executable spec (Plan) |
| `workflow/grill-me` | orchestrator | dev-flow.md — the pre-code interview (Think) |
