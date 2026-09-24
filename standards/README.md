# standards/ — the single source of truth

These are the canonical engineering standards. Everything else in this repo
(agents, skills) **cites** these files instead of restating them, so a rule is
written once and changed in one place.

Why this exists: bad code is now the most expensive it has ever been. Regenerating
code without design oversight makes it *worse*, not better. The human is the
strategic architect — vocabulary, boundaries, design — while the agent does
tactical implementation. These standards encode that architecture so the output is
structured and predictable instead of "vibe-coded."

## The files

| File | Covers |
|------|--------|
| [house-rules.md](./house-rules.md) | Non-negotiables: language (es-CL, no Argentinisms), npm-only, no emojis, strict TS, dark-mode-first, git safety, communication style. |
| [dev-flow.md](./dev-flow.md) | The lifecycle: Think → Plan → Build → Review → Test → Ship → Reflect. Spec-driven development, design-up-front then test, commit & branch strategy, pre-commit gate, CI/CD trigger. |
| [architecture.md](./architecture.md) | Clean/hexagonal (ports & adapters), SOLID, DDD, deep modules, folder structure, design patterns, fitness functions, visual system. |
| [testing.md](./testing.md) | Test pyramid, real-behavior rule, TDD-as-a-tool, the quality ladder (typecheck → coverage → BDD → integration → mutation), per-language toolchains, performance testing. |
| [agent-guardrails.md](./agent-guardrails.md) | Keeping AI-written tests honest: the failure modes (faked red, overshoot, tautological/self-verifying tests, weaken-to-green, coverage theater), banned moves, mutation testing as the real signal, and the human checkpoints that don't automate away. |
| [environment.md](./environment.md) | Portable environment discipline: detect the runtime, verify a tool exists before using it, confirm browser tooling launches, check module format — don't assume. Machine specifics go in a local override. |
| [cloud.md](./cloud.md) | Deploy topology (Cloud Run / GCP), CI/CD-on-push, IaC / Terraform, GCP cost-consciousness. |

## How these are used

- **Agents** open the relevant standard at the start of a task (a `code-reviewer`
  reads `testing.md` + `architecture.md`; `senior-dev` reads all).
- **Skills** are the *procedures* that put a standard into practice (the `tdd` skill
  executes the loop that `testing.md` mandates).
- Installed to `~/.claude/standards/` by `install.sh`, so every project on the
  machine sees the same rules.

## Provenance

These are not aspirational. Each rule is distilled from real corrections across many
projects — lessons that were previously scattered as one-off notes and per-project
memory. Consolidating the *principles* here (project- and machine-agnostic) is the
point: one durable, reviewable home. Anything specific to a single machine (exact
paths, ports, runtime versions) stays in a per-machine local override, not here.
