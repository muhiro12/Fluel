# ADR 0004: MHPlatform Consumer Surfaces Follow 1.1 While Pinning Stays Semver

- Date: 2026-03-23
- Status: Accepted

## Context

MHPlatform 1.1 clarifies its consumer matrix around base product selection,
`MHAppRuntimeBootstrap` as the preferred root entry, and route/review/mutation
shells as opt-in additions. The upstream package also recommends exact-tag
pinning for released consumers.

Fluel already matches the current consumer surfaces in code: the app root is
built around `MHAppRuntimeBootstrap`, the app uses `MHAppRuntime` because it
needs the package-owned license surface and the debug-only ad path, and
`MHMutationFlow` is adopted only where the app owns mutation follow-up side
effects. At the same time, this repository already relies on CI-backed rolling
`1.x` intake from the remote GitHub package instead of exact-tag coordination.

## Decision

Follow MHPlatform 1.1 consumer-surface guidance in Fluel, but keep repository
dependency governance on semver-tracked remote `1.x` adoption starting at
`1.0.0`.

Concretely:

- `Fluel` stays a default-runtime consumer on `MHAppRuntime`.
- `MHAppRuntimeBootstrap` stays the root entry point for app startup.
- `MHMutationFlow` remains an optional shell used only in app-owned mutation
  adapters.
- Route and review shells stay out until the product needs them.
- MHPlatform remains a remote GitHub dependency only, with no local-path
  adoption, no floating branch tracking, and no umbrella `import MHPlatform`
  usage.

## Consequences

- Repository docs should describe semver tracking as a Fluel-specific exception,
  not as the upstream default MHPlatform release policy.
- `ci_scripts/tasks/check_mhplatform_adoption.sh` must enforce the Fluel
  contract: remote-only adoption, no floating branch, no umbrella import, and a
  resolved pin inside the approved `1.x` semver range.
- `MHAppRuntimeCore` is not the right base product while Fluel still uses the
  package-owned license surface and debug-only ad path from `MHAppRuntime`.
- Future MHPlatform changes should be evaluated by choosing the base product
  first and adding optional shells only where Fluel owns that concern.
