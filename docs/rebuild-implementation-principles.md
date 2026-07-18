# Rebuild Implementation Principles

## Purpose

This document records implementation-direction constraints that were clarified
after the product-preservation pass.

The product documents still define what Fluel is. This document records the
platform, app-shape, reference-project, package, and OS-baseline direction used
by the current rebuild.

The initial rebuilt project now exists. This document does not authorize
recreating it, replacing its target structure, defining a release plan, or
restoring any legacy implementation detail.

## Product Center

Preserve the product center from `docs/rebuild-handoff.md`:

Fluel quietly keeps time with the things and places the user lives with.

All implementation choices should serve that focused domain.

## AI-Era App Thesis

Fluel should be built as a focused Apple-platform app for an AI-assisted
platform future.

The app should not try to become a broad platform, productivity suite, or
super app. Its value should come from owning one deep domain clearly:
structured information about entries, starts, precision, time together,
archive state, notes, photos, activity, milestones, presets, and sharing
contexts.

In this model:

- Fluel owns high-quality domain data and behavior.
- Native SwiftUI screens remain polished, calm, and directly useful.
- Siri, Apple Intelligence, Shortcuts, App Intents, widgets, and other system
  surfaces should be able to reach Fluel's focused domain through reliable
  structured interfaces.
- AI and system surfaces may orchestrate user intent, but Fluel should remain
  the trustworthy domain owner for time-with-things-and-places data.

Do not turn this into a generic AI chat app. AI-era support means Fluel's
domain is clean, structured, native, and available to system surfaces.

## Platform Direction

Use Apple-native capabilities as primary constraints:

- Build with the current Xcode and iOS SDK available when implementation
  starts.
- Use Swift, SwiftUI, HIG, App Intents, and official Apple framework guidance
  as primary implementation evidence.
- Prefer platform-native persistence and data modeling when it fits Fluel's
  domain. SwiftData is the default direction unless a concrete product or
  platform reason justifies a different choice.
- Keep the app ready for system-level access through App Intents and related
  structured surfaces from the beginning of the rebuild.
- Treat CloudKit-backed SwiftData, Operations-backed App Intents, and English
  plus Japanese localization as rebuild baseline capabilities.

## Minimum OS Baseline

The current minimum support baseline is the iOS 27 family.

Do not design the current implementation around compatibility with older iOS
families unless this baseline is explicitly revised. Keep the selected SDK and
deployment target aligned with this baseline.

## Reference Projects

The highest-priority app references for Fluel are:

- Origami.
- Incomes.

Treat them as intent-bearing references, not source to copy blindly.

Use Origami and Incomes especially for applied app shape, platform-native UI,
package posture, design-system adoption, and implementation quality bars.
Preserve Fluel's own product domain, language, and emotional tone when a
reference app's domain-specific behavior conflicts with Fluel's docs.

If a reference repository is not available in the local workspace, record that
coverage gap rather than silently substituting a weaker reference.

## Package Posture

Use the same package posture as Incomes unless a Fluel-specific product or
platform constraint requires a documented exception.

The initial implementation inspected the current Incomes project and aligned
with its then-current package set and version policy. The observed Incomes
package posture included:

- `MHPlatform` from `https://github.com/muhiro12/MHPlatform.git`, using the
  `1.0.0..<2.0.0` family for shared-library adoption and an Xcode project
  package reference with an up-to-next-major `1.0.0` minimum.
- `MHPlatformCore` for shared-library logic that should stay core-safe.
- `MHPlatform` for app-side umbrella adoption when the app needs platform
  runtime, route, review, or other app-level support.
- `MHUI` from `https://github.com/muhiro12/MHUI`, using the Incomes-aligned
  `1.x` posture.
- `MHUI` re-exports `MHDesign`, so styled adopters need only the `MHUI`
  product link.
- `SimplyDanny/SwiftLintPlugins` as the project-declared SwiftLint source,
  rather than relying on a separately installed `swiftlint` binary.

This list is a snapshot, not a substitute for checking Incomes at project
creation time.

## MHUI Direction

Use MHUI with the full current SDK capabilities available to the app.

Do not constrain Fluel's MHUI usage to legacy fallback styling or older-OS
compatibility paths when the iOS 27 baseline allows current SDK-native
treatments. Prefer SDK-native MHUI surfaces, materials, treatments, and
design-system behavior when they fit Fluel's quiet product tone.

Color choices that define Fluel's identity should remain deliberate
product-design decisions. Structural design-system use, semantic roles,
spacing, sizing, materials, and state treatments should follow MHUI, HIG, and
current SDK guidance.

## Architecture Posture

Start from the smallest structure that can express the product well, then add
boundaries when they protect real behavior.

As the implementation grows beyond one app surface, prefer the Incomes-style
direction:

- Durable business logic lives in a shared library.
- App, widget, App Intent, watch, and other delivery surfaces stay
  responsibility-thin adapters.
- Cross-surface business use cases enter through public `*Operations`-style
  facades.
- Platform framework glue stays in the app or target adapter unless it becomes
  a proven reusable platform-foundation concern.

Do not add layers only for symmetry with another repository.

## Current Foundation Note

The rebuilt app foundation now uses the Incomes/Stally-aligned package posture:
the app target links `MHPlatform` and `MHUI`, which re-exports `MHDesign`,
while `FluelLibrary` depends only on `MHPlatformCore` from the MHPlatform
package for core-safe link contracts.

The current development foundation adds `FluelLibrary` as the shared package
for durable entry behavior. The app target still owns SwiftData `@Model`
storage, SwiftUI presentation, navigation, and model-container setup. The
library owns start precision, draft validation, normalized start dates,
elapsed-time summaries, stable entry snapshots, `EntryOperations`, and
core-safe route URL contracts.

The rebuild baseline now includes:

- SwiftData runtime storage configured for CloudKit, with separate in-memory
  containers for previews, tests, and runtime screenshot scenarios.
- App Intents and App Shortcuts in the app target that call
  `FluelLibrary` Operations through thin app-side adapters and hand app
  destinations to the MHPlatform route pipeline.
- English and Japanese localization through app String Catalogs and package
  localization resources.

Keep this split narrow. Do not add widgets, watch targets, backup services,
review prompts, or insights infrastructure only to mirror Incomes. Add new
surfaces when a feature goal needs them, and have those surfaces call
`FluelLibrary` operations rather than recreating domain rules.

## Verification Posture

Use the repository `AGENTS.md` verification contract and keep Apple
verification Xcode-native-first.

Treat shared-library tests, app or surface builds, retained repository-rule
checks, and runtime/UI evidence as separate capabilities. Choose the smallest
set that proves the change, and add stronger evidence for public APIs,
persisted schema, app lifecycle, system-surface behavior, or visible UI.
