# ADR 0007: Adapter Failure-Surfacing Contract

- Date: 2026-03-23
- Status: Accepted

## Context

Fluel already keeps reusable mutation rules in `FluelLibrary`, but app-side
mutation follow-up still needed a repository-level contract for how failures
should be surfaced. Without that contract, the app could dismiss success flows
after a blocking error or treat post-commit follow-up failures as if the domain
write had rolled back.

## Decision

Every adapter-owned mutation path must classify failures into one of these
phases:

| Phase | Contract |
| --- | --- |
| Preflight failure before mutation | Block success and keep the current caller active. |
| Primary domain mutation failure | Block success and surface the error to the current caller. |
| Post-commit follow-up failure | Treat as degraded success, preserve the committed write, log the phase explicitly, and surface a repairable non-blocking notice when practical. |

## Consequences

- `FluelEntryMutationWorkflow` returns typed mutation results instead of raw
  success and error callbacks.
- Entry form and detail presentation models decide UI effects from
  `FluelMutationResult`.
- Widget reload failures do not claim rollback of a completed domain write.
- App-side logging must include operation name, surface, phase, and error
  payload for mutation failures.
