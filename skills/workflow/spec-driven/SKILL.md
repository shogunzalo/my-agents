---
name: spec-driven
description: User-invoked orchestrator (/spec) that turns a vague intent into an
  executable spec before any code. Use when the user runs "/spec", says "spec this
  out", "write the plan first", "design before code", or when a non-trivial feature
  needs a reviewable plan artifact (contracts, edge cases, acceptance criteria,
  dependency order) with a gate before implementation.
---

# spec-driven — plan before code

Executes the **Plan** stage of [standards/dev-flow.md](../../../standards/dev-flow.md):
write the design down so a fresh reader or agent can implement it, instead of
vibe-coding. Design intent lives in a durable artifact; shape follows
[standards/architecture.md](../../../standards/architecture.md).

## When to use

- Anything non-trivial — more than a one-file surgical edit — before Build starts.
- The user runs `/spec`, or says "spec it out", "plan first", "design before code".
- Coming out of a `/grill-me` (Think) with a shared understanding but no plan yet.
- Skip for a genuine one-liner; a spec that costs more than the change is waste.

## Workflow

1. **Overview + approach.** One paragraph: the user-facing outcome and how you'll get
   there. If you can't state the outcome plainly, go back to Think (`grill-me`).
2. **Data models / API contracts.** Types, schemas, endpoints, request/response
   shapes. Validate-then-act at the boundary (Zod-style). This is the part agents
   drift on — pin it down.
3. **Edge cases + failure modes.** Empty/nil, concurrency, auth, partial failure,
   the "what could break" list from Think. Name them; decide behavior for each.
4. **Acceptance criteria.** Verifiable "done" statements — each one a test you could
   write (feeds the `tdd` skill in Test).
5. **Dependency order.** Slice into vertical steps and order them so each builds on a
   landed, tested predecessor. No big-bang.
6. **Persist shared vocabulary + ADRs.** Record the domain terms (ubiquitous
   language → `CONTEXT.md`/glossary, per architecture.md) and any decision worth its
   alternatives as a lightweight ADR (decision, context, options, why). So the next
   session doesn't re-derive or re-argue it.
7. **Review gate.** Stop. The human (or reviewing agent) approves the spec *before*
   code. Building past an unreviewed spec defeats the point.

**Simplicity first:** spec only what was asked. No speculative abstraction, no
"while we're here." Name the scale trigger instead of pre-building for it
(architecture.md).

## Anti-patterns

- Spec as fiction — a plan so vague it can't be executed or reviewed (no contracts,
  no acceptance criteria). It looks like planning; it isn't.
- Speculative architecture: interfaces, layers, or config for a scale that hasn't
  arrived. Simplicity first — name the trigger.
- Writing code during the spec, then back-filling the doc. That's vibe-coding with a
  paper trail.
- Skipping the review gate — nobody reads it, so it drifts from the code immediately.
- Re-inventing vocabulary each session because the last one was never persisted.
- Boiling the ocean: one giant plan instead of an ordered set of small slices.

## Checklist

- [ ] Overview + approach a fresh agent could execute.
- [ ] Data models / API contracts explicit (types, schemas, endpoints).
- [ ] Edge cases and failure modes enumerated with decided behavior.
- [ ] Acceptance criteria written as verifiable, test-shaped statements.
- [ ] Work sliced and ordered by dependency (no big-bang).
- [ ] Shared vocabulary persisted; non-obvious decisions captured as ADRs.
- [ ] Simplicity held: nothing beyond what was asked; scale triggers named.
- [ ] Spec reviewed and approved before implementation begins.
