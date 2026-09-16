# Environment — discipline, not assumptions

The environment a session runs in is not guaranteed. Don't assume tool versions,
installed binaries, or running services — **detect, then act**, and say so when
something can't be verified. This file is portable discipline; concrete facts about a
specific machine belong in a per-machine local override (a `~/.claude/CLAUDE.md` or
machine memory), never in the shared standards.

## Runtime versions

- **Don't assume the default runtime is the right one.** The system `node` may be an
  EOL version. Prefer the project's pinned version (`.nvmrc`, `.tool-versions`,
  `engines`) and put it on `PATH` before running anything.
- Toolchains have version floors (modern Vite/Vitest need current Node). A mismatch
  shows up as `EBADENGINE` / "Unsupported engine" — treat that as "wrong runtime,"
  not a warning to ignore.
- Respect deliberate pins. If a repo pins an old version on purpose, do **not**
  upgrade it to make an error go away.

## Verify tooling exists before relying on it

- **Check `command -v <tool>` before using it.** A linter, scanner (e.g. semgrep),
  formatter, or CLI you expect may not be installed.
- **Browser/UI verification is fragile.** A headless-browser CLI can be broken by a
  system-library (GLIBC) mismatch or a corrupted binary download. Verify the browser
  tooling actually launches first; if it can't, drive the browser via a working
  library binary directly, or fall back to inspecting served HTML — and **say what
  couldn't be confirmed** rather than silently skipping a check.
- Don't re-download a large binary to "fix" it if an intact copy already exists —
  point at the good one.

## Services & data

- `ECONNREFUSED` almost always means the DB/server isn't running — start it first.
- Container runtimes may need a manual start (no systemd), and the shell may predate
  the group membership needed to talk to the daemon. Confirm the daemon is up.
- **One shared connection pool per service** — never open a second (connection-limit
  exhaustion).
- **Check module format (ESM vs CJS) before adding a dependency** — an ESM-only
  package won't load in a CJS runtime, and vice versa.
- **ORM footgun:** import the client from wherever it's actually generated/exported
  for that project; don't assume the default package path. Know which ORM a repo uses
  before writing a query.

## Destructive operations

- Some tools refuse destructive commands when invoked by an AI agent and demand
  explicit **user** consent (e.g. a DB migrate-reset guard). An agent/task
  authorization is **not** user consent — don't fake it. Prefer a non-destructive
  path (an idempotent, self-cleaning seed) and ask the user directly if a true reset
  is required. See [testing.md](./testing.md) → data/seed QA.

## Resource limits

- Heavy local workloads (DB + multiple dev servers + a browser + a test runner) can
  exhaust memory and freeze a constrained VM. Cap resources where possible and don't
  run everything at once when you don't need to.

## Related

- [testing.md](./testing.md) (running the real gate) · [cloud.md](./cloud.md)
  (deploy topology).
