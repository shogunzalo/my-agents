# House rules — non-negotiables

The rules that apply to **every** task, every project, every agent. If a rule here
conflicts with a project's local `CLAUDE.md`, the local file wins for that repo —
but assume these hold unless told otherwise.

## Language & copy

- **Client-facing Spanish is Chilean Spanish (es-CL), tuteo.** (This is the owner's
  locale default; adjust per project if a repo targets a different market.)
- **Never use Argentinisms.** No voseo (`tenés`/`querés` → `tienes`/`quieres`), no
  `che`/`pibe`/`boludo`/`quilombo`/`laburo`/`birome`/`pochoclo`/`colectivo`,
  no `casaca`/`remera` (use `camiseta`/`polera`). When unsure whether a word is
  Chilean or Argentine, pick the neutral option. This one is emphatic.
- **Code, comments, commits, and identifiers are in English.** Only user-visible copy
  and LLM-facing prompt text is localized.

## Communication style

- **No emojis** in communication, commits, or code.
- Be direct. Surface tradeoffs, don't hide confusion. Decide, don't dither.
- Report outcomes faithfully: if tests fail, say so with the output; if a step was
  skipped, say that.

## Tooling

- **npm only** for JS/TS — never yarn or pnpm. A stray `yarn.lock`/`pnpm-lock.yaml`
  is cruft, not a signal. Don't run `npm install` unless genuinely adding a dep.
- **uv** for Python (ruff, pytest). **cargo** for Rust.
- **TypeScript strict, no `any`.** Prefer `unknown` + narrowing; mind
  `noUncheckedIndexedAccess`. Read the *installed* framework docs — recent
  Next/React/Expo differ from training data.

## Product defaults

- **Dark mode first**, with light + follow-system options. Give every app a
  distinctive visual identity via design tokens — avoid the generic AI-app look (see
  [architecture.md](./architecture.md) → visual system).
- **Multi-platform reuse:** design apps so logic can move web → React Native →
  Electron via shared packages. Keep platform-specific I/O at the edges.
- **Greenfield best-of-breed** over reusing legacy code, when starting fresh.

## Git safety

- **Never push, force-push, or open PRs unless explicitly asked.**
- **Always `git pull`/rebase before starting work** — avoid the avoidable merge
  conflict: *"there are conflicts, did you pull? You should always pull."*
- **Never commit secrets.** No tokens, keys, or `.env` files in git.

## Related

- [dev-flow.md](./dev-flow.md) — how these fold into the lifecycle.
- [architecture.md](./architecture.md) — the visual-system detail behind "product
  defaults".
