# Cloud — deploy, infra, and cost

## Deploy through the pipeline, never by hand

> "Deploys should happen through the pipeline and with code, not manually — things
> should work for the whole team. When we push to main, we deploy."

- **Push to main → CI/CD deploys.** Default to a pipeline (GitHub Actions or
  equivalent) triggered by push to main.
- **Fix pipeline failures by committing forward, not by deploying manually.** A
  deploy that only works from one authed laptop is not a real deploy path.
- One-time **infra bootstrap** (service accounts, federated CI auth, secrets, first
  bucket/registry) may be done from the CLI — but the deploy itself must be code in
  the repo.
- After pushing, **verify the build actually landed** — don't assume the push
  triggered a successful deploy.

## Topology (a typical shape)

- **Backends:** build a container → push to a registry → deploy to a managed runtime
  (e.g. Cloud Run / equivalent), authenticated from CI via federated identity (WIF),
  not long-lived keys. Run DB migrations through a proxy as a pipeline step.
- **Static / SSR front-ends:** static export to a CDN/host, or a hosting layer that
  rewrites to the container runtime for SSR routes.
- **Cron / scheduled work:** confirm the scheduler service is available in your target
  region *before* designing around it — regional service availability varies; a
  component may only exist in a neighboring region.
- Vendored `file:` tarball deps must be `COPY`'d before the install step in the
  Dockerfile.

## Infrastructure as Code / Terraform

- Prefer **IaC for anything reproducible** — service definitions, IAM, buckets,
  scheduler jobs, secrets wiring — so infra is reviewable and rebuildable, not
  click-ops. Terraform is the default when a project needs managed infra state.
- Keep state remote and locked; never commit state or secrets.
- The line between "bootstrap from CLI once" and "codify in the pipeline": if it will
  ever be recreated or needs review, it belongs in code.

## Cost-consciousness

Watch cloud spend actively — idle resources are the common surprise on a small
budget.

- **Scale to zero** where possible (min-instances 0 for low-traffic services).
- Don't leave dev/prod DB instances or VMs running idle; stop shared instances when
  unused.
- **Flag anything that will accrue cost while idle *before* provisioning it.**

## Related

- [dev-flow.md](./dev-flow.md) (Ship stage) · [environment.md](./environment.md)
  (services, proxies) · [house-rules.md](./house-rules.md) (never commit secrets).
