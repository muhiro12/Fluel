# UI Preview Report

## Purpose

This report summarizes the current Fluel UI preview and screenshot coverage.
It is preparation for a later MHUI and MHDesign adoption pass, not a product
feature expansion.

## Target Screens

Confirmed existing app screens:

- Active entries empty state.
- Active entries with entries.
- Entry detail.
- Archive.
- Dashboard.
- Timeline.
- Milestones.
- Presets.
- Add and edit entry.

Not covered as a screen:

- Settings: documented as a future product surface, but not implemented in the
  current app target.
- Widget-style glance: documented as a future surface, but not implemented in
  the current app target.

Component preview retained:

- Entry row, using `EntryRowView`.

## Preview Support

Preview data now lives in app-target preview support:

- `Fluel/PreviewSampleData.swift`
- `Fluel/PreviewSampleData+Support.swift`
- `Fluel/PreviewSampleData+Entries.swift`
- `Fluel/PreviewSampleData+Drafts.swift`
- `Fluel/PreviewSampleData+Presets.swift`

The sample data follows the product language in
`docs/product-language.md`: This home, Notebook, Watch, Wallet, Bag, Plant,
Furniture, and Desk lamp.

Supported preview scenarios:

- `empty`
- `typical`
- `dense`
- `archive`
- `presets`

Runtime screenshot support is available through launch arguments:

```sh
--fluel-ui-preview-screen activeEntries
--fluel-ui-preview-screen dashboard
--fluel-ui-preview-screen timeline
--fluel-ui-preview-screen milestones
--fluel-ui-preview-screen presets
--fluel-ui-preview-screen archive
--fluel-ui-preview-screen entryDetail
--fluel-ui-preview-screen archivedEntryDetail
--fluel-ui-preview-screen entryEditor
--fluel-ui-preview-scenario empty
--fluel-ui-preview-scenario dense
```

These launch arguments use an in-memory `ModelContainer` and do not change the
normal persistent app container.

## Preview Coverage

Added or confirmed screen-level previews:

- `ContentView`
  - Active entries - empty
  - Active entries - typical
  - Active entries - dense, large type
  - Active entries - dark
- `ArchiveEntryListView`
  - Archive - empty
  - Archive - archived entries
- `EntryDetailView`
  - Entry detail - typical
  - Entry detail - archived
  - Entry detail - long text, large type
- `EntryEditorView`
  - Add entry - empty
  - Edit entry - filled
  - Edit entry - long text, dark
- `DashboardView`
  - Dashboard - empty
  - Dashboard - typical
  - Dashboard - dense
- `TimelineView`
  - Timeline - empty
  - Timeline - typical
  - Timeline - dense
- `MilestonesView`
  - Milestones - empty
  - Milestones - upcoming
- `PresetsView`
  - Presets - starter presets
  - Presets - custom and default

## Screenshots

Captured runtime screenshots:

- `docs/ui-preview-screenshots/active-entries-empty.jpg`
- `docs/ui-preview-screenshots/active-entries-dense.jpg`
- `docs/ui-preview-screenshots/dashboard-dense.jpg`
- `docs/ui-preview-screenshots/timeline-dense.jpg`
- `docs/ui-preview-screenshots/milestones-upcoming.jpg`
- `docs/ui-preview-screenshots/archive-entries.jpg`
- `docs/ui-preview-screenshots/presets-custom-default.jpg`
- `docs/ui-preview-screenshots/entry-detail-typical.jpg`
- `docs/ui-preview-screenshots/entry-detail-archived.jpg`
- `docs/ui-preview-screenshots/entry-editor-long-text.jpg`

All screenshots were captured on iPhone 17 Pro Simulator at 368 x 800.

## Confirmed States

Confirmed through previews and screenshots:

- Empty active list.
- Active list with multiple entries.
- Dense list data with long title wrapping.
- Entry rows with note, photo metadata, and approximate-start badges.
- Entry detail with typical month-precision data.
- Entry detail for an archived entry.
- Add-entry form with empty draft.
- Edit-entry form with filled and long-note drafts.
- Archive list with archived entries.
- Dashboard overview with active, archived, note, and photo counts.
- Timeline summary, upcoming milestones, and monthly activity.
- Milestones list.
- Presets with starter, pinned, recent, custom, and default states.
- Dark mode for active entries and edit-entry previews.
- Large Dynamic Type previews for active entries and entry detail.

## Unconfirmed States

Not confirmed or only partially confirmed:

- Settings, because the screen is not implemented.
- Widget-style glance, because the surface is not implemented.
- Direct Xcode Preview image capture, because the available XcodeBuildMCP
  tools did not expose a dedicated Preview renderer.
- Semantic UI snapshot and tap traversal, because `snapshot_ui` failed in the
  local Xcode beta environment with missing `SimulatorKit.framework`.
- Destructive confirmation dialog rendering, because semantic tap traversal was
  unavailable. The archived detail preview confirms the destructive action
  entry point is visible.
- Error alerts for save, archive, and restore failures, because no failure
  injection seam exists for those app-side adapters.
- Full photo display, because current UI exposes photo presence as metadata
  rather than rendering image content.

## UI Tone

The current copy mostly matches Fluel's quiet, familiar, low-pressure tone.
The empty state is gentle and starts with one entry. Sample data uses ordinary
things and places rather than inventory or productivity language.

The denser active list still feels more tool-like than calm because many
navigation actions sit in the leading toolbar at once. This is visible in the
active-entry screenshots and should be handled before broad MHUI polishing.

## MHUI And MHDesign Opportunities

Highest-priority candidates:

- Main navigation chrome: the active screen currently exposes Dashboard,
  Timeline, Milestones, Presets, and Archive as separate leading toolbar
  icons. This is cramped on iPhone and should move to a calmer native
  navigation pattern before detailed visual polish.
- Entry row density: long titles, badges, and trailing time values work but
  need a clearer MHUI treatment for wrapping, spacing, and scan rhythm.
- Summary cards: Dashboard and Timeline use similar card-like grouped content.
  They are good candidates for shared MHDesign spacing, section header, and
  count-value treatments.
- Badges: approximate start, note, and photo metadata should use a consistent
  design-system badge treatment across list, detail, dashboard, and timeline.
- Detail sections: Entry detail has the right information order, but section
  rhythm and emphasis should be refined with MHUI once navigation is calmer.

## SwiftUI-Native Areas To Keep

These current choices look appropriate to keep native unless a later design
system pass has a concrete reason to change them:

- `NavigationStack` for app and detail navigation.
- `List` and `Form` for dense platform-native content.
- `ContentUnavailableView` for empty states.
- `searchable` for active, archive, and timeline search.
- `Menu` plus `Picker` for sort, filter, activity, and scope controls.
- `ShareLink` for entry and timeline sharing.
- `swipeActions` for archive and restore shortcuts.
- `confirmationDialog` for discard and permanent-delete flows.

## Next MHUI Adoption Candidates

Recommended next slice:

1. Rework the main active-screen navigation chrome.
2. Define shared row and metadata badge treatments.
3. Align Dashboard and Timeline summary-card treatments.
4. Review Entry detail section hierarchy at large Dynamic Type.
5. Add explicit failure-state preview seams only if needed for UI review.

## Verification Notes

Successful checks during this pass:

- XcodeBuildMCP `build_sim`.
- XcodeBuildMCP `build_run_sim` with preview launch arguments.
- XcodeBuildMCP `screenshot` for each captured runtime screen.
- Runtime log scan for fatal, error, crash, exception, and termination text.
- `bash ci_scripts/tasks/format_swift.sh`.
- `bash ci_scripts/tasks/lint_swift.sh`.

Tooling limitation:

- XcodeBuildMCP `snapshot_ui` was attempted and failed because the local
  Xcode beta installation is missing `SimulatorKit.framework`. Screenshots
  were captured through direct preview-screen launch arguments instead.
