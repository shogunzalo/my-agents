---
name: user-journeys
description: Map the actual usage flow before building — who the user is, what they
  are trying to do, what they click, what the system does in response, and every state
  each step can be in. Use when planning a feature or product surface, when the user
  asks "how will people actually use this?", or when a UI's flows/states are unclear
  before implementation.
---

# User journeys — the usage flow, before code

Makes the real path through the product explicit so the spec, the UI, and the tests
all target what users actually do. Feeds [standards/dev-flow.md](../../../standards/dev-flow.md)
(Plan stage) and pairs with the `spec-driven` and `grill-me` skills; the `ux-engineer`
agent implements and verifies the flows this produces.

## When to use

- Planning any feature or new product surface with a user-facing flow.
- The user asks what people click, what does what, or how the thing is actually used.
- A UI exists but its flows, edge states, or navigation are fuzzy or undocumented.
- Before writing a spec — journeys are an input to it, not an afterthought.

## Workflow

1. **Name the actors.** Who uses this? (first-time vs returning, roles/permissions,
   the anonymous visitor, the admin). Pick the primary actor for the main journey.
2. **State the goal (job-to-be-done).** What is the actor trying to accomplish, in
   their words? Use the domain's ubiquitous language (see `ddd` skill).
3. **Find the entry points.** How does the actor arrive at this flow (deep link, nav,
   notification, empty state, redirect after auth)?
4. **Trace the happy path step by step.** For each step write: **trigger** (what the
   user does — click/type/drag/submit) → **system response** (what happens, what
   navigates, what persists) → **resulting state**. One row per step; keep it concrete
   ("clicks *Guardar*" not "user saves").
5. **Enumerate the states of each step.** For every screen/step, list its
   empty / loading / success / error / partial / permission-denied / offline states —
   not just the happy one.
6. **Branch the alternate and failure paths.** What happens on validation error,
   double-submit, expired session, no results, cancel, back-button, network failure?
   Where does each branch land the user?
7. **Mark the seams.** Note where a step crosses a boundary (API call, auth check,
   third-party, background job) — these become the integration tests and the ports.
8. **Hand off.** The journey feeds the spec (acceptance criteria come straight from
   the steps), the `ux-engineer` (flows, states, mobile/a11y), and `qa-engineer` (the
   real-behavior tests assert the trigger → system-response pairs end-to-end).

## Output shape

A short document per journey: actor + goal at the top, then a numbered
trigger → response → state table for the happy path, a states-per-step list, and an
alternate/failure-paths section. A simple text flow diagram is fine; prose beats a
picture nobody updates.

## Anti-patterns

- Mapping only the happy path — the states and failure branches are where the real
  work (and the bugs) live.
- Vague steps ("user manages settings") that can't become an acceptance criterion or a
  test.
- Designing screens before the flow — journeys drive the screens, not the reverse.
- Inventing personas the product doesn't have; keep actors real.
- Letting the journey rot after build — update it when the flow changes, or delete it.

## Checklist

- [ ] Primary actor + goal named in the domain's language.
- [ ] Entry points identified.
- [ ] Happy path as trigger → system response → state, one row per step.
- [ ] Every step's non-happy states enumerated.
- [ ] Alternate + failure paths traced to where the user lands.
- [ ] Boundary-crossing seams marked for integration tests.
- [ ] Handed to spec-driven / ux-engineer / qa-engineer as inputs.
