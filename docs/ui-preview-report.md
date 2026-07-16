# UI Preview Report

## Purpose

This report summarizes the current Fluel UI preview, screenshot, and MHUI
adoption coverage.

Repository paths and implementation notes were refreshed on 2026-07-16
against commit `8ef4434`. Most screenshots below remain historical evidence
from the original preview pass. Targeted live and Preview checks completed on
2026-07-13 and adaptive-navigation checks completed on 2026-07-16 are called
out explicitly.

The decision standard is:

- Preserve Fluel's quiet, familiar, low-pressure product tone.
- Keep Apple-native adaptive navigation, lists, forms, search, menus, share,
  swipe, and confirmation behavior where those controls are already the right
  fit.
- Use MHUI and MHDesign where they improve shared rhythm, semantic typography,
  metadata treatment, and reusable presentation without flattening native
  surfaces.

## HIG And MHUI Priority

Apple Human Interface Guidelines and platform-native behavior are the base
layer. Native `NavigationSplitView`, `NavigationStack`, `List`, `Form`,
`Menu`, `ShareLink`, sheets, alerts, controls, swipe actions, and confirmation
dialogs stay in place when they are the most familiar Apple-platform pattern.

MHUI and MHDesign are the shared style layer above that base. In Fluel they
should align spacing, typography rhythm, section cues, row rhythm, metadata,
badges, empty states, key-value display, and action emphasis without becoming a
replacement for standard Apple controls.

This gives Fluel more of the non-Incomes MHUI family feel while preserving its
own quiet, familiar, gentle, concrete, and low-pressure product tone.

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

Component previews retained or added:

- `EntryRowView`.
- `FluelBadgeStack`.
- `FluelEmptyState`.
- `FluelSectionHeader`.

## MHUI And MHDesign Audit

Current linked package state:

- The app target links `MHPlatform`, `MHDesign`, and `MHUI`.
- `FluelLibrary` depends on `MHPlatformCore` from `MHPlatform`.
- The Xcode app's `Package.resolved` file is tracked for reproducible app and
  Xcode Cloud resolution. SwiftPM lockfiles for `FluelLibrary` remain local
  generated artifacts. The recorded verification run resolved `MHPlatform` at
  `1.12.0`, `MHUI` at `1.8.0`, and `SwiftLintPlugins` at `0.64.1`.

Available API areas inspected:

- `MHDesignMetrics`, including shared spacing, corner radius, layout,
  readable width, and control target metrics.
- `mhTheme(_:)` and `MHTheme.standard`.
- `mhTextStyle(_:colorRole:)`, `mhRowTitle()`, `mhRowSupporting()`,
  `mhRowOverline()`, and `mhRowValue(colorRole:)`.
- `mhBadge(style:accessibilityLabel:)`.
- `mhEmptyStateLayout()`.
- `LabeledContentStyle.mhKeyValue`.
- `mhRow()`.
- `mhSectionHeader()`, `mhSectionHeaderTitle()`,
  `mhSectionHeaderSupporting()`, and `mhSectionFooterText()`.
- `mhListChrome(...)`, `mhFormChrome(...)`, `mhSection(...)`,
  `mhSurface(...)`, `mhGroupedRows(...)`, `MHActionGroup`,
  `mhInputChrome(state:)`, and `mhGlassPolicy(_)`.

MHUI's architecture guidance was important: host screens own product wording,
business-state branching, and navigation meaning. MHUI owns reusable
presentation primitives and neutral container behavior. The implementation
therefore kept Fluel-specific screen composition and copy in the app target,
while centralizing the repeated empty-state presentation through
`FluelEmptyState`.

## Screen Decisions

Active entries:

- Adopted: one native two-column `NavigationSplitView` for top-level
  destinations, `EntryRowView` row rhythm through `mhRow()`,
  `MHDesignMetrics` spacing, adaptive metadata badges through
  `FluelBadgeStack`, and shared empty-state presentation through
  `FluelEmptyState`.
- Kept SwiftUI-native: a detail-local `NavigationStack`, `List`, `searchable`,
  sort/filter `Menu` plus `Picker`, `NavigationLink`, and `swipeActions`.
- Removed: the root Browse toolbar menu. The sidebar now owns top-level
  navigation and automatically collapses to a single navigation flow at
  compact width.
- Deferred: `mhListChrome(...)`, because it removed the calmer native
  inset-grouped surface.

Archive:

- Adopted: the same entry row treatment as the active list and the same
  shared empty-state presentation.
- Kept SwiftUI-native: archive search, sort/filter menus, restore swipe
  action, and restore error alert.
- Deferred: custom archive action chrome, because the native swipe action is
  still the clearest Apple pattern here.

Entry detail:

- Adopted: shared `FluelSectionHeader` for quiet section hierarchy and
  existing `LabeledContentStyle.mhKeyValue` for key-value rows.
- Kept SwiftUI-native: grouped `List`, inline navigation title, `ShareLink`,
  `confirmationDialog`, and alert.
- Deferred: `mhListChrome(...)` and `MHActionGroup`, because the standard
  grouped detail card layout and native destructive confirmation read better.

Entry editor and preset editor:

- Adopted: `FluelSectionHeader` for consistent section hierarchy.
- Kept SwiftUI-native: `Form`, text fields, segmented precision picker,
  date/month/year pickers, cancellation/confirmation toolbar items, discard
  confirmation, and save alerts.
- Deferred: `mhFormChrome(...)` and `mhInputChrome(state:)`, because they
  flattened native form cards or duplicated standard form behavior.

Dashboard:

- Adopted: `FluelSectionHeader`, MHUI row text roles, and shared milestone row
  treatment.
- Kept SwiftUI-native: grouped `List` and key-value overview rows.
- Deferred: custom `mhSection(...)` cards, because native grouped sections
  already preserve the quiet overview surface well.

Timeline:

- Adopted: `FluelSectionHeader`, MHUI row text roles, and existing
  `mhKeyValue` summary rows. Timeline empty state now uses the same
  `FluelEmptyState` wrapper as the other empty surfaces.
- Kept SwiftUI-native: `List`, search, activity/scope menus, monthly
  grouping, and `ShareLink`.
- Deferred: custom timeline chrome, because timeline remains a reading
  surface rather than a separate dashboard-like shell.

Milestones:

- Adopted: shared milestone row styling with MHUI typography and badge roles,
  plus the common empty-state wrapper.
- Kept SwiftUI-native: grouped `List`.
- Deferred: custom milestone cards, because the standard section preserves a
  quieter scan pattern.

Presets:

- Adopted: `FluelBadgeStack`, MHUI row text roles, and shared spacing from
  `MHDesignMetrics`. Presets empty state also uses `FluelEmptyState` while
  keeping its product-specific copy and Create Preset action.
- Kept SwiftUI-native: `List`, `Button`, `Menu`, sheets, alert, and delete
  confirmation.
- Deferred: `MHActionGroup`, because the row's primary Use action plus native
  overflow menu is still clearer at compact width.

Settings:

- Not implemented. No settings screen was added, because this pass explicitly
  avoids new product features.

## Preview Support

Preview data lives in app-target preview support:

- `Fluel/Sources/PreviewSupport/PreviewSampleData.swift`
- `Fluel/Sources/PreviewSupport/PreviewSampleData+Support.swift`
- `Fluel/Sources/PreviewSupport/PreviewSampleData+Entries.swift`
- `Fluel/Sources/PreviewSupport/PreviewSampleData+Drafts.swift`
- `Fluel/Sources/PreviewSupport/PreviewSampleData+Presets.swift`

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
- `FluelBadgeStack`
  - Badge stack
- `FluelEmptyState`
  - Empty state - action
  - Empty state - no action
- `FluelSectionHeader`
  - Section header

## Screenshots

Before screenshots retained:

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

After screenshots captured during this pass:

- `docs/ui-preview-screenshots/after-active-entries-empty.jpg`
- `docs/ui-preview-screenshots/after-active-entries-dense.jpg`
- `docs/ui-preview-screenshots/after-dashboard-dense.jpg`
- `docs/ui-preview-screenshots/after-timeline-dense.jpg`
- `docs/ui-preview-screenshots/after-milestones-upcoming.jpg`
- `docs/ui-preview-screenshots/after-archive-entries.jpg`
- `docs/ui-preview-screenshots/after-presets-custom-default.jpg`
- `docs/ui-preview-screenshots/after-entry-detail-typical.jpg`
- `docs/ui-preview-screenshots/after-entry-detail-archived.jpg`
- `docs/ui-preview-screenshots/after-entry-editor-long-text.jpg`

Localization baseline screenshots:

- `docs/ui-preview-screenshots/localization-active-entries-en.jpg`
- `docs/ui-preview-screenshots/localization-active-entries-ja.jpg`

All screenshots were captured on iPhone 17 Pro Simulator at 368 x 800.

## Before And After Differences

Most improved:

- Root navigation no longer depends on a Browse toolbar menu. A native
  two-column split view keeps Entries primary, groups the five supporting
  destinations in a sidebar, collapses to a single flow on iPhone, and keeps
  sidebar and detail visible together on iPad.
- The main detail title uses compact inline presentation on iPhone and large
  presentation at regular width, avoiding title-layout changes after moving
  through the collapsed sidebar.
- Entry metadata badges now use an adaptive shared stack. Badges stay compact
  when they fit and fall back vertically when long text or compact width needs
  it.
- Section hierarchy in Dashboard, Timeline, Milestones, Presets, detail, and
  editor screens now uses the same quiet MHUI section cue and semantic title
  treatment.
- Row spacing now comes from `MHDesignMetrics` instead of local ad-hoc values
  where the row is part of the shared visual rhythm.
- Empty states now keep native `ContentUnavailableView` semantics while using
  one Fluel wrapper for MHUI spacing and action styling.

MHUI family fit:

- The app now shares row, badge, section, empty-state, key-value, and primary
  action rhythm across screens.
- Product meaning still comes from Fluel's own copy, sample entries, screen
  composition, and active/archive separation.
- The family resemblance is stronger without making the UI louder or less
  iOS-native.

Intentionally preserved:

- Native grouped cards remain on list, detail, and form screens.
- Native search, menus, pickers, swipe actions, share, alerts, and
  confirmation dialogs remain in place.
- Product language remains Entry, Start, Precision, Time together, Archive,
  Timeline, Milestone, and Preset.

Rejected after testing:

- `mhListChrome(...)` made Dashboard and Entry detail too flat by removing the
  native inset-grouped card surface.
- `mhFormChrome(...)` made the entry editor too flat by removing standard
  form grouping.
- Applying `mhRow()` inside grouped detail/dashboard section cards also
  removed card backgrounds, so `mhRow()` is limited to the entry list rows.
- `MHActionGroup` remains deferred for detail and preset actions because the
  current native toolbar, menu, swipe, and confirmation patterns communicate
  action safety more clearly at this stage.

## Confirmed States

Confirmed through previews and screenshots:

- Tab-free root navigation with all six destinations.
- Compact-width sidebar-to-detail navigation on iPhone.
- Regular-width sidebar and Entries detail shown together on iPad, including
  the selected Entries highlight.
- Empty active list.
- Active list with multiple entries.
- Dense list data with long title wrapping.
- Entry rows with note, photo metadata, and approximate-start badges.
- Entry detail with typical month-precision data.
- Entry detail with a valid photo fixture.
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
- English and Japanese active-entry empty states through runtime launch
  arguments and screenshots.

## Unconfirmed States

Not confirmed or only partially confirmed:

- Settings, because the screen is not implemented.
- Widget-style glance, because the surface is not implemented.
- iPad destination switching beyond the initial Entries selection and
  portrait-to-landscape adaptation. CoreSimulator accepted the launch and
  portrait screenshot but did not provide reliable interaction or rotation
  control during the 2026-07-16 pass.
- A complete recapture of every retained Preview variant. Targeted Japanese
  Milestones and photo-detail previews rendered successfully on 2026-07-13.
- Permanent-delete confirmation rendering. Entry-discard confirmation was
  verified through live Simulator interaction on 2026-07-13.
- Error alerts for save, archive, and restore failures, because no failure
  injection seam exists for those app-side adapters.
- End-to-end selection of real iCloud, RAW, and panoramic photo assets. The
  picker, file-backed downsampling, cancellation, storage, and display paths
  are implemented, but those external asset variants remain a device test.

## UI Tone

The updated UI keeps Fluel's quiet, familiar, low-pressure tone. The largest
change is making the primary active-entry screen the compact starting point
while moving infrequent destinations into an adaptive sidebar. The new section
cues add a small amount of structure without adding new product copy or
turning the app into a dashboard-first product.

The app still feels Apple-native because standard grouped lists, forms, search,
menus, share, swipe actions, alerts, and confirmation dialogs remain the core
interaction model.

## Further Improvement Candidates

Good later candidates:

1. Add a settings screen only when display preferences become an active product
   slice.
2. Add failure-injection preview seams if save/archive/restore error UI needs
   visual review.
3. Revisit `MHActionGroup` for detail actions if the action set grows beyond
   the current native toolbar and section buttons.
4. Consider a package-level MHUI flow layout for metadata badges if badge
   wrapping becomes common across apps.
5. Revisit a third split-view column only if the product gains an independent
   intermediate selection tier that cannot remain in the detail stack.

Not recommended now:

- Do not add custom cards just to show more MHUI.
- Do not add settings, widgets, Watch, AI, or backup surfaces during UI-only
  passes.
- Do not replace native `List` or `Form` behavior while it remains the clearest
  Apple pattern for these screens.

## Verification Snapshot

The adaptive-navigation pass recorded these successful checks on 2026-07-16:

- Xcode-native builds with `Fluel`, Debug, and the discovered iOS 27 Simulator
  destination.
- iPhone 17 Pro live navigation through all six destinations, return to
  Entries, Add Entry presentation, screenshots, hierarchy inspection, and
  startup-log review.
- iPad Pro 11-inch (M5) launch through `simctl` fallback after Xcode-native
  device interaction could not connect. The portrait screenshot confirmed the
  simultaneous sidebar and detail layout, selected Entries highlight, all six
  destinations, and absence of a bottom tab bar.
- Compact inline and regular-width large title presentation checks.
- `bash ci_scripts/tasks/format_swift.sh`.
- `bash ci_scripts/tasks/lint_swift.sh`.
- `bash ci_scripts/tasks/check_repository_rules.sh`.
- `bash ci_scripts/tasks/verify_task_completion.sh`, including 66 shared
  library tests and the fallback app build.
- String Catalog audit for required locales `en,ja` with no incomplete or
  stale keys in `Localizable.xcstrings`.
- `git diff --check`.

The original preview pass recorded these successful checks:

- XcodeBuildMCP `session_show_defaults`, followed by session defaults for
  `Fluel.xcodeproj`, scheme `Fluel`, Debug, iPhone 17 Pro iOS 27 Simulator.
- XcodeBuildMCP `build_sim`.
- XcodeBuildMCP `build_run_sim` with preview launch arguments.
- XcodeBuildMCP `screenshot` for each captured runtime screen.
- XcodeBuildMCP `build_run_sim` with English and Japanese localization launch
  arguments for active-entry screenshot evidence.
- XcodeBuildMCP `build_run_sim` without preview launch arguments to confirm
  the production SwiftData plus CloudKit container path starts without a fatal
  runtime error.
- App Intents metadata inspection in
  `Fluel.app/Metadata.appintents/extract.actionsdata`.
- Built app resource inspection for `Localizable.strings`,
  `AppIntents.strings`, `AppShortcuts.strings`, and package localization
  resources under both `en.lproj` and `ja.lproj`.
- String Catalog audit for required locales `en,ja`.
- Active entries empty-state screenshot refreshed after introducing
  `FluelEmptyState`.
- Final runtime log scan for fatal, error, crash, exception, termination,
  failure, and assertion text.
- `bash ci_scripts/tasks/format_swift.sh`.
- `bash ci_scripts/tasks/lint_swift.sh`.
- `bash ci_scripts/tasks/test_library.sh`.
- `bash ci_scripts/tasks/check_repository_rules.sh`.
- `bash ci_scripts/tasks/verify_task_completion.sh`.
- `git diff --check`.

Tooling limitation:

- Semantic UI snapshot is still treated as unreliable in this local Xcode beta
  environment because of the previously observed missing
  `SimulatorKit.framework` issue. Runtime screenshots and logs remain the
  fallback evidence path.
- Markdown lint was not run because `markdownlint` was not available on the
  local `PATH`.
