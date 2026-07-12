# Fluel

Fluel is a pre-release iOS app for quietly keeping time with the things and
places a person lives with.

This repository preserves the product intent from an earlier implementation
and now contains the rebuilt app project, a small shared library package, and
repository-owned verification scripts. Product knowledge that must guide the
rebuild is preserved under `docs/`.

## Documentation

Start here:

- `docs/product-brief.md`
- `docs/product-purpose.md`
- `docs/preserved-concepts.md`
- `docs/domain-concepts.md`
- `docs/user-workflows.md`
- `docs/user-experience-principles.md`
- `docs/product-language.md`
- `docs/rebuild-handoff.md`
- `docs/rebuild-implementation-principles.md`
- `docs/rebuild-baseline.md`

These documents describe what Fluel is, why it exists, what concepts and
language should survive, and what legacy implementation details should not be
carried forward automatically. The implementation-principles document captures
additional rebuild direction clarified after the preservation pass.

## Implementation Status

The current implementation surface is a rebuilt Xcode project:

- Project: `Fluel.xcodeproj`
- Scheme: `Fluel`
- App target: `Fluel`
- Shared package: `FluelLibrary`
- Repository verification scripts: `ci_scripts/tasks/`

The current app includes active and archived entries, entry creation, editing,
duplication, notes and photos, dashboard and timeline summaries, milestones,
presets, App Intents backed by `FluelLibrary` Operations, CloudKit-backed
SwiftData, and English plus Japanese localization. Further implementation work
should use the preserved product documents as the source of truth for Fluel's
domain, language, workflows, and experience principles.

## Development

Use Xcode 27 with an iOS 27 Simulator. Open `Fluel.xcodeproj` and select the
`Fluel` scheme, or run the repository checks from the command line:

```sh
bash ci_scripts/tasks/build_app.sh
bash ci_scripts/tasks/test_library.sh
bash ci_scripts/tasks/check_repository_rules.sh
```

Simulator development uses the repository's app configuration. Running on a
device or using the production CloudKit container requires your own development
team and matching bundle and iCloud container identifiers; update the Xcode
build settings, entitlements, and model-container configuration together.
