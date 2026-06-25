# Fluel

Fluel is an unfinished Apple-platform product concept for quietly keeping time
with the things and places a person lives with.

This repository preserves the product intent from an earlier implementation
and now contains the initial rebuilt app project. The legacy Xcode project,
Swift implementation, widget, shared library, and CI scripts have been removed
from the active repository surface. Product knowledge that must guide the
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

These documents describe what Fluel is, why it exists, what concepts and
language should survive, and what legacy implementation details should not be
carried forward automatically. The implementation-principles document captures
additional rebuild direction clarified after the preservation pass.

## Rebuild Status

The current implementation surface is a minimal rebuilt Xcode project:

- Project: `Fluel.xcodeproj`
- Scheme: `Fluel`
- App target: `Fluel`
- Shared package: `FluelLibrary`
- Repository verification scripts: `ci_scripts/tasks/`

The project is an early SwiftUI and SwiftData scaffold, not a complete product
implementation. Future implementation work should use the preserved product
documents as the source of truth for Fluel's domain, language, workflows, and
experience principles.
