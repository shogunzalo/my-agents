---
name: clean-architecture
description: Ports & adapters / hexagonal design with a pure deterministic core. Use
  when structuring a new module or refactoring a tangled one, when the user mentions
  "hexagonal", "ports and adapters", "clean architecture", "pure core", "outbox", or
  "dependency direction", or when business logic is entangled with I/O (DB, HTTP, LLM,
  timers, randomness) and needs to be pulled apart.
---

# Clean architecture — ports & adapters

Puts the clean/hexagonal section of
[standards/architecture.md](../../../standards/architecture.md) into practice: a pure
core that *decides*, adapters at the edges that *act*, wired in one place. The payoff
is a core you can test without infrastructure and change without fear.

## When to use

- Starting a module that will grow business rules, or untangling one where logic and
  I/O are fused.
- The user says "hexagonal", "ports and adapters", "clean architecture", "pure/
  deterministic core", "outbox", "composition root", or "dependency direction".
- A test needs a running DB/clock/network to exercise a pure decision — a smell that
  the effects belong at the edge.

## Workflow

1. **Find the decision.** Isolate the business rule — the part that, given inputs,
   *decides* an outcome. That is the core. Everything else (persistence, transport,
   third-party calls) is an adapter.
2. **Define ports as interfaces the core owns.** The core declares the narrow
   interface it needs (`Clock`, `IdGen`, `BookingRepo`); infrastructure implements it.
   Dependency inversion: the arrow points *inward*, never core → infra.
3. **Purge ambient I/O from the core.** No `Date.now()`, no `Math.random()`, no real
   timers, no network. Inject a clock and an id/randomness source. This is what makes
   the core deterministic and unit-testable without mocks.
4. **Model side effects as intents (outbox).** The core returns a description of what
   should happen (`[{ type: "SendEmail", to, body }]`) instead of performing it. An
   adapter drains those intents and acts. Preserve the decision → effect split.
5. **Wire once in a composition root.** Construct concrete adapters and inject them at
   the app entrypoint only. The core is imported everywhere; concrete infra is
   imported nowhere but the root.
6. **Make modules deep.** A lot of behavior behind a small interface. If an
   abstraction just forwards calls, inline it — a shallow wrapper is cost without
   hiding.
7. **Enforce the direction with a fitness function.** Add an executable check (lint
   rule / dependency-cruiser / a test) that fails if the core imports infrastructure
   or calls a banned API. A rule that isn't executable decays.

## The wrap-to-enforce trick

When a rule must never be bypassed (a risk/policy/authorization check), put it *on the
port*: the core can only reach the outside through the wrapped port, so the dependency
direction makes the check unskippable. Structure enforces the invariant — no
discipline required.

## Anti-patterns

- `Date.now()` / `Math.random()` / `fetch` inside the core → non-deterministic, needs
  mocks to test, flaky.
- Performing effects mid-decision (writing the row, sending the email) instead of
  returning intents → you can't test the decision without the world.
- Importing a concrete adapter (a DB client, an SDK) from the core → dependency arrow
  points outward; the core is no longer portable or unit-testable.
- Wiring dependencies in scattered `new`s across the codebase instead of one
  composition root.
- Shallow "clean" layers: a port + adapter per trivial call that only forwards —
  ceremony that hides nothing (simplicity first; name the scale trigger instead).
- The dependency rule living only in a code-review checklist, with no executable gate.

## Checklist

- [ ] Business decision lives in a core with zero I/O.
- [ ] Clock and id/randomness are injected, not ambient.
- [ ] Side effects returned as intents; adapters perform them.
- [ ] Ports are narrow interfaces the core owns; infra implements them.
- [ ] Concrete adapters constructed only in the composition root.
- [ ] Modules are deep (behavior >> interface surface).
- [ ] A fitness function fails the build if the core imports infrastructure.
