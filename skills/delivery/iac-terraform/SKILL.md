---
name: iac-terraform
description: Infrastructure as Code with Terraform. Use when provisioning or changing
  managed infra (services, IAM, buckets, schedulers, secrets wiring), when the user
  says "terraform", "provision", "add infra", or "codify this", or when infra that
  will be recreated or reviewed is currently click-ops.
---

# IaC / Terraform — codify reproducible infra

Puts the Infrastructure-as-Code section of [standards/cloud.md](../../../standards/cloud.md)
into practice. If infra will ever be recreated or needs review, it belongs in code —
click-ops is neither reviewable nor rebuildable.

## When to use

- Provisioning or changing managed infra: service definitions, IAM bindings, buckets,
  scheduler jobs, secrets wiring, registries.
- The user says "terraform", "provision", "codify", or "add infrastructure".
- You find existing infra was created by hand and it needs to be reproducible/reviewable.

## Workflow

1. **Draw the bootstrap line first.** One-time, one-way setup (the state backend
   itself, the first project/service account, the WIF/OIDC binding CI needs to run) may
   be bootstrapped from the CLI once. *Everything reproducible or reviewable* —
   services, IAM, buckets, schedulers, secrets wiring — is codified in Terraform.
2. **Configure remote, locked state before the first apply.** State lives in a remote
   backend (e.g. a bucket) with locking, so the team shares one source of truth and
   concurrent applies can't corrupt it. Never keep state on a laptop.
3. **Codify the resources.** Model each resource declaratively; wire secrets by
   *reference* to a secret manager, never by inlining the value. Parameterize
   environments with variables/workspaces rather than copy-pasted stacks.
4. **Plan and review before apply.** `terraform plan`, read the diff, and treat it like
   any code review — the plan is the change. Apply only the reviewed plan; let the
   pipeline apply on merge where the project runs IaC through CI (pair with `ci-cd`).
5. **Watch idle cost.** Flag any resource that accrues cost while idle before creating
   it; prefer scale-to-zero and don't leave dev instances running (cloud.md).

## Anti-patterns

- Click-ops in the console for anything that will be recreated or needs review.
- Committing `terraform.tfstate`, `.tfvars` with secrets, or plaintext credentials.
- Local-only state — no remote backend, no locking — so the team drifts.
- Inlining secret values instead of referencing a secret manager.
- `terraform apply` without reading the plan, or applying an unreviewed diff.
- Codifying the state backend into itself instead of bootstrapping it once.

## Checklist

- [ ] Bootstrap-once vs codify line is explicit; reproducible infra is in Terraform.
- [ ] State is remote and locked; no state file or secrets committed.
- [ ] Secrets are referenced from a secret manager, not inlined.
- [ ] `plan` was reviewed like code before `apply`; only the reviewed plan applied.
- [ ] Environments are parameterized, not copy-pasted.
- [ ] Idle-cost resources flagged before provisioning; scale-to-zero where possible.
