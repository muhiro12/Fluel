# Fluel

Fluel is an unfinished iOS product concept for quietly keeping time with the
things and places a person lives with.

This repository is between the documentation-preservation phase and a future
full rebuild. The legacy Xcode project and Swift implementation have been
removed from the active repository surface. Product knowledge that must
survive the rebuild is preserved under `docs/`.

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

No current Xcode project or Swift source should be treated as the product
implementation. A future rebuild will create a brand-new Xcode project using
the current Xcode and iOS SDK at that time.
