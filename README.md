# Fluel

## Overview

Fluel is a SwiftUI iOS app for tracking how long the user has been living with
specific things or places. It stores data in a shared SwiftData container,
shares the same entry model with its widget extension, and keeps reusable entry
logic in `FluelLibrary`.

## Targets

- **Fluel** - the iOS app for active and archived entry browsing, entry
  creation, timeline history, dashboard insights, presets, and settings.
- **FluelWidget** - the WidgetKit extension that surfaces the lead active entry
  with elapsed time, collection counts, milestones, and recent activity.
- **FluelLibrary** - the shared domain layer containing the `Entry` model,
  mutation/query helpers, formatting, preview data, and widget snapshot
  projection used by both surfaces.

## Feature Highlights

### Entry tracking

- Create and edit entries with day, month, or year precision.
- Attach optional photos and free-form notes.
- Archive, restore, duplicate, share, and permanently delete entries.

### Browsing and insights

- Browse active entries with sorting, content filters, search, and quick preset
  actions.
- Review added, updated, and archived activity in the timeline.
- Inspect dashboard counts, milestone timing, and recent activity summaries.

### Presets, settings, and guidance

- Use built-in and custom presets, pin favorites, and configure a default
  create preset.
- Manage display preferences, archive access, licenses, and TipKit resets from
  Settings.
- Guide users with TipKit across creation, presets, filters, dashboard, and
  detail actions.

### Shared widget experience

- Reuse the same SwiftData store through the shared App Group container.
- Build widget-ready data in `FluelLibrary` and keep WidgetKit rendering in
  `FluelWidget`.

## Architecture And Technologies

- **SwiftData + App Group** - the app and widget read from the same store at
  `group.com.muhiro12.Fluel/Fluel.sqlite`.
- **Shared library source of truth** - reusable mutation, query, formatting,
  and widget snapshot logic belongs in `FluelLibrary`.
- **Observation-first app shell** - app-owned preset state is injected once
  from the app assembly through typed SwiftUI environment values.
- **Thin adapters** - `Fluel` is a full-platform app target that centers app
  startup on `MHAppRuntimeBootstrap` through `MHPlatform`, keeps presentation,
  preferences, TipKit, and mutation follow-up side effects app-owned, and
  leaves WidgetKit delivery to `FluelWidget`.
- **Per-tab navigation roots** - the main shell keeps a separate
  `NavigationStack` per primary tab so each tab preserves its own navigation
  history while keeping create and licenses presentation local to that tab.
- **Optional shell additions** - mutation follow-up stays an app-owned concern
  and uses the umbrella-exported `MHMutationFlow` surface only where the app
  target actually owns that work.
- **Full-platform app base product** - the app adopts `MHPlatform` because
  Fluel wants the one-step package-owned runtime path for license presentation
  and the debug-only native ad path while disabling ads for Codex capture mode.
- **Shared-library platform path** - `FluelLibrary` currently has no MHPlatform
  dependency; if it needs platform access later, it must stop at
  `MHPlatformCore` or a granular core-safe module instead of app-facing
  umbrellas.
- **Repo-specific package governance** - Fluel keeps MHPlatform as a remote
  semver-tracked `1.x` dependency starting at `1.0.0`, while resolving the
  current published 1.2 line in `Package.resolved`.
- **Preview and capture support** - the app can boot sample data for previews
  and Codex capture flows without changing live storage.

## Requirements

- Xcode 26 or later with the iOS 26 SDK installed.
- An Apple Developer account configured for App Groups and widget entitlements
  if you plan to sign and run your own build.
- An iPhone simulator or device that supports iOS 26.

## Setup

1. Clone the repository and open the project directory.
2. Update bundle identifiers, entitlements, and
   `FluelLibrary/Sources/Common/AppGroup.swift` if you are not using the
   production identifiers.
3. If you add provider credentials or release-only identifiers later, keep
   them in ignored local files instead of tracked source files. Keep
   `Secret.swift`, `GoogleService-Info.plist`, `.env`, and signing assets out
   of git, and validate with
   `bash ci_scripts/tasks/check_public_repo_safety.sh` before publishing.
4. Open `Fluel.xcodeproj` in Xcode, select the **Fluel** scheme, and run on an
   iOS 26 simulator or device.
5. Enable the **FluelWidget** scheme as needed when testing the widget
   extension.

## Build And Test

Use the helper scripts in `ci_scripts/` as needed. For full local verification:

```sh
bash ci_scripts/tasks/verify.sh
```

If you only need required builds and tests based on local changes:

```sh
bash ci_scripts/tasks/run_required_builds.sh
```

If you only need the app build:

```sh
bash ci_scripts/tasks/build_app.sh
```

If you only need the app integration test bundle:

```sh
bash ci_scripts/tasks/test_app_integration.sh
```

If you want to verify the existing Codex capture screens after an app build:

```sh
bash ci_scripts/tasks/test_capture_screens.sh
```

If you only need library tests:

```sh
bash ci_scripts/tasks/test_shared_library.sh
```

### Public Repository Safety

Before creating a public GitHub repository, run:

```sh
bash ci_scripts/tasks/check_public_repo_safety.sh
```

The same safety check also runs inside
`bash ci_scripts/tasks/run_required_builds.sh` and
`bash ci_scripts/tasks/verify.sh`.

### CI Script Layout

- `ci_scripts/tasks/` contains supported user-facing entrypoints such as
  `verify.sh`, `run_required_builds.sh`, `build_app.sh`,
  `test_app_integration.sh`, and `test_shared_library.sh`.
- `ci_scripts/lib/` contains shared shell helpers used by those task scripts.
  Reuse the existing helpers before copying setup or path-selection logic into
  another task.
- When you change only CI scripts or docs, `bash ci_scripts/tasks/verify.sh`
  may intentionally skip Xcode build and test work if no files changed under
  `Fluel/`, `FluelWidget/`, `FluelLibrary/`, or `Fluel.xcodeproj/`. In that
  case, also run the directly affected task scripts you changed.

### CI Artifact Layout

CI helper scripts write generated artifacts under `.build/ci/`.
Run-scoped outputs live in `.build/ci/runs/<RUN_ID>/` (`summary.md`,
`commands.txt`, `meta.json`, `logs/`, `results/`, `work/`), while shared cache
and build state live in `.build/ci/shared/` (`cache/`, `DerivedData/`, `tmp/`,
`home/`).

## Documentation

- [Current overview](./Designs/Overviews/fluel-current-overview.md)
- [Architecture guide](./Designs/Architecture/ARCHITECTURE_GUIDE.md)
- [Shared entry surface design](./Designs/Architecture/shared-entry-surface-design.md)
- [Architecture decisions](./Designs/Decisions)
