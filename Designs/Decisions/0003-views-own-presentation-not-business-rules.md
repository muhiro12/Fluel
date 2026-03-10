# ADR 0003: Views Own Presentation, Not Business Rules

- Date: 2026-03-10
- Status: Accepted

## Context

SwiftUI views in Fluel are natural places to add local decisions around entry
creation, editing, archiving, and deletion. Over time, those decisions become
hard to reuse and easy to diverge from widget or future surface behavior.

## Decision

Views own presentation state, local interaction flow, and navigation.
Reusable validation, mutation rules, and query decisions belong in shared
services and value types such as `EntryRepository`, `EntryFormInput`, and other
`FluelLibrary` domain helpers.

## Consequences

- If a view reconstructs reusable validation or mutation logic, that is a
  refactoring target.
- Thin app-side workflows are acceptable when they adapt shared services to a
  screen.
- Presentation code becomes easier to review because UI concerns and reusable
  rules have clearer boundaries.
