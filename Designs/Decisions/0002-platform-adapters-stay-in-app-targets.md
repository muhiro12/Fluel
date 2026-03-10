# ADR 0002: Platform Adapters Stay in App Targets

- Date: 2026-03-10
- Status: Accepted

## Context

Some Fluel capabilities depend directly on Apple frameworks or product runtime
integration, such as TipKit, PhotosUI, WidgetKit timeline reloads, and app
runtime bootstrap configuration. Those dependencies do not belong in the shared
domain layer.

## Decision

Keep platform-specific integrations in `Fluel` and `FluelWidget`. Do not push
platform behavior into `FluelLibrary` through target-local extensions or shared
services that depend on app frameworks.

## Consequences

- `FluelEntryMutationWorkflow`, `FluelWidgetReloader`,
  `FluelSharedPreferences`, and widget providers remain adapter-side types.
- `FluelLibrary` stays focused on platform-neutral entry logic and shared data
  shapes.
- When a new feature needs Apple-only APIs, the default design is an adapter in
  `Fluel` or `FluelWidget` over shared library services.
