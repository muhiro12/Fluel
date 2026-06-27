# AGENTS.md

Repository-specific agent contract for Fluel.

## Repository State

This repository now contains the initial rebuilt Apple app project alongside
the preserved product documentation and a small shared library package. Treat
`docs/` as the source of truth for product intent, and treat the Xcode project,
`FluelLibrary`, and `ci_scripts` as the current implementation and
verification surface.

Do not restore deleted legacy Swift code or make future feature architecture
decisions unless the current task explicitly asks for that phase.

## Repository Rules

- Use English for branch names, code comments, documentation, and identifiers
  unless UI localization or legal content requires otherwise.
- Follow the current repository structure and source style; keep
  documentation-only changes consistent with the surrounding docs.
- Keep public repository text product-centered, portable, and free from
  unnecessary solo-developer framing.
- Keep changes small, repository-local, and focused on durable product
  knowledge or the active rebuild task.
- Markdown must follow
  <https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md>.
- Swift code must comply with the repository SwiftLint configuration.
- Treat `docs/` as the source of truth for preserved product knowledge.

## Project Structure

- `Fluel.xcodeproj`: Xcode project for the app surface.
- `Fluel/`: app target source, assets, entitlements, and plist.
- `FluelLibrary/`: Swift package for durable entry domain logic,
  cross-surface value contracts, `*Operations`, and package tests.
- `ci_scripts/`: repository-owned shell entrypoints for non-runtime
  verification and fallback app builds.

## Target Responsibilities

The `Fluel` app target owns Apple surface concerns:

- SwiftUI screens, presentation state, navigation, sheets, and previews.
- App lifecycle and SwiftData `ModelContainer` setup, including the production
  CloudKit-backed configuration and preview/test in-memory configuration.
- SwiftData `@Model` adapter types and translation to or from
  `FluelLibrary` value contracts.
- Thin persistence adapters such as simple `@Query`, insert, and save calls
  while the app has only one surface.
- App Intents, App Shortcuts, and other system-surface adapters that call
  `FluelLibrary` Operations without reimplementing domain rules.
- App-local String Catalogs for SwiftUI, App Intents, and App Shortcuts.

The app target should not own durable entry rules, elapsed-time calculations,
start precision behavior, input validation, or cross-surface use cases.

`FluelLibrary` owns reusable product behavior:

- `StartPrecision`, `TimeTogetherSummary`, `EntryDraft`, `EntryInput`,
  `EntrySnapshot`, and `EntryOperations`.
- Domain validation, normalized start dates, approximate start semantics, and
  elapsed-time presentation values.
- Public `*Operations` facades that future App Intents, widgets, share
  extensions, watch targets, and app UI adapters can call.
- Repository-owned package tests for durable behavior.

Keep `FluelLibrary` Foundation-only until a concrete need justifies another
dependency. It must not import SwiftUI, SwiftData, MHUI, MHDesign, MHPlatform,
or app-runtime frameworks. Platform and persistence glue stays in the app or a
future surface adapter.

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
- `docs/rebuild-baseline.md`

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
- Treat CloudKit, App Intents, and English plus Japanese localization as
  standard rebuild baseline requirements, not release-end additions.
- Keep App Intents thin and backed by `FluelLibrary` Operations; do not add
  AppIntents or SwiftData dependencies to `FluelLibrary`.
- Start localization with the rebuild by using String Catalogs or equivalent
  target-owned resources for English and Japanese user-facing strings.
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
- Current shared library: Swift package `FluelLibrary`.
- Current widget and watch schemes: none.
- Current App Intents: included in the `Fluel` app target.
- Preferred compile check: XcodeBuildMCP `build_sim` with project
  `Fluel.xcodeproj`, scheme `Fluel`, configuration `Debug`, and an iOS 27
  simulator.
- Preferred package test check: `bash ci_scripts/tasks/test_library.sh`.
- Preferred Swift format check or autofix:
  `bash ci_scripts/tasks/format_swift.sh`.
- Preferred Swift lint check: `bash ci_scripts/tasks/lint_swift.sh`.
- Preferred retained repository-rule check:
  `bash ci_scripts/tasks/check_repository_rules.sh`.
- Preferred String Catalog audit from the repository root when the local
  `string-catalog-maintainer` skill is installed:

  ```sh
  codex_home="${CODEX_HOME:-$HOME/.codex}"
  audit_script="$codex_home/skills/string-catalog-maintainer/scripts/audit_xcstrings.py"
  python3 "$audit_script" \
    --project-root . \
    --required-locales en,ja \
    --format markdown
  ```
- Preferred non-runtime aggregate shell check:
  `bash ci_scripts/tasks/verify_task_completion.sh`.
- Current shell fallback:

  ```sh
  bash ci_scripts/tasks/build_app.sh
  ```

- General patch check: `git diff --check`.
- Retained repository-rule scripts:
  `ci_scripts/tasks/check_repository_rules.sh` and
  `ci_scripts/tasks/check_library_boundaries.sh`.

When public `FluelLibrary` APIs, `*Operations`, domain behavior, or tests
change, run the package tests and repository rules. Also run the app build when
the app target, SwiftData schema, package product links, or adapter-facing
contracts change.

When runtime, lifecycle, persistence container, navigation, visible UI,
localization, App Intents, or package-linking behavior changes, add
XcodeBuildMCP `build_run_sim`, runtime log review, and `screenshot` evidence.
For localization changes, capture English and Japanese screenshots when the UI
surface is affected. If UI automation or `snapshot_ui` is unavailable in the
active Xcode beta environment, use runtime logs, screenshots, and domain tests
as the fallback verification contract.

For documentation-only changes:

- Run `git diff --check`.
- Run Markdown linting when the tool is available.
- Review the affected docs for consistency with `docs/rebuild-handoff.md`.
