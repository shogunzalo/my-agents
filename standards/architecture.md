# Architecture — how the code is shaped

The design principles that keep a codebase navigable, testable, and cheap to change.
Bad architecture is the tax AI leverage can't pay down — this is the part the human
owns.

## Clean / hexagonal (ports & adapters)

- **A pure domain core with zero I/O.** Business logic depends on *interfaces*
  (ports), never on concrete infrastructure. Adapters (DB, HTTP, LLM, queues) bind
  to those ports at the edges. Wire dependencies in a single composition root.
- The core has **no `Date.now()`, no `Math.random()`, no real timers, no network**.
  Inject a clock and an id/randomness source. This is what makes it deterministic
  and testable.
- **Side effects are modeled as intents** returned by the core (outbox pattern), not
  performed inside it. Preserve the decision → effect split: the core *decides*, the
  adapter *acts*.
- A concrete example of the payoff: a risk/policy layer that *wraps* an outbound port
  so the engine can never bypass it — the dependency direction enforces the rule.

## SOLID

Applied pragmatically, not dogmatically:

- **S** — one reason to change per module. **O** — extend via new adapters/strategies,
  don't edit stable core. **L** — adapters honor their port's contract fully.
- **I** — narrow, purpose-built interfaces (don't force a fat port on a thin
  consumer). **D** — depend on abstractions; the core defines the interface it needs
  and infrastructure implements it.

## Deep modules

Prefer **deep modules**: a lot of behavior behind a simple interface. A good module
hides complexity; a shallow one just forwards it. Judge an abstraction by how much it
lets callers *not* know.

## Domain-Driven Design

- **Ubiquitous language:** name things the way the domain does, and use those names
  consistently in code, tests, and conversation. Persist the vocabulary (a glossary /
  `CONTEXT.md`) so humans and agents stop drifting.
- Model aggregates by **identity, not nesting**. Where it fits, derive read models
  (CQRS-ish) from an append-only event log — auditability first-class.
- Validate-then-act with schemas (e.g. Zod in TS) at the boundary.

## Folder structure

- **Monorepo** with workspaces where multiple surfaces share logic: a zero-dep pure
  domain package → server/adapter packages → app packages. Shared domain lives in the
  zero-dep package so it can move web → React Native → Electron.
- Group by **feature/domain**, not by technical layer, above the adapter line. Keep
  ports next to the core that owns them; keep adapters in infrastructure.
- Platform-specific I/O stays at the edges so the core stays portable.

## Design patterns

Reach for the standard vocabulary when it earns its place — ports/adapters, strategy
(swappable algorithms behind a port), factory/composition-root for wiring, repository
for persistence, outbox for effects. Don't pattern for its own sake: simplicity
first, name the scale trigger rather than pre-building for it.

## Fitness functions

Encode architectural rules as **executable checks**, so the design can't silently
decay:

- Dependency-direction tests (the core must not import infrastructure).
- Coverage / mutation thresholds as CI gates (see [testing.md](./testing.md)).
- Lint rules for banned patterns (`any`, `Date.now()` in core, deep relative imports
  crossing the port boundary).
- Bundle-size / performance budgets where they matter.

These are the guardrails that keep incremental change from decaying into entropy.

## Visual system (front-end)

- **Design tokens only.** Colors/type/spacing/radius live as CSS variables /
  Tailwind theme tokens in one place (e.g. `globals.css`); never hardcode hex in a
  component. Design **both** themes (dark-mode-first — see
  [house-rules.md](./house-rules.md)).
- **Avoid AI-slop tropes** — the generic default look of AI-generated apps: no
  `Sparkles`-style "magic" icons; no library-default `focus:border-primary` /
  `hover:border-primary` glow-boxes; not everything centered; not the safe
  Inter/Space-Grotesk + purple-gradient hero. Spend boldness deliberately, in one
  place, grounded in the subject.
- **Have a point of view.** A distinctive, consistent identity (type carries the
  page; a deliberate palette biased toward the accent; motion that respects
  `prefers-reduced-motion`) beats a component-library assembly.
- **Inspiration bar:** aim for the level of craft on
  [awwwards.com](https://www.awwwards.com/) and
  [Framer templates](https://www.framer.com/marketplace/templates/) — not generic
  defaults.

## Related

- [testing.md](./testing.md) (fitness functions, quality ladder) ·
  [dev-flow.md](./dev-flow.md) (spec/vocabulary in Plan) · [house-rules.md](./house-rules.md)
