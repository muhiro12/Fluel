# AGENTS.md

Repository-specific agent contract for Fluel.

## Repository State

This repository now contains the initial rebuilt Apple app project alongside
the preserved product documentation. Treat `docs/` as the source of truth for
product intent, and treat the Xcode project as the current implementation
surface.

Do not restore deleted legacy Swift code, add CI scaffolding, or make future
architecture decisions unless the current task explicitly asks for that phase.

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

Implementation-direction constraints clarified after product preservation live
in `docs/rebuild-implementation-principles.md`. Read that document before
starting rebuild implementation or setup work.

When changing documentation, preserve the existing boundary:

- Preserve product vision, purpose, user value, concepts, workflows, language,
  tone, and rebuild handoff knowledge.
- Do not preserve deleted implementation structure, type names, persistence
  details, old target boundaries, old CI scripts, or technical workarounds as
  rebuild requirements.
- Do not turn the documentation into an implementation plan unless the user
  explicitly starts the rebuild planning phase.

## Rebuild Boundary

During implementation work:

- Read `docs/rebuild-implementation-principles.md` before making setup,
  package, OS-baseline, design-system, or app-surface decisions.
- Treat Fluel as a focused Apple app for an AI-assisted platform future: the
  app owns a clean domain and exposes reliable structured surfaces without
  becoming a broad platform or generic AI chat app.
- Use Apple, Swift, SwiftUI, HIG, and official Apple framework guidance as
  primary platform constraints.
- Use `apple-ios-dev-flow` for ordinary Apple-platform implementation work
  when the skill is available.
- Use Origami and Incomes as the highest-priority app references, with Incomes
  as the frontier app reference for applied Apple app architecture. Adapt
  intent rather than copying domain-specific or stale structure.
- Use the Incomes package posture unless a Fluel-specific constraint requires
  a documented exception. This includes MHPlatform, MHUI, and project-declared
  SwiftLintPlugins usage once a project exists.
- Use MHUI with the full current SDK capabilities available to the rebuild.
- Treat the intended minimum support baseline as the iOS 27 family unless the
  user explicitly revises it.
- Prefer a shared-library-first shape for durable business logic if the new
  implementation grows across app, widget, intent, watch, or other delivery
  surfaces.
## Apple Verification Contract

Use the Incomes/Cookle verification posture unless the new repository shape
gives a stronger reason to diverge:

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
## Current Verification

The active Xcode project is `Fluel.xcodeproj`.

- App scheme: `Fluel`.
- Active app target: `Fluel`.
- Current shared-library, widget, watch, and intent schemes: none.
- Preferred compile check: XcodeBuildMCP `build_sim` with project
  `Fluel.xcodeproj`, scheme `Fluel`, configuration `Debug`, and an iOS 27
  simulator.
- Current shell fallback:

  ```sh
  xcodebuild \
      -project Fluel.xcodeproj \
      -scheme Fluel \
      -configuration Debug \
      -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
      build
  ```

- Swift lint check: `swiftlint lint --strict --no-cache`.
- General patch check: `git diff --check`.
- Retained repository-rule scripts: none.

For documentation-only changes:

- Run `git diff --check`.
- Run Markdown linting when the tool is available.
- Review the affected docs for consistency with `docs/rebuild-handoff.md`.
