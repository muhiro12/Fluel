# Rebuild Baseline

Fluel treats CloudKit, App Intents, and English plus Japanese localization as
baseline rebuild capabilities rather than release-end additions.

## CloudKit

The app target owns SwiftData runtime configuration. Production launch uses a
CloudKit-backed `ModelContainer`, while previews, tests, and screenshot
scenarios use in-memory containers.

Keep CloudKit setup app-local. Do not add repository or service layers only to
wrap SwiftData or CloudKit while the app has one persistence surface.

## App Intents

App Intents live in the app target. They call `FluelLibrary` Operations through
thin app-side adapters and must not reimplement durable entry rules.

`FluelLibrary` may use `MHPlatformCore` for core-safe link contracts, but it
must not add `AppIntents`, SwiftUI, SwiftData, MHUI, MHDesign, the MHPlatform
umbrella product, or app-runtime framework dependencies. App-side App Intents
should hand routes to the app through the MHPlatform route pipeline rather than
holding in-memory router state.

## Localization

English is the source language and Japanese is the additional supported
language. Add user-facing app strings to String Catalogs from the start, and
localize App Intent titles, descriptions, parameters, dialogs, and shortcut
phrases.

Preserve Fluel product language such as Entry, Start, Precision, Time
together, Archive, Timeline, Milestone, and Preset unless the product owner
chooses an explicit Japanese term.

## Verification

Baseline changes should be verified with the repository contract in
`AGENTS.md`: shared-library tests when Operations or package resources change,
app build and runtime launch when app adapters or localization change, runtime
log review, screenshots for visible UI behavior, lint, repository rules, and
`git diff --check`.
