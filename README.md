# my-agents

A personal engineering system for Claude Code — a roster of subagents, a
library of composable skills, and the canonical standards they all cite, wired into
one development lifecycle. This is the source of truth; `install.sh` syncs it into
`~/.claude/`.

Its purpose: **bypass the "vibe coding" phase and get structured, predictable code.**
Bad code is now the most expensive it has ever been — the human stays the strategic
architect (design, vocabulary, boundaries) while agents do tactical implementation
against written-down rules.

## Three layers

| Layer | Path | What it is |
|-------|------|-----------|
| **Standards** | [`standards/`](./standards/) | The single source of truth: house-rules, dev-flow, architecture, testing, environment, cloud. Every agent and skill *cites* these instead of restating them. |
| **Skills** | [`skills/`](./skills/) | On-demand procedures that execute a standard (e.g. the `tdd` skill runs the loop `testing.md` mandates). Two-field `SKILL.md` frontmatter; the `description` is the auto-load trigger. |
| **Agents** | [`agents/`](./agents/) | Specialist subagents that own a lane of the lifecycle. |

Start with [`standards/README.md`](./standards/README.md) — it's the map.

## The roster

| Agent | Role in the lifecycle | Model | Writes code? |
|-------|----------------------|-------|--------------|
| **dispatcher** | Tech-lead / router. Reads a request, picks the lane, and produces an ordered delegation plan naming which specialists and skills to invoke, in what sequence, with gates. | opus | ❌ routes only |
| **software-architect** | Plans & designs before code exists. Produces developer-ready specs with a mandatory Big-O complexity audit, testing strategy, and CI plan. | opus | ❌ never |
| **senior-dev** | Implements features, refactors, and bug fixes in the house TypeScript/Next/Node style. Hands large test surfaces to qa-engineer. | (inherits) | ✅ |
| **code-reviewer** | Read-only review of a diff/branch: correctness bugs first, then secrets/security, house-convention violations, SOLID/complexity. Verifies by running typecheck/tests. | opus | ❌ reports only |
| **qa-engineer** | Owns testing end-to-end: designs strategy & writes the tests (Vitest+coverage+BDD+Stryker / pytest / cargo), uses mutation testing as the real regression signal, keeps AI-written tests honest (no faked red / tautological / weaken-to-green — [agent-guardrails](./standards/agent-guardrails.md)), validates seed/fixture data & DB coherence, hunts edge cases, verifies by running the real toolchain. TDD where it pays. | opus | ✅ (tests) |
| **product-designer** | Standalone specialist: owns the look & feel — distinctive, non-"AI-slop" visual identity, design tokens/systems, type & color & motion, both themes. Verifies the rendered UI and implements the visual layer in Tailwind. | opus | ✅ (styling) |
| **ux-engineer** | Standalone specialist: interaction/IA, user journeys + **mobile-first responsive** & **accessibility** (WCAG). Verifies real layouts across 375/768/1024 breakpoints, fixes overflow/tap-target/contrast/focus bugs in Tailwind/React. | sonnet | ✅ |
| **seo-geo** | Standalone specialist: audits & improves both **SEO** (organic search) and **GEO** (getting cited by ChatGPT/Claude/Gemini/Perplexity) — intent titles + metadata, JSON-LD, sitemaps + indexing, OG images, llms.txt, AI-crawler access. Checks the live site, then implements. | opus | ✅ |

The **dispatcher** routes; **architect → senior-dev → {qa-engineer ∥ code-reviewer}**
is the core pipeline. **product-designer**, **ux-engineer**, and **seo-geo** are
standalone specialists you invoke as needed. See [WORKFLOW.md](./WORKFLOW.md) for how
to run a feature end-to-end, and [`skills/`](./skills/) for the disciplines each lane
applies.

## House context — now in standards/

The conventions these agents were tuned against — stack, npm/uv/cargo, the real
quality gate, deploy topology, es-CL/no-Argentinisms, git safety, plus this machine's
environment footguns — now live once in [`standards/`](./standards/) instead of being
restated in each agent. The headlines:

- **Stack:** Next.js App Router + React 19 + TS strict + Tailwind + shadcn (front);
  Express 5 / Fastify + Prisma/Drizzle over PostgreSQL (back); Expo/React Native
  (mobile); Python on **uv**; Rust/cargo. **npm** for JS (never yarn/pnpm).
- **Quality gate:** run the project's *real* typecheck; gold ladder is typecheck →
  coverage ≥95% → Cucumber BDD (es-CL) → API integration → Stryker ≥85% (mutation score
  is the real regression signal, not line coverage). Test the *real* behavior, not just
  the pure helper. TDD is a tool, not a mandate — design up front, then test. →
  [testing.md](./standards/testing.md)
- **Test honesty:** AI-written tests are kept honest by explicit guardrails — no faked
  red, no tautological/self-verifying tests, no weaken-to-green; the human reads *why* a
  test went red. → [agent-guardrails.md](./standards/agent-guardrails.md)
- **Deploy:** push to main → CI/CD; never manual by hand. Container → managed runtime
  via federated CI auth; IaC for reproducible infra; scale to zero. →
  [cloud.md](./standards/cloud.md)
- **Copy:** es-CL, tuteo; **never** Argentinisms. No emojis. →
  [house-rules.md](./standards/house-rules.md)
- **Environment:** detect, don't assume — right runtime via `.nvmrc`, verify a tool
  exists before using it, verify browser tooling launches. Machine-specific facts go
  in a local override. → [environment.md](./standards/environment.md)

## Install

```bash
./install.sh            # copy agents/ + skills/ + standards/ into ~/.claude/
./install.sh --symlink  # symlink instead, so edits here take effect live
./install.sh --dry-run  # show what would change, do nothing
```

Syncs `agents/*.md` → `~/.claude/agents/`, `skills/**/SKILL.md` → `~/.claude/skills/`
(folder layout preserved), and `standards/*.md` → `~/.claude/standards/`. After
installing, everything is available in any Claude Code session on this machine.

## Secret scanning (pre-commit)

A versioned git hook at [`hooks/pre-commit`](./hooks/pre-commit) blocks a commit if
staged changes look like they contain a credential — private-key blocks, cloud/API
keys (AWS, Google, GitHub, Slack, Stripe, Anthropic, OpenAI, Telegram), service-account
JSON, assigned secrets, and stray `.env` files (`.env.example`/`.sample`/`.template`
are allowed). It's zero-dependency (bash + git + grep) and additionally runs
[`gitleaks`](https://github.com/gitleaks/gitleaks) if it's installed.

Enable it once per clone:

```bash
git config core.hooksPath hooks
```

- A confirmed false positive can be marked with a trailing `pragma: allowlist secret`
  comment on that line.
- `git commit --no-verify` bypasses it — don't, for a real finding.
- Real secrets belong in an env var or a secret manager, never in the repo.

## Use them

In any Claude Code session:

- **Explicitly:** `@software-architect design the auth flow for trip-planner`, or
  `@code-reviewer review my working diff`.
- **Automatically:** Claude routes work to them based on their `description` — ask
  "plan and build feature X" and it will pull in the architect, then senior-dev, etc.
- **In parallel:** launch several at once for independent work (e.g. review + write
  tests for two different modules).

Each agent's behavior is defined entirely by its Markdown file in `agents/`. Edit the
file, re-run `install.sh` (or use `--symlink` once), and the change is live.

## Editing an agent

Agent files are Markdown with YAML frontmatter:

```markdown
---
name: my-agent            # the @handle
description: >-           # when Claude should reach for it (routing signal)
  One or two sentences...
tools: ["*"]              # or an explicit allow-list; omit to inherit all
model: opus               # optional: opus | sonnet | haiku, else inherits
memory: user              # optional: gives it a persistent ~/.claude/agent-memory dir
---

System prompt goes here — this is the agent's identity and instructions.
```

Keep the `description` sharp: it's the signal Claude uses to decide when to delegate.
Keep the body dense and specific to how *you* work — that's what makes these better
than a generic assistant.
