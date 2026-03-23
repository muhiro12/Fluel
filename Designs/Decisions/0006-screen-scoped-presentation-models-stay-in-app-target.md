# ADR 0006: Screen-Scoped Presentation Models Stay in App Target

- Date: 2026-03-23
- Status: Accepted

## Context

Large Fluel feature views were accumulating search state, filter persistence,
sheet routing, confirmation dialog state, and error presentation directly in
the SwiftUI view body. That made app-side behavior harder to review and pushed
screen orchestration into the same place as rendering.

## Decision

Keep screen-scoped `@Observable` presentation models, routers, and
coordinators in the app target. Root views own those models in `@State` and
pass them downward with typed environment values or `@Bindable`.

## Consequences

- `MainTabRouter` owns app-tab navigation and sheet routing.
- `HomeScreenModel`, `ArchiveScreenModel`, `TimelineScreenModel`,
  `SettingsScreenModel`, `PresetSettingsScreenModel`,
  `EntryFormPresentationModel`, and `EntryDetailPresentationModel` own
  screen-level presentation state.
- Views stay focused on layout, display-only formatting, and dispatching user
  actions to app-owned models or shared-library APIs.
- `ObservableObject` and `EnvironmentObject` are not the default pattern for
  new Fluel screen state.
