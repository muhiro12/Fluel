# Fluel Current Product and Architecture Overview

Current as of March 21, 2026.

## Purpose

Fluel is a SwiftUI app for tracking how long the user has been living with
specific things or places. The current product is implemented as one shared
domain library plus two surfaces:

- An iPhone app for entry creation, browsing, insights, settings, and archive
  management
- A WidgetKit extension for glanceable lead-entry status

The current implementation is intentionally biased toward a single source of
truth for reusable entry logic in `FluelLibrary`, with platform adapters and UI
living in the app and widget targets.

## Product Surface Summary

| Surface | Current role | Key responsibilities |
| --- | --- | --- |
| `Fluel` | Primary product surface | Create and edit entries, browse active and archived items, manage presets, review timeline activity, inspect dashboard insights, configure settings |
| `FluelWidget` | Passive glanceable surface | Show the lead active entry, elapsed time, collection counts, one milestone, and one recent activity item |
| `FluelLibrary` | Shared domain layer | SwiftData model, mutation/query helpers, ordering/filtering/search helpers, formatting, preview data, widget snapshot projection |

## Current End-User Features

### 1. Entry creation and editing

- Create entries with day, month, or year precision.
- Edit existing entries from the detail surface.
- Attach an optional photo from `PhotosPicker`.
- Write an optional free-form note.
- Duplicate an existing entry into a new create flow.

### 2. Active and archived entry management

- Browse active entries with sorting, content filtering, and search.
- Archive and restore entries from detail and list-driven flows.
- Permanently delete archived entries after confirmation.
- Open a dedicated archive screen with its own sorting, filtering, and search.

### 3. Presets and quick create flows

- Use built-in starter presets for common belongings.
- Create and edit custom presets.
- Pin presets and track recently used presets.
- Configure a default preset for new entry creation.
- Trigger quick create flows from preset suggestions on main surfaces.

### 4. Timeline and sharing

- Group added, updated, and archived activity by recent month sections.
- Filter timeline activity by kind and scope.
- Search visible activity text.
- Share timeline summaries as formatted text.

### 5. Dashboard insights

- Show active and archived collection counts.
- Highlight the lead active entry.
- Surface upcoming milestones.
- Surface recent activity summaries.

### 6. Widget surface

- Read the shared store from the same App Group container as the app.
- Show the lead active entry in small and medium widget layouts.
- Present elapsed time, start label, collection counts, one upcoming milestone,
  and one recent activity item.
- Refresh on the next local `00:05`.

### 7. Settings and guidance

- Manage display preferences for list cards, note previews, and metadata badges.
- Open archive and licenses from Settings.
- Reset TipKit state for testing.
- Guide users with TipKit across create, preset, filter, dashboard, and detail
  flows.

### 8. Preview and internal capture support

- Seed sample data through `FluelSampleData` for previews and tests.
- Boot Codex capture flows from debug launch arguments without touching the live
  store.

## Data Model and Storage Design

### Core model

`Entry` is the central persisted record and currently stores:

- `title`
- `startPrecision`
- `startYear`
- `startMonth`
- `startDay`
- optional `photoData`
- optional `note`
- `archivedAt`
- `createdAt`
- `updatedAt`

### Persistence and sharing

- The canonical SwiftData store lives at
  `group.com.muhiro12.Fluel/Fluel.sqlite`.
- Both the app and widget targets share the same App Group entitlement
  `group.com.muhiro12.Fluel`.
- App-side display preferences and preset state live in the runtime
  `UserDefaults` suite `com.muhiro12.Fluel.runtime`.

## Architecture Summary

- `FluelLibrary` owns reusable mutation and query rules through types such as
  `EntryRepository`, `EntryListOrdering`, and snapshot query helpers.
- `Fluel` owns the app assembly, SwiftUI presentation, runtime bootstrap,
  preferences, TipKit, and mutation follow-up orchestration through app-side
  adapters such as `FluelEntryMutationWorkflow`.
- The app shell injects `EntryPresetStore` once through typed SwiftUI
  environment values and uses Observation for app-owned preset state.
- `MainView` keeps one `NavigationStack` per primary tab so Home, Timeline,
  Dashboard, and Settings retain independent navigation state.
- `FluelWidget` stays thin by building timeline entries from shared
  `EntryWidgetSnapshotQuery` results rather than owning duplicate business
  logic.

## Current Integration Boundaries

- WidgetKit with shared App Group storage
- PhotosUI for optional entry photos
- `ShareLink`-based sharing from detail and timeline views
- `MHAppRuntime` default adapter integration with the runtime-owned license
  surface enabled
- A debug-only native AdMob path in live runtime configuration, disabled for
  Codex capture mode
- No App Intents or App Shortcuts targets in the current repository
