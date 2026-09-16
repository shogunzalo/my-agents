---
name: ci-cd
description: Ship through the pipeline, never by hand. Use when setting up or fixing a
  deploy, when the user says "deploy", "the build is broken", "push to prod", or
  "set up CI", or whenever a change needs to reach an environment.
---

# CI/CD — deploy through the pipeline

Puts the deploy rules of [standards/cloud.md](../../../standards/cloud.md) and the Ship
stage of [standards/dev-flow.md](../../../standards/dev-flow.md) into practice. A deploy
that only works from one authed laptop is not a real deploy path — the pipeline is the
single door to every environment.

## When to use

- Wiring a new deploy, or a change needs to reach staging/prod.
- The user says "deploy", "ship it", "the build failed", or "set up CI/CD".
- A pipeline run is red and you're tempted to deploy manually to unblock.

## Workflow

1. **Push to main → the pipeline deploys.** Default to CI (GitHub Actions or
   equivalent) triggered by push to main. Do not run `gcloud run deploy` /
   `firebase deploy` / equivalent by hand — the whole team must get the same result.
2. **Fix forward, never sideways.** When a run is red, commit a fix forward; don't
   route around a broken pipeline with a manual deploy. Manual deploys mask the break
   and drift environments from the repo.
3. **Verify the build actually landed.** After pushing, confirm the run went green and
   the new revision is serving — don't assume a push equals a successful deploy.
4. **Keep the test gate in the pipeline, and never skip it.** Typecheck + tests are a
   required check that blocks the deploy; disabling or `--no-verify`-ing the gate to
   ship defeats its purpose (see [standards/testing.md](../../../standards/testing.md)).
5. **Authenticate CI with federated identity.** Use workload identity federation (WIF)
   / OIDC — never long-lived service-account keys stored as CI secrets. Run DB
   migrations as a pipeline step (through a proxy), not from a laptop.
6. **Bootstrap once from the CLI; codify the rest.** First-time infra (service
   accounts, WIF binding, registry, first bucket) may be one-shot CLI; the deploy
   itself lives as pipeline-as-code in the repo (pair with the `iac-terraform` skill).

## Anti-patterns

- Manual `deploy` from a laptop as the normal path — works for one person, not the team.
- Reacting to a red pipeline by deploying by hand instead of committing a fix forward.
- Assuming a push deployed without checking the run and the live revision.
- Commenting out / skipping the test gate to get a release out.
- Long-lived JSON key files in CI secrets instead of WIF/OIDC.
- Region-blind scheduler/service wiring — confirm regional availability before designing
  around a component (cloud.md).

## Checklist

- [ ] Deploy is triggered by push to main through the pipeline, not a manual command.
- [ ] Pipeline failures are fixed forward, not bypassed by a manual deploy.
- [ ] The build was verified as landed (green run + serving revision).
- [ ] Test/typecheck gate runs in CI and is not skipped or disabled.
- [ ] CI authenticates via WIF/OIDC; no long-lived keys committed or stored.
- [ ] One-time bootstrap is documented; the deploy path is pipeline-as-code in the repo.
