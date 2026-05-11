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

## Feature highlights

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

## Architecture and technologies

- **SwiftData + App Group** - the app and widget read from the same store at
  `group.com.muhiro12.Fluel/Fluel.sqlite`.
- **Shared library source of truth** - reusable entry mutation, query,
  formatting, and widget snapshot logic belongs in `FluelLibrary`.
- **Widget bridge** - `LeadEntryWidgetProvider` reads shared snapshots from
  `FluelLibrary`, while `FluelWidget` owns WidgetKit timeline delivery and
  rendering.
- **Preview and capture support** - the app can boot sample data for previews
  and Codex capture flows without changing live storage.

## Architecture records

- Thin targets in this repository are responsibility-thin, not
  line-count-thin. `Fluel` and `FluelWidget` may still own SwiftUI shells,
  lifecycle wiring, routing, WidgetKit policy, and framework adapters, but
  reusable entry rules and shared widget contracts belong in `FluelLibrary`.
- `FluelLibrary` owns the shared SwiftData model, mutation/query services,
  formatting, and widget snapshot builders.
- `Fluel` and `FluelWidget` consume those shared APIs and remain the place for
  Apple-specific integration work such as SwiftUI presentation, TipKit,
  PhotosUI, WidgetKit, app runtime wiring, ads, and licenses.
- Automated unit tests stay in `FluelLibrary/Tests`. This repository does not
  add separate unit test targets for `Fluel` or `FluelWidget`; those adapters
  are verified through builds plus shared-library tests.
- Start detailed architecture reading from
  [ARCHITECTURE_GUIDE.md](Designs/Architecture/ARCHITECTURE_GUIDE.md),
  [shared-entry-surface-design.md](Designs/Architecture/shared-entry-surface-design.md),
  and
  [fluel-current-overview.md](Designs/Overviews/fluel-current-overview.md).

## Platform package posture

- `Fluel` intentionally adopts the full `MHPlatform` umbrella because the app
  uses package-owned runtime surfaces, the license list surface, mutation
  follow-up shell support, and the debug-only native ad path.
- `FluelLibrary` intentionally adopts `MHPlatformCore` as the shared-library
  umbrella for core-safe platform helpers.
- `FluelWidget` intentionally stays off direct MHPlatform package adoption.
- This repository intentionally tracks MHPlatform and MHUI with the 1.x semver
  range starting at `1.0.0`.

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
3. If you are shipping a fork with your own identifiers, update
   `FluelLibrary/Sources/Common/AppGroup.swift`,
   `Fluel/Fluel.entitlements`, and
   `FluelWidget/Configurations/FluelWidget.entitlements`.
4. Open `Fluel.xcodeproj` in Xcode, select the **Fluel** scheme, and run on an
   iOS 26 simulator or device.
5. Enable the **FluelWidget** scheme as needed when testing the widget
   extension.

## Build And Test

Use the helper scripts in `ci_scripts/` as needed. The repository contract is:
Direct entrypoints live in `ci_scripts/tasks/`, shared shell helpers live in
`ci_scripts/lib/`, and `ci_scripts/ci_post_clone.sh` is reserved for external
post-clone CI setup.

- `bash ci_scripts/tasks/check_environment.sh --profile <format|build|verify>`
  diagnoses missing local prerequisites before you start a tool-dependent flow.
- `bash ci_scripts/tasks/format_swift.sh` is the explicit SwiftLint autofix
  step to run after Swift edits and before the final verification gate.
- `bash ci_scripts/tasks/lint_swift.sh` reruns SwiftLint in strict mode without
  modifying source files.
- `bash ci_scripts/tasks/verify_task_completion.sh` is the non-destructive
  verification gate for Codex task completion.
- `bash ci_scripts/tasks/verify_pre_push.sh` is the optional Git `pre-push`
  wrapper for the same non-destructive verification gate.
- `bash ci_scripts/tasks/verify_repository_state.sh` checks the current
  repository state and still writes CI run artifacts.
- Release UI smoke auditing is intentionally separate from the normal verify
  gate. Use the global `$xcode-ui-smoke-auditor` skill and the
  [release UI smoke audit guide](Designs/Architecture/release-ui-smoke-audit.md)
  when a release or UI-sensitive change needs live Simulator evidence.

SwiftLint is resolved from the `SimplyDanny/SwiftLintPlugins` package declared
in `Fluel.xcodeproj`. The repository scripts do not require a separately
installed `swiftlint` binary on your `PATH`.
By default, `format_swift.sh` and `lint_swift.sh` operate on local Swift
changes. Set `CI_SWIFTLINT_ALL=1` when you need a full tracked-file sweep.

Before running the full verify gate, diagnose the local prerequisites:

```sh
bash ci_scripts/tasks/check_environment.sh --profile verify
```

After Swift edits, run the explicit autofix step:

```sh
bash ci_scripts/tasks/format_swift.sh
```

Then run the non-destructive full recheck:

```sh
bash ci_scripts/tasks/verify_task_completion.sh
```

For release-time verification or a clean-worktree full run, force the standard
verify entrypoint to execute all required checks:

```sh
CI_RUN_FORCE_FULL=1 bash ci_scripts/tasks/verify_task_completion.sh
```

If you only need the optional pre-push wrapper shell:

```sh
bash ci_scripts/tasks/verify_pre_push.sh
```

If you prefer to run the SwiftLint steps directly:

```sh
bash ci_scripts/tasks/format_swift.sh
bash ci_scripts/tasks/lint_swift.sh
```

If you only need required builds/tests based on local changes:

```sh
bash ci_scripts/tasks/verify_repository_state.sh
```

If you only need the app build:

```sh
bash ci_scripts/tasks/build_app.sh
```

If you want to verify the existing Codex capture screens after an app build:

```sh
bash ci_scripts/tasks/test_capture_screens.sh
```

If you only need library tests:

```sh
bash ci_scripts/tasks/test_shared_library.sh
```

If you want Git's `pre-push` hook to enforce the same repository flow, configure
the hook to delegate to `bash ci_scripts/tasks/verify_pre_push.sh`.

The scripts below are optional targeted helpers, not standardized repository
entrypoints.

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
- [Release UI smoke audit](./Designs/Architecture/release-ui-smoke-audit.md)
- [Architecture decisions](./Designs/Decisions)
