---
name: ddd
description: Domain-driven design — modeling from the domain's own language. Use when
  naming or modeling a domain, when the user mentions "ubiquitous language", "bounded
  context", "aggregate", "domain model", "glossary", or "shared vocabulary", or when
  code, tests, and conversation keep drifting on what to call things and where a
  concept's boundaries lie.
---

# DDD — model in the domain's language

Puts the Domain-Driven Design section of
[standards/architecture.md](../../../standards/architecture.md) into practice: name
things the way the domain does, draw boundaries by identity and context, and persist
the vocabulary so humans and agents stop re-deriving it.

## When to use

- Modeling a new domain, or a request where the *nouns and verbs* aren't yet agreed.
- The user says "ubiquitous language", "bounded context", "aggregate", "domain
  model", "glossary", or "shared vocabulary".
- Code, tests, and product talk use different words for the same thing (drift), or one
  word means two things in two places (a missing context boundary).

## Workflow

1. **Extract the ubiquitous language.** List the domain's real terms with one-line
   definitions. Use those exact names in code, tests, commits, and conversation — no
   synonyms, no dev-only jargon for a domain concept.
2. **Persist the glossary.** Write it down (a `CONTEXT.md` / glossary artifact) so it
   survives the session and every human and agent shares it. An unpersisted vocabulary
   drifts by the next session and burns tokens re-explaining.
3. **Draw bounded contexts.** Where the same word means different things (a "Customer"
   in billing vs. support), split into separate models with an explicit translation at
   the seam. Don't force one god-model to serve every context.
4. **Model aggregates by identity, not nesting.** An aggregate is a consistency
   boundary referenced by id; hold other aggregates by id, not by embedding their
   object graph. Keep aggregates small — one invariant cluster each.
5. **Validate-then-act at the boundary.** Parse untrusted input into domain types with
   a schema (e.g. Zod in TS) at the edge, so the core only ever sees valid values.
   Invalid states shouldn't be representable past the boundary.
6. **Derive read models where it fits.** For audit-first domains, keep the write side
   as facts/events and derive query views (CQRS-ish) — don't overload one model for
   both reads and writes.

## Anti-patterns

- Anemic model: data bags plus a "service" layer that holds all the rules → the domain
  language lives nowhere and invariants leak everywhere.
- One shared model spanning contexts, so a single field means different things to
  different consumers → integration bugs at the seam.
- Fat aggregates that embed other aggregates' object graphs instead of referencing by
  id → unclear consistency boundaries and lock contention.
- Vocabulary that lives only in someone's head → drift; the next session invents new
  names for existing concepts.
- Trusting boundary input and validating deep in the core instead of validate-then-act
  at the edge.
- Renaming a domain concept in code but not in the glossary/tests (or vice versa) →
  the ubiquitous language stops being ubiquitous.

## Checklist

- [ ] Domain terms defined and used verbatim in code, tests, and conversation.
- [ ] Glossary persisted to a durable artifact, not just chat.
- [ ] Bounded contexts identified; shared terms translated at the seam.
- [ ] Aggregates reference each other by identity, not nesting; kept small.
- [ ] Boundary input validated (schema) before it reaches the core.
- [ ] Read models derived where auditability/CQRS pays off.
