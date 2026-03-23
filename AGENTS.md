# AGENTS.md

This document defines the repository-specific agent behavior contract for Fluel.
It keeps outer-architecture and workflow decisions explicit inside the repo.

## Agent Philosophy

- Follow the existing repository structure before introducing new layers.
- Prefer minimal, safe changes over broad refactors.
- Keep reusable entry logic in `FluelLibrary` when it is shared by the app or widget.
- Keep platform wiring and side effects in app-side or extension-side adapters.

## Naming and Language Rules

Use English for:

- Branch names
- Code comments
- Documentation
- Identifiers

Avoid non-English text unless required for UI localization or legal content.

## Markdown Guidelines

All Markdown files should follow:

https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md

## Repository Documentation Layout

Use these locations as the canonical documentation structure:

- `README.md` for repository onboarding and build/test entrypoints
- `Designs/Overviews/` for current product and architecture snapshots
- `Designs/Architecture/` for durable boundary and design guidance
- `Designs/Decisions/` for ADR-style architecture decisions

## Swift Code Guidelines

### Follow SwiftLint rules

All Swift code must comply with this repository's SwiftLint configuration.

### Use `.init(...)` when the return type is explicit

#### Preferred

```swift
var model: EntryWidgetSnapshot {
    .init(date: .now, snapshot: nil)
}
```

#### Not preferred

```swift
var model: EntryWidgetSnapshot {
    EntryWidgetSnapshot(date: .now, snapshot: nil)
}
```

### Multiline control-flow formatting

Do not use single-line bodies for control-flow statements or trailing closures.

## Build and Test Entry Points

Agents must use one of these standardized entrypoints:

```sh
bash ci_scripts/tasks/verify_task_completion.sh
bash ci_scripts/tasks/verify_repository_state.sh
```

Agents may run `bash ci_scripts/tasks/check_environment.sh --profile verify`
first to diagnose missing local prerequisites.
When Swift files are edited, agents should run
`bash ci_scripts/tasks/format_swift.sh` before the final verification gate.
`bash ci_scripts/tasks/verify_task_completion.sh` is the non-destructive
verification gate.
`bash ci_scripts/tasks/verify_pre_commit.sh` reruns the same non-destructive
verification shell for manual final checks and `.pre-commit-config.yaml`.
SwiftLint is resolved from the `SimplyDanny/SwiftLintPlugins` package declared
in `Fluel.xcodeproj`, not from a separately installed `swiftlint` binary.
By default, `format_swift.sh` and `lint_swift.sh` operate on local Swift
changes. Set `CI_SWIFTLINT_ALL=1` when you need a full tracked-file sweep.


Optional single-purpose entrypoints:

```sh
bash ci_scripts/tasks/build_app.sh
bash ci_scripts/tasks/test_shared_library.sh
```

## CI Artifact Layout

CI run artifacts are written under `.build/ci/runs/<RUN_ID>/`.
Each run stores `summary.md`, `commands.txt`, `meta.json`, `logs/`, `results/`,
and `work/`.
Shared CI directories are under `.build/ci/shared/` (`cache/`,
`DerivedData/`, `tmp/`, `home/`).
Only the newest 5 run directories are retained.
The entire `.build/ci` directory is disposable.

## Screen State Rules

- Keep screen-scoped `@Observable` presentation models, routers, and
  coordinators in the app target.
- Root views should own those models in `@State` and pass them downward with
  typed environment values or `@Bindable`.
- Do not keep large collections of search, filter, dialog, sheet, and error
  state directly on large feature views when a screen model can own them.

## Adapter Failure Rules

- Primary mutation failures must block success and stay visible to the current
  caller.
- Post-commit follow-up failures are degraded-success cases. Preserve the
  committed domain write, log the failure phase explicitly, and surface a
  repairable notice when practical.
- Do not collapse adapter failure phases into one generic success path.
