# my-agents

Gonzalo's personal roster of Claude Code subagents, plus the workflow that wires
them into a development lifecycle. These are the definitions that live in
`~/.claude/agents/` (user scope — available in **every** project on this machine).

This repo is the source of truth; `install.sh` syncs it into `~/.claude/agents/`.

## The roster

| Agent | Role in the lifecycle | Model | Writes code? |
|-------|----------------------|-------|--------------|
| **software-architect** | Plans & designs before code exists. Produces developer-ready specs with a mandatory Big-O complexity audit, testing strategy, and CI plan. | opus | ❌ never |
| **senior-dev** | Implements features, refactors, and bug fixes in the house TypeScript/Next/Node style (Synta as the reference exemplar). | (inherits) | ✅ |
| **unit-tester** | Authors tests in the fleet's toolchains — Vitest+coverage+BDD+Stryker for TS, pytest/uv for Python, `cargo test` for Rust. | sonnet | ✅ (tests) |
| **code-reviewer** | Read-only review of a diff/branch: correctness bugs first, then secrets/security, house-convention violations, SOLID/complexity. Verifies by running typecheck/tests. | opus | ❌ reports only |
| **qa-engineer** | Owns quality end-to-end: drives TDD (red→green→refactor), designs test strategy & writes the tests (Vitest+coverage+BDD+Stryker / pytest / cargo), validates seed/fixture data & DB coherence, hunts edge cases, verifies by running the real toolchain. | opus | ✅ (tests) |
| **seo-geo** | Standalone specialist (outside the pipeline): audits & improves both **SEO** (organic search) and **GEO** (getting cited by ChatGPT/Claude/Gemini/Perplexity) — intent titles + metadata, JSON-LD, sitemaps + indexing (Search Console/IndexNow), OG images, llms.txt, AI-crawler access. Checks the live site, then implements. | opus | ✅ |
| **product-designer** | Standalone specialist: owns the look & feel — distinctive, non-"AI-slop" visual identity, design tokens/systems, type & color & motion, both themes. Reviews the rendered UI (dev-browser) and implements the visual layer in Tailwind. | opus | ✅ (styling) |
| **ux-engineer** | Standalone specialist: interaction/IA + **mobile-first responsive** & **accessibility** (WCAG). Verifies real layouts across 375/768/1024 breakpoints via dev-browser, fixes overflow/tap-target/contrast/focus bugs in Tailwind/React. | sonnet | ✅ |

The first four form a pipeline: **architect → senior-dev → unit-tester → code-reviewer**.
**seo-geo**, **product-designer**, and **ux-engineer** are standalone specialists you invoke as
needed — respectively to grow a site's search/AI visibility, to establish or elevate its visual
identity, and to make it genuinely usable and accessible on every screen (mobile-first).
See [WORKFLOW.md](./WORKFLOW.md) for how to run a feature through the pipeline end-to-end.

## House context baked into every agent

These agents were tuned against the real conventions of ~40 projects on this machine,
so you don't have to restate them each time:

- **Stack:** Next.js App Router + React 19 + TS strict + Tailwind + shadcn (front);
  Express 5 / Fastify + Prisma/Drizzle over PostgreSQL (back); Expo/React Native
  (mobile); Python on **uv** (ruff, pytest); Rust/cargo for product-like experiments.
- **Package managers:** **npm** (never yarn/pnpm) for JS, **uv** for Python, cargo for Rust.
- **Quality gate:** a typecheck is the universal minimum — but run the project's *real*
  one (`tsc -b` / `npm run typecheck`), since `npx tsc --noEmit` silently passes on a
  solution-style tsconfig (`"files": []` + `references`) without checking anything. The
  gold standard (Synta) is typecheck → coverage ≥95% → Cucumber BDD (Spanish) → API
  integration → Stryker mutation ≥85%. Vitest 3 / Vite need Node ≥20 (`nvm use 20`).
- **Deploy:** GitHub Actions → Google Cloud Run (GCP `link-binder`, `southamerica-west1`),
  Docker → Artifact Registry, WIF auth, Cloud SQL Proxy for migrations. Static → Firebase.
  Cloud Scheduler (scaled-to-zero cron/tick) lives in a **separate** region — it's not
  offered in `southamerica-west1` (use e.g. `southamerica-east1`).
- **Copy:** client-facing UI/LLM text is **Chilean Spanish (es-CL)**, tuteo. **NEVER, EVER use
  neutral Spanish (Argentina) or any Argentinism** — no voseo, no *che/pibe/remera/casaca*
  (use *camiseta/polera*). Code/comments/commits in English.
- **Git:** never push / force-push / open PRs unless explicitly asked. Never commit secrets.

## Install

```bash
./install.sh            # copies agents/*.md into ~/.claude/agents/
./install.sh --symlink  # symlinks instead, so edits here take effect live
./install.sh --dry-run  # show what would change, do nothing
```

After installing, the agents are available in any Claude Code session on this machine.

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
