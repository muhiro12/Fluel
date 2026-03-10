# Fluel Product Overview

## Overview

Fluel is an iOS app for tracking how long the user has been living with
specific things or places. Each entry stores a title, a start date with
day/month/year precision, optional photo data, an optional note, archive state,
and created/updated timestamps. The product centers on active and archived
entries, activity history, milestone timing, and lightweight reflection.

## Targets and Shared Modules

- `Fluel/` is the iOS app target. It boots the shared SwiftData container,
  configures runtime services, and presents the main app navigation.
- `FluelLibrary/` is a shared Swift package for the app and widget. It owns the
  `Entry` model, collection and activity queries, formatting helpers,
  localization helpers, preview data, and widget snapshot projection.
- `FluelWidget/` is the WidgetKit extension. It renders the lead active entry
  from the shared store in small and medium widget layouts.

## App Surface

### Main Navigation

`MainView` provides four tabs: Home, Timeline, Dashboard, and Settings.
Archived entries are opened through navigation, while entry creation and
licenses are presented as sheets.

### Entry Workflows

Users can create and edit entries with day/month/year start precision, optional
photos via `PhotosPicker`, and free-form notes. Entry detail supports sharing,
duplicating, editing, archiving/restoring, and permanent deletion.

### Presets

The app includes built-in starter presets for home, wallet, bag, shoes, watch,
and plant. It also supports custom presets, pinning, recently used presets, and
a default preset that can prefill new entry creation.

### Insights and History

Home focuses on active entries with sorting, content filters, search, and quick
preset actions. Timeline groups added, updated, and archived activity with
activity-kind and scope filters plus shareable timeline text. Dashboard
aggregates collection counts, a lead active entry, upcoming milestones, and
recent activity. Archive provides a dedicated view for archived entries with its
own sorting, filtering, and search.

### Settings and Support

Settings manages display preferences, preset management, a collection summary,
archive access, licenses, and TipKit reset.

## Data and Persistence

`FluelLibrary` persists a single SwiftData `Entry` model in a shared SQLite
store located at `group.com.muhiro12.Fluel/Fluel.sqlite`. Both the app target
and widget extension declare the same App Group entitlement:
`group.com.muhiro12.Fluel`. App-side preferences and preset metadata are stored
in the runtime `UserDefaults` suite `com.muhiro12.Fluel.runtime`.

## Widget Surface

The extension surface is currently limited to `LeadEntryWidget`. It loads a
shared `ModelContainer`, builds an `EntryWidgetSnapshot`, and displays the lead
active entry's elapsed time, start label, collection counts, most recently
archived title, one upcoming milestone, and one recent activity item. The
widget supports `.systemSmall` and `.systemMedium` families and schedules its
next refresh for the next local `00:05`.

## Localization and Guidance

String catalogs exist in the app, library, and widget targets with English as
the source language and localized content for English, Spanish, French,
Japanese, and Simplified Chinese. TipKit is used across the main surfaces for
entry creation, preset selection, filters, dashboard overview, detail quick
actions, preset management, and default preset onboarding.

## Current Integration Boundaries

- WidgetKit with shared App Group storage
- PhotosUI for optional entry photos
- `ShareLink`-based sharing from detail and timeline views
- MH app runtime integration with licenses enabled
- A debug-only native AdMob ad unit path in app runtime configuration
- No App Intents or App Shortcuts targets in the current repository
