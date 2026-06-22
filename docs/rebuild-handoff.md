# Rebuild Handoff

## Purpose Of This Handoff

This repository is expected to lose its existing Xcode project and source code
in a future manual phase. The rebuild itself is not part of this task.

These documents preserve the product knowledge that should survive deletion of
the legacy implementation.

## Documentation Set

Read these files before any future rebuild work:

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

## Safe To Discard In The Future Manual Phase

The future manual cleanup phase may delete the legacy implementation without
preserving these details:

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

Do not carry these forward merely because they exist today.

## Must Not Be Lost

The source code should not be deleted until these product ideas are preserved
in docs:

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

This handoff does not decide:

- App architecture.
- Target structure.
- Persistence technology.
- UI framework details.
- Design-system adoption.
- Widget technology.
- Testing strategy.
- Release plan.
- New features.

Those are future decisions after the legacy implementation has been removed.
Some implementation-direction constraints have since been recorded in
`docs/rebuild-implementation-principles.md`; use that document for the
confirmed rebuild posture without treating the legacy implementation as a
blueprint.

## Final Audit Result

The preservation pass found no additional product-specific meaning in assets
beyond placeholder icon and accent metadata. A follow-up audit also preserved
legacy localization scope, the non-empty entry title rule, and `Desk lamp` as
archived sample vocabulary. The important source-only product knowledge has
been extracted into the docs listed above.

If future manual deletion uncovers unreviewed private notes, screenshots, or
external planning artifacts that are not present in this repository, those
should be audited separately before deletion.
