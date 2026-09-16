---
name: perf-testing
description: Load and performance testing against a budget. Use when latency or
  throughput is a real requirement, when the user says "load test", "is it fast
  enough", "p95", "benchmark", or "does it scale", or when a perf budget should
  become a CI fitness function.
---

# Perf testing — assert against a budget, don't eyeball

Puts the performance-testing rule of [standards/testing.md](../../../standards/testing.md)
and the fitness-functions rule of [standards/architecture.md](../../../standards/architecture.md)
into practice. A number you eyeballed once on your laptop proves nothing; a budget
asserted under realistic load, and re-asserted in CI, keeps performance from decaying.

## When to use

- Latency/throughput is a stated requirement, or a change could regress a hot path.
- The user says "load test", "benchmark", "p95", "is it fast enough", or "will it scale".
- You want a perf budget encoded as a fitness function so regressions fail the build.

## Workflow

1. **Set the budget first.** Write down the target as an assertion, not a vibe: p95
   latency under load, min throughput, max bundle size, query count per request. A test
   without a threshold is a demo.
2. **Pick the tool for the seam.** `autocannon` for a quick HTTP throughput check; **k6**
   for scripted scenarios and thresholds; **Gatling** for rich, staged load profiles.
   Match the tool to the seam, not habit.
3. **Model realistic concurrency.** Ramp virtual users to a real target, use realistic
   think-time and payloads, and hit a representative dataset — not one warm row. Test
   the seam that matters (the endpoint/query users actually invoke), not a micro-bench of
   a pure helper.
4. **Assert, then read the shape.** Fail the run when the budget is breached (k6
   `thresholds`, Gatling assertions). Beyond pass/fail, read the p95/p99 tail and error
   rate — the mean hides the users who suffer.
5. **Wire budgets as CI fitness functions.** Keep the ones that matter (p95 latency,
   bundle size, query count) as gates in CI so a regression fails the build, not a
   user's request. Pair with the `ci-cd` skill.

## Anti-patterns

- Eyeballing a single run and calling it "fast enough" — no threshold, no proof.
- One-request or zero-think-time hammering that models nothing real.
- Benchmarking a pure helper while the real endpoint/query goes untested.
- Reporting only the mean; the tail (p95/p99) is where the pain lives.
- Testing against an empty/warm dataset that hides N+1s and cold-cache cost.
- A perf test that never runs again — a budget not in CI silently rots.

## Checklist

- [ ] Budget written as an explicit assertion (p95 / throughput / bundle / query count).
- [ ] Tool fits the seam (autocannon / k6 / Gatling).
- [ ] Realistic concurrency, think-time, payloads, and dataset.
- [ ] Run fails on budget breach; p95/p99 tail and error rate reviewed.
- [ ] The budgets that matter run as fitness functions in CI.
