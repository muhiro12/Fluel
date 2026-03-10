# Shared Entry Surface Design

## Purpose

This document describes the current boundary for shared entry logic in Fluel.
It explains where new code should live when the same operation must work across
the iOS app and widget extension.

## Core Principles

- `FluelLibrary` is the source of truth for shared entry logic.
- `Fluel` owns SwiftUI presentation and adapters for Apple frameworks.
- `FluelWidget` owns WidgetKit timeline delivery and rendering.
- Views keep presentation state and navigation, but reusable business decisions
  and mutations belong in shared services.
- `FluelLibrary` remains a single module unless there is a stronger reason than
  code organization alone.

## Responsibility Boundaries

| Concern | Lives in | Examples |
| --- | --- | --- |
| Shared domain logic | `FluelLibrary` | `Entry`, `EntryRepository`, `EntryFormInput`, `EntryListOrdering`, `EntrySearchMatcher`, `EntryContentFilter`, `EntryFormatting`, `EntryWidgetSnapshotQuery`, `ModelContainerFactory` |
| Apple framework adapters | `Fluel`, `FluelWidget` | `FluelEntryMutationWorkflow`, `FluelWidgetReloader`, `FluelSharedPreferences`, `LeadEntryWidgetProvider`, TipKit bootstrap |
| App-side platform support | `Fluel/App`, `Fluel/Support` | `FluelApp`, `FluelAppConfiguration`, preset storage, display preferences, app style, runtime logging |
| Presentation orchestration | `Fluel/Features` | SwiftUI views, navigation state, sheet presentation, form draft state, confirmation dialogs |

## Canonical Shared APIs

The following types are the current shared entry points for reusable
operations:

- `EntryFormInput`
- `EntryRepository.create(context:input:now:calendar:)`
- `EntryRepository.update(context:entry:input:now:calendar:)`
- `EntryRepository.archive(context:entry:now:)`
- `EntryRepository.restore(context:entry:now:)`
- `EntryRepository.delete(context:entry:)`
- `EntryListOrdering`
- `EntryContentFilter`
- `EntrySearchMatcher`
- `EntryCollectionSnapshotQuery`
- `EntryActivitySnapshotQuery`
- `EntryActivityTimelineSectionQuery`
- `EntryActivityTimelineSummaryQuery`
- `EntryActivityTrendSnapshotQuery`
- `EntryMilestoneSnapshotQuery`
- `EntryWidgetSnapshotQuery`
- `ModelContainerFactory`

## Placement Rules

1. If an operation is reusable across the app and widget, add or extend a
   library API first.
2. If an operation depends on Apple-only frameworks such as WidgetKit, TipKit,
   PhotosUI, or app runtime wiring, keep it in `Fluel` or `FluelWidget` and
   make it call library APIs.
3. If a view starts recreating elapsed-time formatting, milestone logic,
   archive/delete rules, or share-text logic, treat that as a missing library
   API.
4. Keep `UserDefaults`, WidgetKit reload behavior, TipKit setup, and runtime
   bootstrap code out of `FluelLibrary`.
5. If glue code is app-only but reused by multiple screens, factor it into
   `Fluel/Support/` instead of duplicating it in views.

## Current Examples

- `FluelEntryMutationWorkflow` stays in `Fluel` because it executes widget
  reload side effects after shared mutations complete.
- `LeadEntryWidgetProvider` stays in `FluelWidget` because WidgetKit timeline
  policy is extension-specific, but it delegates snapshot building to
  `EntryWidgetSnapshotQuery`.
- `ModelContainerFactory`, `AppGroup`, and `Database` stay in `FluelLibrary`
  because both the app and widget need the same storage contract.
- `FluelSampleData` is an intentional exception under
  `FluelLibrary/Sources/Preview/` because preview infrastructure is shared
  across app previews, widget placeholders, and tests.
- `FluelSharedPreferences` and preset storage stay in the app target because
  they are runtime preference adapters, not shared business logic.

## Refactoring Heuristic

When a business rule is duplicated, the default fix is to move the rule into
`FluelLibrary` rather than duplicating it in another view or target.
When the duplicated code is still Apple-framework glue, the default fix is to
extract it into `Fluel/Support/`.
