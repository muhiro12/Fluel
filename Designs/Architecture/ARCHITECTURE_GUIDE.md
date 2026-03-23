# Fluel Architecture Guide

Current as of March 22, 2026.

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

| Target | Consumer type | Base product | Optional additions | Not adopted |
| --- | --- | --- | --- | --- |
| `Fluel` | UI and composition root | `MHAppRuntime` | `MHMutationFlow`, `MHLogging` | `MHPlatform` umbrella, route shell, review shell |
| `FluelWidget` | Passive UI extension | No MHPlatform product adoption | None | `MHPlatform` umbrella, runtime shell, mutation shell, review shell |
| `FluelLibrary` | Shared logic library | No MHPlatform product adoption | None | `MHPlatform` umbrella, `MHAppRuntimeCore`, `MHAppRuntime`, `MHMutationFlow`, `MHReviewPolicy` |
| `FluelTests` | App integration bundle | App-owned `Fluel` / `FluelLibrary` test surface | None | `MHPlatform` umbrella imports in test support |

The current app is a default-runtime consumer: it selects `MHAppRuntime` as the
base product because Fluel uses package-owned license presentation and the
debug-only native ad path. It uses `MHAppRuntimeBootstrap` as the root entry
and adds `MHMutationFlow` only where the app target owns mutation follow-up
side effects. Route and review shells remain out of scope until the product
actually needs them.

## Canonical Mutation Flow

`View -> FluelEntryMutationWorkflow -> EntryRepository -> SwiftData write -> Observation/@Query updates`

`FluelEntryMutationWorkflow` may trigger app-side follow-up actions after a
successful mutation, but the mutation rules themselves belong in
`FluelLibrary`.

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

Not allowed in views:

- Reusable validation branching
- Archive/delete policy decisions
- Shared elapsed-time or milestone calculations
- Widget snapshot construction rules

## Current Alignment Notes

- `Fluel/App/FluelAppAssembly.swift`, `Fluel/App/FluelApp.swift`, and
  `Fluel/Features/Main/MainView.swift` keep app startup, typed environment
  injection, and the per-tab navigation shell in the app target.
- `Fluel/Support/Mutation/FluelEntryMutationWorkflow.swift` is the right place
  for widget reload follow-up orchestration.
- `Fluel/Features/License/FluelLicenseView.swift` keeps app-owned presentation
  while delegating the license list surface to `MHAppRuntime`.
- `FluelWidget/Sources/LeadEntryWidgetProvider.swift` stays thin by delegating
  snapshot building to `FluelLibrary`.
- `FluelLibrary/Sources/Entry/EntryRepository.swift` remains the canonical
  mutation and query entry point for shared entry rules.

## Repository Guards

- `Fluel.xcodeproj` consumes `MHPlatform` from the remote GitHub package and
  intentionally keeps a Fluel-specific semver policy: `upToNextMajorVersion`
  from `1.0.0`, no local-path override, and no floating branch, even though
  MHPlatform release docs recommend exact tags for released consumers.
- `Fluel.xcodeproj` consumes `MHUI` from the remote GitHub package and keeps
  the same repository-wide `1.x` semver tracking policy starting at `1.0.0`.
- `ci_scripts/tasks/check_mhplatform_adoption.sh` enforces the Fluel-specific
  MHPlatform contract: remote-only, no local-path adoption, no floating branch,
  no `import MHPlatform` umbrella usage, and resolved pins within the approved
  `1.x` semver range.
- `ci_scripts/tasks/check_mhui_adoption.sh` blocks local-path `MHUI`,
  floating-branch tracking, and remote-package drift away from the approved
  `1.x` semver range.
- `ci_scripts/tasks/check_shared_library_boundaries.sh` keeps app-only
  frameworks and app-facing MHPlatform shells out of `FluelLibrary/Sources`.
- `ci_scripts/tasks/test_app_integration.sh` verifies the app-owned mutation
  workflow against an in-memory SwiftData container.
- `ci_scripts/tasks/run_required_builds.sh` runs the MHPlatform adoption check,
  shared-library boundary check, app build, app integration test, and screen
  capture flow when the changed paths require them.
