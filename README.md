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
- **Thin adapters** - `Fluel` owns SwiftUI presentation, runtime wiring,
  preferences, TipKit, and mutation follow-up side effects, while
  `FluelWidget` owns WidgetKit timeline delivery.
- **Preview and capture support** - the app can boot sample data for previews
  and Codex capture flows without changing live storage.

## Requirements

- Xcode 16 or later with the iOS 18 SDK installed.
- An Apple Developer account configured for App Groups and widget entitlements
  if you plan to sign and run your own build.
- An iPhone simulator or device that supports iOS 18.

## Setup

1. Clone the repository and open the project directory.
2. Update bundle identifiers, entitlements, and
   `FluelLibrary/Sources/Common/AppGroup.swift` if you are not using the
   production identifiers.
3. Open `Fluel.xcodeproj` in Xcode, select the **Fluel** scheme, and run on an
   iOS 18 simulator or device.
4. Enable the **FluelWidget** scheme as needed when testing the widget
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

If you only need library tests:

```sh
bash ci_scripts/tasks/test_shared_library.sh
```

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
