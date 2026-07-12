# Rebuild Handoff

## Purpose Of This Handoff

This handoff was created before the legacy Xcode project and source code were
removed. It preserved the product knowledge that had to survive that cleanup.

The legacy cleanup and initial rebuild are now complete. This document remains
historical product-intent evidence and does not authorize deletion of the
current rebuilt implementation.

## Documentation Set

These files formed the preservation set and remain product references for
current implementation work:

- `docs/product-brief.md`
- `docs/product-purpose.md`
- `docs/preserved-concepts.md`
- `docs/domain-concepts.md`
- `docs/user-workflows.md`
- `docs/user-experience-principles.md`
- `docs/product-language.md`
- `docs/rebuild-handoff.md`

After the preservation pass, implementation-direction constraints were added
to:

- `docs/rebuild-implementation-principles.md`
- `docs/rebuild-baseline.md`

Together, they answer:

- What the product is.
- Why it exists.
- What problem it solves.
- What concepts must survive.
- What product language must survive.
- What workflows must survive.
- What experience principles must survive.
- What should be discarded with the old implementation.

The implementation-principles document additionally records rebuild direction
for platform posture, reference projects, package alignment, OS baseline, and
AI-era app shape.

## Evidence Used

Product knowledge was extracted from:

- Existing product overview and README material.
- User-facing localization strings.
- Completed legacy string catalogs for English, Japanese, Spanish, French, and
  Simplified Chinese (`zh-Hans`).
- Entry, timeline, dashboard, preset, settings, and widget copy.
- Sample data and starter examples.
- Unit tests that encode user-visible behavior and edge cases.
- Commit history, especially the prototype and persistent v1 milestones.
- Asset catalogs, which did not contain meaningful product-specific imagery.

Architecture records were inspected only to separate product intent from
technical structure.

## Preserved Product Center

The rebuild should preserve this center:

Fluel quietly keeps time with the things and places the user lives with.

Everything else should be evaluated against that center.

## Legacy Details That Were Safe To Discard

During the completed legacy cleanup, these implementation details did not need
to be carried forward automatically:

- Existing Xcode project structure.
- Existing app, library, and widget target boundaries.
- Existing source directories and file names.
- Existing type, property, function, and parameter names.
- Existing SwiftUI hierarchy.
- Existing state-management patterns.
- Existing persistence model and storage implementation.
- Existing widget implementation.
- Existing package dependencies.
- Existing CI and repository-boundary scripts.
- Existing debug, diagnostics, preview, and capture infrastructure.
- Existing architecture decision records that describe code placement.

They were not rebuild requirements merely because they existed in the legacy
repository. This statement does not apply to the current rebuilt
implementation.

## Must Not Be Lost

Before the legacy source was deleted, these product ideas had to be preserved
in docs. They remain requirements for the current implementation:

- Fluel's purpose as a quiet time-with-things-and-places product.
- Entry as one thing or place the user lives with.
- Entry titles as required, non-empty user-facing names.
- Start precision: day, month, or year.
- Honest approximate starts.
- Time together as the central display concept.
- Active versus archived entries.
- Notes and photos as optional memory context.
- Longest together as the primary active-list emphasis.
- Archive, restore, and deliberate permanent delete.
- Dashboard overview.
- Timeline history with added, updated, and archived activity.
- Upcoming yearly milestones.
- Presets as reusable starting points.
- Gentle tips and empty states.
- Display-density preferences.
- Widget-style glance for the longest-running active entry.
- The product language and tone captured in `docs/product-language.md`.
- The legacy localization scope of English, Japanese, Spanish, French, and
  Simplified Chinese (`zh-Hans`).

## Rebuild Boundary

This preservation handoff did not decide:

- App architecture.
- Target structure.
- Persistence technology.
- UI framework details.
- Design-system adoption.
- Widget technology.
- Testing strategy.
- Release plan.
- New features.

Those decisions were made separately as the rebuilt implementation took shape.
The confirmed implementation posture is recorded in
`docs/rebuild-implementation-principles.md` and `docs/rebuild-baseline.md`;
neither document makes the legacy implementation a blueprint.

## Final Audit Result

The preservation pass found no additional product-specific meaning in assets
beyond placeholder icon and accent metadata. A follow-up audit also preserved
legacy localization scope, the non-empty entry title rule, and `Desk lamp` as
archived sample vocabulary. The important source-only product knowledge has
been extracted into the docs listed above.

If a later audit uncovers unreviewed private notes, screenshots, or external
planning artifacts that are not present in this repository, audit them
separately before making related product decisions.
