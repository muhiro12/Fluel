# Fluel Architecture Guide

Current as of March 23, 2026.

## Scope

This guide defines the `domain-in-library, UI-as-adapter` policy for Fluel.

Related documents:
[shared-entry-surface-design.md](./shared-entry-surface-design.md)
[../Overviews/fluel-current-overview.md](../Overviews/fluel-current-overview.md)

## Responsibility Boundaries

| Layer | Owns | Must not own |
| --- | --- | --- |
| Domain (`FluelLibrary`) | `Entry` model, entry mutation and query rules, search/filter helpers, formatting, shared database location helpers, widget snapshot projection | App runtime wiring, TipKit bootstrap, WidgetKit reloads, `UserDefaults` suite access, SwiftUI navigation state |
| Adapter (`Fluel`, `FluelWidget`) | App bootstrap, platform preferences, mutation follow-up side effects, widget timeline policy, shared container wiring | Re-implementing entry validation, archive/delete rules, elapsed-time rules, widget snapshot calculations |
| View (SwiftUI) | Navigation, sheet state, focus, display composition, display-only formatting, user interaction flow | Reusable validation rules, persistence branching, domain calculations |

## MHPlatform Consumer Classification

| Target | Consumer type | Primary product | Add only when needed | Avoid by default |
| --- | --- | --- | --- | --- |
| `Fluel` | Full-platform app target | `MHPlatform` | `MHMutationFlow` concerns inside app-owned mutation adapters | Direct split runtime bundles, route shell, review shell |
| `FluelWidget` | Passive UI extension | No MHPlatform product adoption | None | `MHPlatform`, `MHAppRuntime`, split runtime bundles, mutation shell, review shell |
| `FluelLibrary` | Shared logic library | `MHPlatformCore` or granular core-safe modules if platform access is ever needed | Concrete core-safe modules only when a shared concern genuinely needs them | `MHPlatform`, `MHAppRuntime`, split runtime bundles, `MHMutationFlow`, `MHReviewPolicy` |
| `FluelTests` | App integration bundle | App-owned `Fluel` / `FluelLibrary` test surface | `MHPlatformTesting` only if test support becomes necessary | `MHPlatform` umbrella imports in test support |

The current app is a full-platform consumer: it selects `MHPlatform` as the
base product because Fluel wants the one-step package-owned path for license
presentation and the debug-only native ad configuration. It still uses
`MHAppRuntimeBootstrap` as the root entry and keeps mutation follow-up as an
app-owned optional concern. `FluelLibrary` currently has no MHPlatform
dependency; if platform access ever moves into the shared library, it must stop
at `MHPlatformCore` or a granular core-safe module.

## Canonical Mutation Flow

`View -> FluelEntryMutationWorkflow -> EntryRepository -> SwiftData write -> Observation/@Query updates`

`FluelEntryMutationWorkflow` may trigger app-side follow-up actions after a
successful mutation, but the mutation rules themselves belong in
`FluelLibrary`.

## Failure-Surfacing Contract

Adapter-owned mutation paths must classify failures by phase.

- Preflight failure before mutation: block success and keep the current screen.
- Primary domain mutation failure: block success and surface the error to the
  current caller.
- Post-commit follow-up failure: treat as degraded success, preserve the
  committed write, log the phase explicitly, and prefer repairable notices over
  rollback claims.

## Widget Flow

`Widget provider -> ModelContainerFactory.shared() -> EntryWidgetSnapshotQuery -> Widget view`

The widget extension may own timeline scheduling and WidgetKit presentation, but
shared snapshot building belongs in `FluelLibrary`.

## SwiftData Boundary

Keep in `FluelLibrary`:

- `@Model` types
- `FetchDescriptor` and query helpers
- Shared mutation and archive rules
- Shared formatting and widget snapshot values
- Database location and container factory helpers

Keep in `Fluel` or `FluelWidget`:

- `ModelContainer` bootstrapping at app or widget startup
- App runtime integration
- TipKit setup and platform preferences
- Widget reloads and timeline refresh policy
- View-specific orchestration

## View Rules

Allowed in views:

- Navigation and dismissal
- Confirmation dialogs and alerts
- Focus and picker state
- Display-only formatting and composition
- Owning one small screen-scoped `@Observable` presentation model in the root
  view through `@State`

Not allowed in views:

- Reusable validation branching
- Archive/delete policy decisions
- Shared elapsed-time or milestone calculations
- Widget snapshot construction rules
- Large collections of search, filter, sheet, dialog, or error state when a
  screen-scoped model can own them

## Screen-Scoped Presentation Models

When a screen grows beyond trivial local state, keep a small `@Observable`
presentation model or router in the root view's `@State` and pass it downward
with typed environment values or `@Bindable`.

Prefer this over:

- `ObservableObject`
- `EnvironmentObject`
- piling multiple preference, dialog, sheet, and error flags directly into the
  view

Current examples should include `MainTabRouter`, `HomeScreenModel`,
`ArchiveScreenModel`, `TimelineScreenModel`, `SettingsScreenModel`,
`PresetSettingsScreenModel`, `EntryFormPresentationModel`, and
`EntryDetailPresentationModel`.

## Current Alignment Notes

- `Fluel/App/FluelAppAssembly.swift`, `Fluel/App/FluelApp.swift`, and
  `Fluel/Features/Main/MainView.swift` keep app startup, typed environment
  injection, and the per-tab navigation shell in the app target.
- `Fluel/Support/Mutation/FluelEntryMutationWorkflow.swift` is the right place
  for widget reload follow-up orchestration.
- `Fluel/Features/License/FluelLicenseView.swift` keeps app-owned presentation
  while delegating the license list surface to `MHPlatform`.
- `FluelWidget/Sources/LeadEntryWidgetProvider.swift` stays thin by delegating
  snapshot building to `FluelLibrary`.
- `FluelLibrary/Sources/Entry/EntryRepository.swift` remains the canonical
  mutation and query entry point for shared entry rules.

## Repository Guards

- `Fluel.xcodeproj` consumes `MHPlatform` from the remote GitHub package and
  keeps the repository-wide remote semver policy: `upToNextMajorVersion` from
  `1.0.0`, no local-path override, and no floating branch.
- `Fluel.xcodeproj` consumes `MHUI` from the remote GitHub package and keeps
  the same repository-wide `1.x` semver tracking policy starting at `1.0.0`.
- `ci_scripts/tasks/check_mhplatform_adoption.sh` enforces the 1.2 Fluel
  contract: remote-only MHPlatform, app target base product on `MHPlatform`, no
  floating branch, and resolved pins within the approved `1.x` semver range.
- `ci_scripts/tasks/check_mhui_adoption.sh` blocks local-path `MHUI`,
  floating-branch tracking, and remote-package drift away from the approved
  `1.x` semver range.
- `ci_scripts/tasks/check_shared_library_boundaries.sh` keeps app-only
  frameworks and app-facing MHPlatform surfaces out of `FluelLibrary/Sources`
  while leaving `MHPlatformCore` and granular core-safe modules available if a
  shared concern ever needs them.
- `ci_scripts/tasks/check_repository_contracts.sh` blocks references to removed
  verify script names, removed docs aliases, and removed legacy artifact paths.
- `ci_scripts/tasks/test_app_integration.sh` verifies the app-owned mutation
  workflow against an in-memory SwiftData container.
- `ci_scripts/tasks/verify_repository_state.sh` runs the boundary checks, app
  build, app integration test, shared-library tests, and screen capture flow
  when the changed paths require them.
