# ADR 0001: Shared Library Source of Truth

- Date: 2026-03-10
- Status: Accepted

## Context

Fluel already serves the same entry data across at least two surfaces: the iOS
app and the widget extension. If each surface grows its own mutation, query, or
formatting rules, behavior will drift and future changes will become harder to
review.

## Decision

`FluelLibrary` is the single source of truth for reusable entry logic. Shared
models, mutation rules, query helpers, formatting, and widget snapshot
projection belong there.

## Consequences

- Shared operations should be added to `FluelLibrary` before they are reused in
  the app target or widget target.
- `EntryRepository`, query helpers, formatting helpers, and widget snapshot
  types are canonical shared entry points.
- New app-side or widget-side features should call shared APIs rather than
  recreating domain rules locally.
