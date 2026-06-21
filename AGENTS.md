# AGENTS.md

Repository-specific agent contract for Fluel.

## Repository State

This repository currently preserves product documentation for a future full
rebuild. The legacy Xcode project and Swift implementation are not part of the
active repository surface.

Treat this repository as a product-intent archive until a new project is
explicitly created. Do not recreate an Xcode project, implement features,
restore deleted Swift code, add CI scaffolding, or make future architecture
decisions unless the current task explicitly asks for that phase.

## Repository Rules

- Use English for branch names, code comments, documentation, and identifiers
  unless UI localization or legal content requires otherwise.
- Follow the current repository structure and source style once implementation
  files exist; keep documentation-only changes consistent with the surrounding
  docs while the repository remains docs-only.
- Keep public repository text product-centered, portable, and free from
  unnecessary solo-developer framing.
- Keep changes small, repository-local, and focused on durable product
  knowledge or the active rebuild task.
- Markdown must follow
  <https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md>.
- Swift code must comply with the repository SwiftLint configuration once
  Swift source is reintroduced.
- Treat `docs/` as the source of truth for preserved product knowledge.

## Documentation Contract

The current authoritative product documents are:

- `docs/product-brief.md`
- `docs/product-purpose.md`
- `docs/preserved-concepts.md`
- `docs/domain-concepts.md`
- `docs/user-workflows.md`
- `docs/user-experience-principles.md`
- `docs/product-language.md`
- `docs/rebuild-handoff.md`

When changing documentation, preserve the existing boundary:

- Preserve product vision, purpose, user value, concepts, workflows, language,
  tone, and rebuild handoff knowledge.
- Do not preserve deleted implementation structure, type names, persistence
  details, old target boundaries, old CI scripts, or technical workarounds as
  rebuild requirements.
- Do not turn the documentation into an implementation plan unless the user
  explicitly starts the rebuild planning phase.

## Future Rebuild Boundary

When a future task explicitly starts a new implementation phase:

- Use Apple, Swift, SwiftUI, HIG, and official Apple framework guidance as
  primary platform constraints.
- Use `apple-ios-dev-flow` for ordinary Apple-platform implementation work
  when the skill is available.
- Use Incomes as the frontier app reference for applied Apple app architecture
  and Cookle as the next app-repository baseline, but adapt intent rather than
  copying domain-specific or stale structure.
- Prefer a shared-library-first shape for durable business logic if the new
  implementation grows across app, widget, intent, watch, or other delivery
  surfaces.
- After a new Xcode project exists, update this `AGENTS.md` with the concrete
  schemes, package names, XcodeBuildMCP verification expectations, retained
  repository rule checks, and any real architecture boundaries.

## Future Apple Verification Contract

Once a new Xcode project, Swift package, or Apple-platform implementation is
created, use the Incomes/Cookle verification posture unless the new repository
shape gives a stronger reason to diverge:

- Agents MUST prefer XcodeBuildMCP for Apple build, test, run, Simulator,
  runtime log, screenshot, and UI snapshot verification.
- Before the first XcodeBuildMCP build, test, or run call in a session, run
  XcodeBuildMCP `session_show_defaults`. If defaults do not point at this
  repository, set them for the current session before continuing.
- Treat shared-library tests, app or surface builds, retained repository-rule
  checks, and runtime/UI evidence as separate capabilities.
- Choose the smallest verification set that proves the current change, and
  prefer stronger evidence when public APIs, shared contracts, SwiftData
  schema, app lifecycle wiring, widget or App Intent behavior, or visible UI
  behavior are affected.
- Keep durable business logic and repository-owned unit tests in the shared
  library when the rebuilt app has one. App, widget, intent, watch, and other
  delivery surfaces should stay responsibility-thin adapters.
- Use `*Operations`-style shared-library facades for cross-surface business
  use cases when the rebuilt implementation grows beyond a single app surface.
- For Swift edits, run the repository's Swift formatter or SwiftLint autofix
  entrypoint once it exists. Prefer a project-declared SwiftLint plugin over a
  separately installed `swiftlint` binary.
- Retain shell scripts only for SwiftLint/autofix, static repository rules,
  compatibility wrappers, optional audits, or checks not naturally covered by
  XcodeBuildMCP.
- After schemes exist, name the concrete app, shared-library, widget, watch,
  and intent verification commands here. Do not leave placeholder scheme names
  in this file after the project is created.

## Current Verification

There is no active Xcode build, Swift package test suite, or retained CI script
entrypoint after the legacy implementation removal.

For documentation-only changes:

- Run `git diff --check`.
- Run Markdown linting when the tool is available.
- Review the affected docs for consistency with `docs/rebuild-handoff.md`.

Do not run stale XcodeBuildMCP schemes or old shell verification commands until
a new project and repository contract are created.
