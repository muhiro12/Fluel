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
bash ci_scripts/tasks/run_required_builds.sh
bash ci_scripts/tasks/verify.sh
```

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
