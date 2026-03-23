# ADR 0005: Fluel Adopts MHPlatform Full App Path Under 1.2

- Date: 2026-03-23
- Status: Accepted

## Context

MHPlatform 1.2 reorganizes its consumer guidance around two default pillars:
`MHPlatform` for app composition targets and `MHPlatformCore` for shared
libraries. The one-step default runtime path,
`MHAppRuntimeBootstrap(configuration:...)`, now lives on the `MHPlatform`
umbrella surface, while `MHAppRuntime` remains the advanced runtime/bootstrap
path for apps that intentionally want narrower or explicit split-runtime
composition.

Fluel currently uses the package-owned license surface and the debug-only
native ad path through the one-step runtime configuration. That makes the app
target a better fit for the full `MHPlatform` app path than for the advanced
`MHAppRuntime` path. At the same time, `FluelLibrary` does not currently depend
on MHPlatform and should stay on the shared-library side of the consumer matrix
if platform access is ever needed later.

## Decision

Align Fluel with the MHPlatform 1.2 consumer rules as follows:

- `Fluel` adopts `MHPlatform` as its app-target base product.
- `MHAppRuntimeBootstrap` remains the root entry point for app startup.
- Mutation follow-up remains an app-owned optional concern and uses the
  umbrella-exported `MHMutationFlow` APIs only where the app owns that work.
- `FluelLibrary` keeps having no MHPlatform dependency today; if it ever needs
  platform access, it must stop at `MHPlatformCore` or granular core-safe
  modules instead of app-facing umbrellas.
- The repository keeps remote semver-tracked `1.x` adoption from `1.0.0`
  in the project requirement.

## Consequences

- App-target source imports should converge on `MHPlatform` instead of direct
  `MHAppRuntime`, `MHLogging`, or `MHMutationFlow` imports.
- `ci_scripts/tasks/check_mhplatform_adoption.sh` should require the app target
  to depend on `MHPlatform` and should no longer forbid `import MHPlatform` in
  the app target.
- `ci_scripts/tasks/check_shared_library_boundaries.sh` should continue to keep
  app-facing MHPlatform surfaces out of `FluelLibrary/Sources` while allowing
  the future `MHPlatformCore` / granular core-safe path.
- Repository docs should describe `MHPlatform` / `MHPlatformCore` as the 1.2
  default pillars and remove the old 1.1 exception framing.
