---
name: grill-me
description: User-invoked orchestrator (/grill-me) — the pre-code interview. Use when
  the user runs "/grill-me", says "grill me", "interview me", "ask me the hard
  questions", "poke holes before I build", or when a request is vague/ambiguous and
  you must surface intent, assumptions, and tradeoffs before writing anything. Produces
  a shared understanding, not code.
---

# grill-me — interview the problem before code

Executes the **Think** stage of [standards/dev-flow.md](../../../standards/dev-flow.md):
turn a vague request into verifiable success criteria by asking forcing questions.
The output is a short shared understanding, **not code** — this stage never
implements.

## When to use

- Before Plan (`spec-driven`), whenever the request is fuzzy, large, or assumption-laden.
- The user runs `/grill-me`, or says "grill me", "interview me", "ask the hard
  questions", "poke holes in this".
- You (the agent) notice you're guessing — stop and grill instead of building on a
  guess.

## Workflow

1. **What is the actual user action?** Name the concrete thing a real user does and
   the outcome they see. If it can't be stated in one sentence, that's the first gap.
2. **What's the smallest slice that proves it?** Force a thin vertical slice — the
   minimum that demonstrates the value end-to-end. Defer everything else.
3. **What could break?** Edge cases, failure modes, concurrency, auth, empty/nil,
   the unhappy paths. Enumerate the risks now, cheaply.
4. **What's explicitly out of scope?** Draw the boundary out loud so scope creep has
   nowhere to hide. "Not doing X this round" is a first-class answer.
5. **Surface every assumption and tradeoff.** State what you're assuming and the
   forks in the road (this vs. that, and why). **Don't hide confusion** — an
   unspoken doubt becomes a shipped bug.
6. **Converge on a shared understanding.** Write it down: intent, success criteria,
   smallest slice, risks, out-of-scope. Hand this to `spec-driven` (Plan) — do not
   write code here.

## Anti-patterns

- Answering your own questions to look decisive — a confident guess is still a guess.
- Hiding confusion or ambiguity to keep momentum; it re-emerges as rework.
- Jumping to implementation (or a full design) mid-interview — Think ends before code
  and before the spec.
- Vague success criteria you can't test ("make it better", "handle errors").
- Leaving scope open — no stated out-of-scope means unbounded work.
- Interrogating a truly trivial one-liner into paralysis; match the grilling to the
  risk.

## Checklist

- [ ] The actual user action is named in one sentence.
- [ ] The smallest slice that proves it is identified.
- [ ] Failure modes / "what could break" enumerated.
- [ ] Out-of-scope stated explicitly.
- [ ] Assumptions and tradeoffs surfaced, not hidden.
- [ ] Verifiable success criteria written down.
- [ ] Output is a shared understanding, not code — ready to feed `spec-driven`.
