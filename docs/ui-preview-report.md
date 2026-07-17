# UI Preview Report

## Purpose

This report summarizes the current Fluel UI preview, screenshot, and MHUI
adoption coverage.

Repository paths and implementation notes were refreshed on 2026-07-17
after package-resolution commit `1bba63a`. Most screenshots below remain
historical evidence from the original preview pass. Targeted live and Preview
checks completed on 2026-07-13, adaptive-navigation checks completed on
2026-07-16, and MHUI 1.10 and 1.11 adoption checks completed on 2026-07-17 are
called out explicitly. All 25 current screen-level Preview definitions were
rendered again on 2026-07-17 after the MHUI 1.11 adoption changes.

The decision standard is:

- Preserve Fluel's quiet, familiar, low-pressure product tone.
- Keep Apple-native adaptive navigation, lists, forms, search, menus, share,
  swipe, and confirmation behavior where those controls are already the right
  fit.
- Use MHUI and MHDesign where they improve shared rhythm, semantic typography,
  metadata treatment, and reusable presentation without replacing native
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

## MHUI And MHDesign Audit

Current linked package state:

- The app target links `MHPlatform`, `MHDesign`, and `MHUI`.
- `FluelLibrary` depends on `MHPlatformCore` from `MHPlatform`.
- The Xcode app's `Package.resolved` file is tracked for reproducible app and
  Xcode Cloud resolution. SwiftPM lockfiles for `FluelLibrary` remain local
  generated artifacts. The recorded verification run resolved `MHPlatform` at
  `1.12.0`, `MHUI` at `1.11.0`, and `SwiftLintPlugins` at `0.65.0`.

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
- `MHSummary`, `MHSectionHeader`, `MHSectionFooter`,
  `MHTextRole.summaryTitle`, and `MHTheme.Typography.summaryTitle`.
- `mhListChrome(...)`, `mhFormChrome(...)`, `mhSection(...)`,
  `mhSurface(...)`, `MHGroupedRows`, `MHSurfaceRole.elevated`,
  `MHActionGroup`, `mhInputChrome(state:)`, and `mhGlassPolicy(_)`.

### MHUI 1.10 Adoption Review

The [MHUI 1.9 release](https://github.com/muhiro12/MHUI/releases/tag/1.9),
[MHUI 1.10 release](https://github.com/muhiro12/MHUI/releases/tag/1.10), and
the `1.8...1.10` source diff were reviewed against Fluel's call sites.

- `FluelApp` applies `MHTheme.standard` at the app root for both the normal and
  startup-failure paths. Runtime screenshot roots and standalone component
  previews also apply the same standard theme.
- The no-argument standard theme inherits Fluel's `AccentColor` asset. Fluel's
  system cyan remains the host-owned accent, and the app does not install a
  competing fixed theme accent or redundant root `tint(_:)` override.
- Fluel does not use the removed `mhGroupedRows(...)` modifier, directly
  initialize the changed theme groups, or exhaustively switch over the
  extended surface and font-style enums.
- Existing semantic row, text, badge, section-header, empty-state, key-value,
  and button APIs automatically receive the new neutral palette, tighter
  metrics, stronger system typography, and leading-edge section cues.
- A live iPhone 17 Pro audit covered active entries empty, dashboard dense,
  entry detail dense, presets, and entry editor. The new theme appeared on all
  five screens without clipping, overlap, unreadable text, incorrect accent
  ownership, or runtime failure.
- An iPad landscape dashboard follow-up did not produce reviewable app evidence.
  Device Interaction kept Fluel in the background and returned the SpringBoard
  app switcher after one foreground retry. The run and session were stopped,
  and the original Xcode selection was restored, so this remains a tool-side
  coverage gap rather than an app finding.
- `MHGroupedRows` and the elevated surface role remain available when a future
  custom grouped surface needs them. The current native `List` and `Form`
  decisions do not need replacement merely to exercise the new APIs.

### MHUI 1.11 Adoption Review

The [MHUI 1.11 release](https://github.com/muhiro12/MHUI/releases/tag/1.11),
the
[1.10...1.11 source diff](https://github.com/muhiro12/MHUI/compare/1.10...1.11),
and the package adoption guide were reviewed against Fluel's screens.

- The standard theme now supplies an achromatic editorial palette while
  preserving Fluel's system-cyan host accent for semantic status, focus,
  native controls, and primary actions.
- MHUI 1.11 explicitly distinguishes root theme configuration from complete
  composition. Fluel therefore applies `mhListChrome()` to content lists and
  `mhFormChrome()` to editor forms while retaining native list, form, search,
  swipe, picker, menu, and navigation behavior.
- The package-owned `MHSectionHeader` replaces the app-local
  `FluelSectionHeader` wrapper. Native-container section titles now gain the
  package hierarchy and accessibility header trait directly.
- Entry detail moves its existing time-together summary above the native list
  through `MHSummary`, avoiding a duplicate card while keeping the entry title
  in the navigation bar.
- Custom native-list rows use `mhRow()` where they need package spacing and
  insets. Editor text fields use `mhInputChrome()` inside the retained native
  forms. Related archive and photo actions use `MHActionGroup` with explicit
  destructive and quiet roles.
- The navigation sidebar intentionally remains a native sidebar list rather
  than receiving content-screen chrome.
- Fluel does not use `MHGroupedRows`, direct theme initializers, or exhaustive
  `MHTextRole` switches, so the grouped-row, typography-initializer, and
  new-enum-case migration notes do not require additional changes.
- Empty and filtered states remain native `ContentUnavailableView` content,
  but now appear as overlays above a consistently chromed empty list. This
  avoids turning the unavailable view into an oversized list row and keeps the
  MHUI canvas stable when data appears or disappears.
- Entry and preset rows switch from a horizontal layout to a leading-aligned
  vertical layout at accessibility Dynamic Type sizes. This prevents trailing
  values and actions from compressing the product title into unreadable
  columns while retaining the package row typography and metrics.
- A live iPhone audit covered dense dashboard, dense entry detail, presets, and
  the entry editor. An iPad Pro 11-inch audit covered the dense dashboard in
  landscape. Both device classes showed the new composition without clipping,
  overlap, duplicate titles, accent-ownership drift, or runtime failure.
- The package's native-container validation Preview clips its list footer and
  lower form actions. The package source constrains the embedded `List` to 360
  points and the `Form` to 430 points inside a fixed-height catalog case, so
  this is a package Preview-harness issue rather than evidence that
  `mhListChrome()` or `mhFormChrome()` clips Fluel's runtime screens.

The 1.10 decision to defer container chrome was correct for the package
behavior available during that audit. MHUI 1.11's complete-composition contract
and revised styling supersede that decision.

MHUI's architecture guidance was important: host screens own product wording,
business-state branching, and navigation meaning. MHUI owns reusable
presentation primitives and neutral container behavior. The implementation
therefore kept Fluel-specific screen composition and copy in the app target,
while centralizing the repeated empty-state presentation through
`FluelEmptyState`.

## Screen Decisions

Active entries:

- Adopted: one native two-column `NavigationSplitView` for top-level
  destinations, content-list chrome, native-link row rhythm through `mhRow()`,
  `MHDesignMetrics` spacing, adaptive metadata badges through
  `FluelBadgeStack`, and overlaid empty-state presentation through
  `FluelEmptyState`.
- Kept SwiftUI-native: a detail-local `NavigationStack`, `List`, `searchable`,
  sort/filter `Menu` plus `Picker`, `NavigationLink`, and `swipeActions`.
- Removed: the root Browse toolbar menu. The sidebar now owns top-level
  navigation and automatically collapses to a single navigation flow at
  compact width.

Archive:

- Adopted: content-list chrome, the same native-link row treatment as the
  active list, and the same overlaid empty-state presentation.
- Kept SwiftUI-native: archive search, sort/filter menus, restore swipe
  action, and restore error alert.
- Deferred: custom archive action chrome, because the native swipe action is
  still the clearest Apple pattern here.

Entry detail:

- Adopted: `mhListChrome(...)`, `MHSummary`, package-owned
  `MHSectionHeader`, `MHActionGroup` for archive-state actions, shared photo
  surface metrics, and existing `LabeledContentStyle.mhKeyValue` for key-value
  rows.
- Kept SwiftUI-native: `List`, inline navigation title, `ShareLink`,
  toolbar actions, `confirmationDialog`, and alert.

Entry editor and preset editor:

- Adopted: `mhFormChrome(...)`, `mhInputChrome()`, package-owned
  `MHSectionHeader`, shared photo surface metrics, and `MHActionGroup` for
  related photo actions.
- Kept SwiftUI-native: `Form`, text fields, segmented precision picker,
  date/month/year pickers, cancellation/confirmation toolbar items, discard
  confirmation, and save alerts.

Dashboard:

- Adopted: content-list chrome, package-owned `MHSectionHeader`, MHUI row text
  roles, and shared milestone row treatment.
- Kept SwiftUI-native: `List` behavior and key-value overview rows.
- Deferred: custom `mhSection(...)` cards, because the native `Section`
  structure and package-owned headers preserve the overview scan pattern.

Timeline:

- Adopted: content-list chrome, package-owned `MHSectionHeader`, MHUI row text
  roles, and existing `mhKeyValue` summary rows. Timeline empty state uses the
  same overlaid `FluelEmptyState` wrapper as the other empty surfaces.
- Kept SwiftUI-native: `List`, search, activity/scope menus, monthly
  grouping, and `ShareLink`.
- Deferred: `MHSummary`, because the timeline's multi-value counts remain
  clearer as key-value section rows.

Milestones:

- Adopted: content-list chrome, `MHSectionHeader`, `mhRow()`, shared milestone
  typography and badge roles, plus the common empty-state wrapper.
- Kept SwiftUI-native: `List` behavior.
- Deferred: custom milestone cards, because the standard section preserves a
  quieter scan pattern.

Presets:

- Adopted: content-list chrome, `MHSectionHeader`, `mhRow()`,
  `FluelBadgeStack`, MHUI row text roles, and shared spacing from
  `MHDesignMetrics`. Presets empty state uses `FluelEmptyState` while keeping
  its product-specific copy and Create Preset action.
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
  - Entry detail - photo
  - Entry detail - archived
  - Entry detail - long text, large type
- `EntryEditorView`
  - Add entry - empty
  - Edit entry - filled
  - Create entry - long text, dark
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
- `PresetEditorView`
  - Create preset - empty
  - Edit preset - filled
- `FluelBadgeStack`
  - Badge stack
- `FluelEmptyState`
  - Empty state - action
  - Empty state - no action

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
  editor screens now uses `MHSectionHeader` directly for the same quiet MHUI
  section cue, semantic title treatment, and accessibility header trait.
- Row spacing now comes from `MHDesignMetrics` instead of local ad-hoc values
  where the row is part of the shared visual rhythm.
- Content lists and editor forms now use package-owned screen chrome and
  readable-width behavior while retaining their native SwiftUI controls.
- Entry detail presents time together through `MHSummary` above the list,
  separating screen context from the detail rows without adding a custom card.
- Empty states now keep native `ContentUnavailableView` semantics while using
  one Fluel wrapper for MHUI spacing and action styling. They overlay empty
  chromed lists instead of becoming oversized native list rows.

MHUI family fit:

- The app now shares screen, summary, row, input, badge, section, empty-state,
  key-value, and primary-action rhythm across screens.
- Product meaning still comes from Fluel's own copy, sample entries, screen
  composition, and active/archive separation.
- The family resemblance is stronger without making the UI louder or less
  iOS-native.

Intentionally preserved:

- Native `List`, `Form`, search, menus, pickers, swipe actions, share, alerts,
  and confirmation dialogs remain in place.
- The adaptive navigation sidebar keeps its native sidebar treatment rather
  than receiving content-screen chrome.
- Product language remains Entry, Start, Precision, Time together, Archive,
  Timeline, Milestone, and Preset.

Superseded 1.10 decisions:

- The 1.10 audit deferred `mhListChrome(...)`, `mhFormChrome(...)`, and broader
  row chrome because their then-current appearance flattened native grouped
  cards without adding a complete replacement hierarchy.
- MHUI 1.11 changes that contract: achromatic canvas treatment, readable-width
  container chrome, package headers, row chrome, input chrome, and
  `MHSummary` now form one explicit composition system. The new implementation
  adopts those pieces together instead of applying a single modifier in
  isolation.
- `MHActionGroup` now owns related archive and photo actions. Preset-row
  actions remain a native primary action plus overflow menu because that
  compact row interaction is already clearer than a grouped action strip.

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
- Large Dynamic Type previews for active entries, entry detail, and preset
  rows.
- English and Japanese active-entry empty states through runtime launch
  arguments and screenshots.
- All 25 current screen-level Preview definitions, including the new preset
  editor coverage.

## Unconfirmed States

Not confirmed or only partially confirmed:

- Settings, because the screen is not implemented.
- Widget-style glance, because the surface is not implemented.
- iPad destination switching beyond the initial Entries selection and
  portrait-to-landscape adaptation. CoreSimulator accepted the launch and
  portrait screenshot but did not provide reliable interaction or rotation
  control during the 2026-07-16 pass.
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

The app still feels Apple-native because native lists, forms, search, menus,
share, swipe actions, alerts, and confirmation dialogs remain the core
interaction model.

## Further Improvement Candidates

Good later candidates:

1. Add a settings screen only when display preferences become an active product
   slice.
2. Add failure-injection preview seams if save/archive/restore error UI needs
   visual review.
3. Revisit the preset row's native action plus overflow-menu layout only if
   its action set becomes too large for the current compact row.
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

The MHUI 1.11 adoption pass recorded these successful checks on 2026-07-17:

- Official 1.11 release notes, the `1.10...1.11` source diff, adoption guide,
  sample package, and Fluel call sites were reviewed together.
- Xcode-native build with scheme `Fluel`, Debug, and the discovered iPhone 17
  Pro iOS 27 Simulator destination.
- Xcode-native rendering of all 25 screen-level Preview definitions. Empty,
  populated, photo, archived, editor, dark-mode, and large-Dynamic-Type
  variants completed without a Preview error after the Preview definitions for
  `ContentView`, `EntryDetailView`, and `EntryEditorView` were moved to
  dedicated Preview-support files.
- An Xcode 27 beta Preview-thunk ambiguity around
  `SwiftUI.__designTimeSelection` affected those three source files while the
  app itself continued to build. Separating Preview declarations from their
  stateful screen implementations resolved the tool-only failure without
  adding type erasure or changing production behavior.
- The package-native-container validation Preview was inspected separately.
  Its visible clipping comes from fixed 360-point and 430-point frames in the
  validation harness; Fluel's full-screen list and form Previews did not
  reproduce it.
- iPhone 17 Pro live captures for dense Dashboard, dense Entry detail,
  Presets, and Entry editor. The final screenshots and hierarchies showed no
  clipping, overlap, unreadable text, title duplication, wrong accent
  ownership, or broken navigation.
- iPad Pro 11-inch (M5) live capture for dense Dashboard in landscape,
  including the MHUI readable-width composition.
- Runtime logs reached `startup.ready` without a Fluel/MHUI fatal error,
  exception, or crash. Remaining CoreTelephony, PointerUI, Accessibility, and
  AX messages were Simulator noise without a visible app failure.
- Both Device Interaction sessions and verification processes were stopped.
  The Xcode selection was restored to scheme `Fluel` and destination
  `iPhone 17 Pro for Fluel`.
- `bash ci_scripts/tasks/verify_task_completion.sh`, including 66 shared
  library tests, SwiftLint, library boundaries, localization, repository
  rules, and the fallback app build.
- `git diff --check`.
- The two pre-existing `Text + Text` deprecation warnings in
  `MilestoneRowView.swift` were removed in a separate maintenance change.

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
- Xcode 27 beta's Preview thunk can produce an ambiguous
  `__designTimeSelection` overload for stateful screens whose Preview
  declarations share the implementation file. Dedicated Preview-support files
  are the current repository workaround.
- MHUI's `Validation / Native Containers` Preview is not suitable as
  full-screen clipping evidence while its embedded `List` and `Form` retain
  fixed heights. Fluel's consumer Previews are the controlling evidence for
  this app.
- Markdown lint was not run because `markdownlint` was not available on the
  local `PATH`.
