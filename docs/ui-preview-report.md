# UI Preview Report

## Purpose

This report summarizes the current Fluel UI preview, screenshot, and MHUI
adoption coverage.

Repository paths and implementation notes were refreshed on 2026-07-18
after package-resolution commit `5103690`. Most screenshots below remain
historical evidence from the original preview pass. Targeted live and Preview
checks completed on 2026-07-13, adaptive-navigation checks completed on
2026-07-16, and MHUI 1.10 through 1.13 adoption checks completed on
2026-07-17 and 2026-07-18 are called out explicitly. All 25 current screen-level Preview
definitions were rendered after the MHUI 1.11 adoption changes. The MHUI 1.12
follow-up re-rendered the five screens that cover the changed list, form,
section, key-value, surface, and Liquid Glass boundaries.
A subsequent regular-width root review corrected the sidebar's remaining
app-owned MHUI adoption gap.
The MHUI 1.13 signature-composition follow-up and MHUI 1.15 root-first styling
review completed on 2026-07-18. The MHUI 1.16 adaptive feature-hierarchy
follow-up completed on 2026-07-23.

The decision standard is:

- Preserve Fluel's quiet, familiar, low-pressure product tone.
- Keep Apple-native adaptive navigation, lists, forms, search, menus, share,
  swipe, and confirmation behavior where those controls are already the right
  fit.
- Use MHUI and MHDesign where they improve shared rhythm, semantic typography,
  metadata treatment, surface continuity, and reusable presentation without
  replacing native interaction or adaptation.

## HIG And MHUI Priority

Apple Human Interface Guidelines and platform-native behavior are the base
layer. Native `NavigationSplitView`, `NavigationStack`, `List`, `Form`,
`Menu`, `ShareLink`, sheets, alerts, controls, swipe actions, and confirmation
dialogs stay in place when they are the most familiar Apple-platform pattern.

MHUI and MHDesign are the shared style layer above that base. In Fluel they
should align spacing, typography rhythm, section cues, row rhythm, metadata,
badges, empty states, key-value display, canvas surfaces, and action emphasis
without becoming a replacement for standard Apple controls. Keeping a native
container does not exempt it from the shared visual language when MHUI provides
an appropriate container treatment.

This gives Fluel more of the non-Incomes MHUI family feel while preserving its
own quiet, familiar, gentle, concrete, and low-pressure product tone.

## MHUI 1.15 Root-First And Asset Follow-Up

The current captures no longer read as a mostly OS-standard product.
Dashboard, Entry Detail, Milestones, Timeline, and Presets visibly use the
MHUI signature through editorial summary rules, strong section cues, outlined
grouped rows, restrained accent, and the package spacing rhythm. Active
Entries, Archive, the sidebar, and editors retain native containers for search,
selection, navigation, focus, keyboard, and form behavior. Those screens are
supported exceptions rather than the primary design route.

Fluel applies `.mhTheme(.standard)` once around the success and startup-failure
branches at its app entry point. The MHUI 1.15 adoption cleanup also:

1. Removes the production `.mhTheme(.standard)` from `EntryEditorView`; the
   presented editor inherits the root environment. Theme calls remain in
   standalone Previews because they have no app root.
2. Removes the direct `MHDesign` product link from the app target. MHUI
   re-exports MHDesign, and the root theme synchronizes `mhDesignMetrics` for
   the existing environment readers.

The remaining shipping-source color shortcuts now use semantic asset-backed
roles:

- `.foregroundStyle(.secondary)` in `EntryPhotoImage.swift` is replaced with
  `.mhForegroundStyle(.secondaryText)`.
- `.foregroundStyle(.primary)` in `FluelTimeTogetherLabel.swift` is replaced
  with
  `.mhForegroundStyle(.primaryText)`.
- Empty-state symbols use `.mhForegroundStyle(.accent)`.
- Archive and restore swipe actions use `.mhTint(.accent)`.
- Keep `Color.accentColor` for the clock marker: it resolves the app's
  `AccentColor` asset, while the existing opacity remains a code-derived
  treatment.

Fluel has no RGB or hexadecimal presentation color literals in shipping Swift
source. SF Symbols should remain in `systemName` APIs rather than being copied
into image assets, because they need to retain native weight, scale, and
accessibility behavior. Screenshot files under `docs` and `.build/reports`
are review evidence rather than runtime image resources.

## MHUI 1.16 Adaptive Feature-Hierarchy Follow-Up

MHUI 1.16 intentionally changes the standard palette, spacing, typography
emphasis, surface geometry, divider treatment, and hierarchy-cue placement.
Fluel keeps the package-owned standard theme instead of overriding those
values locally, so its existing signature screens receive that visual update
directly.

The new `MHFeatureGrid` matches Dashboard's existing product hierarchy:

- The longest-running active entry remains the leading highlight.
- The most recently archived entry becomes concise supporting content.
- Compact widths stack the two features while regular widths preserve a
  leading-and-supporting split.
- A single available highlight renders directly instead of reserving an empty
  grid column.

Each feature keeps app-owned wording and data while using MHUI's muted surface,
inset, semantic typography, and adaptive layout. Native `List` and `Form`
screens remain unchanged because their selection, swipe, focus, grouping, and
input behavior still justify the package's native-container bridges.

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

- The app target links `MHPlatform` and `MHUI`; MHUI re-exports `MHDesign`.
- `FluelLibrary` depends on `MHPlatformCore` from `MHPlatform`.
- The Xcode app's `Package.resolved` file is tracked for reproducible app and
  Xcode Cloud resolution. SwiftPM lockfiles for `FluelLibrary` remain local
  generated artifacts. The recorded verification run resolved `MHPlatform` at
  `1.12.0`, `MHUI` at `1.16.0`, and `SwiftLintPlugins` at `0.65.0`.

Available API areas inspected:

- `MHDesignMetrics`, including shared spacing, corner radius, layout,
  readable width, and control target metrics.
- `mhTheme(_:)` and `MHTheme.standard`.
- `mhForegroundStyle(_:)` and `mhTint(_:)`.
- `mhTextStyle(_:colorRole:)`, `mhRowTitle()`, `mhRowSupporting()`,
  `mhRowOverline()`, and `mhRowValue(colorRole:)`.
- `mhBadge(style:accessibilityLabel:)`.
- `mhEmptyStateLayout()`.
- `LabeledContentStyle.mhKeyValue`.
- `mhRow()`.
- `mhSectionHeader()`, `mhSectionHeaderTitle()`,
  `mhSectionHeaderSupporting()`, and `mhSectionFooterText()`.
- `MHSummary`, `MHFeatureGrid`, `MHSectionHeader`, `MHSectionFooter`,
  `MHTextRole.summaryTitle`, and `MHTheme.Typography.summaryTitle`.
- `mhListChrome()`, `mhFormChrome()`, `mhSection(...)`,
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
- This pass left the navigation sidebar outside content-screen chrome. The
  later regular-width review identified that omission as incomplete MHUI
  adoption rather than a required consequence of native navigation.
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

### MHUI 1.11 Visual Ownership Review

The following concerns were classified from Fluel previews before the MHUI
1.12 update, the MHUI 1.11 adoption guide and source, and Apple's layout,
scroll-view, materials, and Liquid Glass guidance.

- Background brightness — MHUI package. `MHBackground` uses an opaque
  `#F2F2F2` light canvas, and Fluel does not override it. This is the package's
  intended achromatic palette, but its perceived weight needs package-level
  review rather than an app-local color fork.
- Background differences — Fluel app integration. Native navigation, toolbar,
  and search controls appropriately use system Liquid Glass or materials, but
  Fluel omitted MHUI canvas and row treatment from the sidebar `List`. That
  made one complete navigation surface use an unrelated system background
  while every detail screen used the MHUI canvas. Native split-view behavior
  does not require this visual discontinuity.
- Scroll-region boundaries — MHUI package. `MHContainerChromeModifier` pads
  the native `List` or `Form` itself horizontally and vertically. This shortens
  the scroll viewport instead of allowing content to extend beneath the
  floating navigation layer and use the system scroll-edge treatment.
- Centered content compression — MHUI package. The same modifier applies outer
  screen margins and a readable-width limit around the complete scrolling
  container. Readable text width is intentional at regular width, but viewport
  padding at compact width makes the whole interactive region feel inset.
- Square list elements — MHUI package. `mhListChrome()` forces a plain list and
  `mhRow()` clears native row backgrounds and separators. The resulting
  editorial rectangles are an intentional 1.11 treatment, but shape and
  grouping need shared-package review.
- Row body alignment — Fluel app and MHUI package. Fluel's preset SF Symbols
  had variable intrinsic widths; the app now uses one Dynamic Type-scaled
  symbol column. Remaining offsets between section headers, key-value rows,
  and ordinary rows come from separate MHUI header and row inset recipes.
- Double-framed form inputs — MHUI package. Fluel follows the documented
  native-form route: a `TextField` inside `Form` receives `mhInputChrome()`.
  The package adds an inner fill and border while the native form section keeps
  its own grouped surface.
- Section cue and row margins — MHUI package. `MHSectionHeaderModifier` adds a
  package leading inset after the native section header inset, while row chrome
  uses a separate list-row inset. The combined native and package margins
  produce different leading guides.
- Liquid Glass harmony — MHUI package, not custom app glass. Fluel uses system
  navigation and control glass; it does not add custom glass to content. Apple
  intends glass for the navigation and control layer, but the package's opaque,
  inset scroll container prevents content from flowing naturally beneath that
  layer and weakens the relationship.

No app-local workaround was added for package-owned canvas, viewport, content
row, header, input, or glass composition. Those concerns need one shared MHUI
fix so all adopters receive the same behavior. The sidebar omission is
app-owned and is corrected after the MHUI 1.12 migration.

Recommended MHUI follow-up:

1. Keep native scrolling containers edge-to-edge and apply readable-width or
   margin policy to their content instead of shortening the scroll viewport.
2. Define one shared leading guide for section cues, ordinary rows, and
   key-value rows after native container insets are resolved.
3. Reconcile the plain editorial row treatment with rounded Apple-platform
   grouping, or expose the two treatments as explicit package choices.
4. Make input chrome aware of native form grouping so one field does not show
   both an outer grouped surface and an inner bordered surface.
5. Review canvas brightness and the transition between opaque content planes
   and system Liquid Glass without putting glass into the content layer.

### MHUI 1.12 Follow-Up

The [MHUI 1.12 release](https://github.com/muhiro12/MHUI/releases/tag/1.12),
[1.11...1.12 source diff](https://github.com/muhiro12/MHUI/compare/1.11...1.12),
and current adoption guide directly address the package-owned findings above.

- Native `List` and `Form` containers keep their complete viewport,
  platform-selected style, grouped row backgrounds, separators, and control
  behavior. Fluel uses only the no-argument `mhListChrome()` and
  `mhFormChrome()` APIs.
- Screen-specific lead content remains inside the app-owned native container.
  Entry detail presents its summary as the first `List` section instead of
  passing a detached header to container chrome.
- Form text fields no longer receive `mhInputChrome()`. Native form grouping
  now owns the field surface without a second frame.
- The standard light canvas changes from `#F2F2F2` to `#FAFAFA`, surfaces
  become white, and public control and surface corner radii increase to 8 and
  12 points.
- Section cues now use the native section leading guide, and key-value rows
  use one stable value column with an automatic vertical fallback.
- Metadata badges and detached input chrome remain solid content treatments.
  Liquid Glass stays reserved for eligible interactive controls and system
  navigation chrome.
- The `NavigationSplitView` and sidebar `List` continue to own adaptive
  navigation behavior. Fluel now applies `mhListChrome()` to that list and
  `mhRow()` to its destinations so the navigation surface participates in the
  same semantic canvas and row system as its detail screens.

One app-side integration issue remained after the package update. The entry
start section applied `.labeledContentStyle(.mhKeyValue)` to the complete
`Section`, which also restyled its native `DatePicker` and `Picker` controls.
At AX2 the date value was clipped. Fluel now applies the style only to the two
explicit `LabeledContent` rows, allowing native controls to choose their own
accessibility layout while retaining MHUI key-value treatment where intended.

Focused Preview verification covered active entries, dense dashboard, entry
detail, the filled entry editor, and custom presets on iPhone 17 Pro. The
entry editor was also rendered at AX2, and dense dashboard plus the filled
editor were rendered on iPad Pro 11-inch. The previously reported content
canvas, viewport, central compression, square grouping, row alignment,
double-frame, section-margin, and Glass-harmony concerns did not reproduce
after migration. A later regular-width root preview exposed the remaining
sidebar background discontinuity, which was an app-side adoption gap.

## Screen Decisions

Active entries:

- Adopted: one native two-column `NavigationSplitView` for top-level
  destinations, MHUI canvas and row treatment in both the sidebar and content
  lists, native-link row rhythm through `mhRow()`, `MHDesignMetrics` spacing,
  adaptive metadata badges through `FluelBadgeStack`, and overlaid empty-state
  presentation through `FluelEmptyState`.
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

- Adopted: `mhListChrome()`, `MHSummary`, package-owned
  `MHSectionHeader`, `MHActionGroup` for archive-state actions, shared photo
  surface metrics, and existing `LabeledContentStyle.mhKeyValue` for key-value
  rows.
- Kept SwiftUI-native: `List`, inline navigation title, `ShareLink`,
  toolbar actions, `confirmationDialog`, and alert.

Entry editor and preset editor:

- Adopted: `mhFormChrome()`, package-owned `MHSectionHeader`, explicit
  `LabeledContentStyle.mhKeyValue` rows, shared photo surface metrics, and
  `MHActionGroup` for related photo actions.
- Kept SwiftUI-native: `Form`, text fields, segmented precision picker,
  date/month/year pickers, cancellation/confirmation toolbar items, discard
  confirmation, and save alerts. Native form grouping intentionally replaces
  detached `mhInputChrome()` on these fields.

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
- Content lists and editor forms now use package-owned canvas chrome while
  retaining their complete native viewport, platform grouping, and SwiftUI
  controls.
- Entry detail presents time together through `MHSummary` in the first list
  section, separating screen context from the detail rows without adding a
  detached scroll container.
- Empty states now keep native `ContentUnavailableView` semantics while using
  one Fluel wrapper for MHUI spacing and action styling. They overlay empty
  chromed lists instead of becoming oversized native list rows.

MHUI family fit:

- The app now shares screen, summary, row, badge, section, empty-state,
  key-value, and primary-action rhythm while native forms own input grouping.
- Product meaning still comes from Fluel's own copy, sample entries, screen
  composition, and active/archive separation.
- The family resemblance is stronger without making the UI louder or less
  iOS-native.

Intentionally preserved:

- Native `List`, `Form`, search, menus, pickers, swipe actions, share, alerts,
  and confirmation dialogs remain in place.
- The adaptive navigation sidebar keeps native split-view behavior, selection
  semantics, and collapse behavior while receiving MHUI canvas and row
  treatment.
- Product language remains Entry, Start, Precision, Time together, Archive,
  Timeline, Milestone, and Preset.

Superseded package decisions:

- The 1.10 audit deferred `mhListChrome()`, `mhFormChrome()`, and broader
  row chrome because their then-current appearance flattened native grouped
  cards without adding a complete replacement hierarchy.
- MHUI 1.11 changes that contract: achromatic canvas treatment, readable-width
  container chrome, package headers, row chrome, input chrome, and
  `MHSummary` now form one explicit composition system. The new implementation
  adopts those pieces together instead of applying a single modifier in
  isolation.
- MHUI 1.12 replaces the native-container parts of that 1.11 treatment with
  full-viewport, platform-selected `List` and `Form` geometry. Fluel keeps the
  semantic package components while removing detached lead content and input
  chrome that compete with native container ownership.
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
- AX2 entry editing with native start controls, unclipped date value, and
  vertically adapting MHUI key-value rows.
- MHUI 1.12 full-viewport list and form geometry on iPhone and iPad.
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

The MHUI 1.16 follow-up recorded these successful checks on 2026-07-23:

- The 1.16 release notes, `1.15...1.16` source diff, adoption guide, public
  sample, and Fluel call sites were reviewed together.
- Xcode-native builds succeeded with scheme `Fluel` on the discovered iPhone
  17 Pro iOS 27 Simulator destination.
- The dense Dashboard Preview rendered in Japanese at standard and AX3 Dynamic
  Type sizes.
- Live iPhone and iPad checks covered the dense Dashboard and its Highlights
  section. The compact layout stacked the leading and supporting features; the
  regular-width layout kept the leading feature wider than its supporting
  feature. Long text wrapped without clipping or overlap.
- The active Xcode destination was restored to `iPhone 17 Pro for Fluel` after
  the iPad check.
- `bash ci_scripts/tasks/format_swift.sh`,
  `bash ci_scripts/tasks/lint_swift.sh`,
  `bash ci_scripts/tasks/check_repository_rules.sh`,
  `bash ci_scripts/tasks/check_localizations.sh`, and `git diff --check`.
- `bash ci_scripts/tasks/verify_task_completion.sh`, including 66 library tests
  in 15 suites and the fallback app build.

The MHUI 1.12 follow-up recorded these successful checks on 2026-07-17:

- Official 1.12 release notes, the `1.11...1.12` source diff, migration guide,
  package verification notes, and Fluel call sites were reviewed together.
- A before-and-after iPad Pro 11-inch root Preview confirmed that applying
  `mhListChrome()` and `mhRow()` removes the unrelated system-colored sidebar
  plane while preserving split-view structure and selection behavior.
- The corrected root rendered on iPad in light and dark appearances and on
  iPhone 17 Pro in the compact navigation layout.
- Xcode-native build with scheme `Fluel`, Debug, and the discovered iPhone 17
  Pro iOS 27 Simulator destination completed with no warning or error.
- The app launched through Xcode and reached `startup.ready`. The remaining
  runtime messages were the expected unsigned-in Simulator CloudKit and system
  service diagnostics, with no Fluel or MHUI runtime failure.
- Direct Xcode-native Preview rendering covered active entries, dense
  dashboard, entry detail, the filled entry editor, and custom presets on
  iPhone 17 Pro.
- The filled editor was re-rendered at AX2 before and after narrowing
  `.mhKeyValue` to explicit `LabeledContent` rows. The native date control
  changed from a clipped horizontal value to a complete vertical layout.
- Dense dashboard and the filled editor rendered on iPad Pro 11-inch without
  central viewport compression, detached chrome, or broken regular-width
  grouping.
- The Xcode scheme remained `Fluel`, and the destination was restored to
  `iPhone 17 Pro for Fluel` after iPad coverage.
- `bash ci_scripts/tasks/format_swift.sh`,
  `bash ci_scripts/tasks/lint_swift.sh`, and
  `bash ci_scripts/tasks/check_repository_rules.sh`.
- `git diff --check`.

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
- Markdown lint was not run because `markdownlint` was not available on the
  local `PATH`.
