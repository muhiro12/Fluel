# AGENTS.md

Repository-specific agent contract for Fluel.

## Repository Rules

- Use English for branch names, code comments, documentation, and identifiers
  unless UI localization or legal content requires otherwise.
- Follow existing architecture and source style; keep changes small and
  repository-local.
- Markdown must follow
  <https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md>.
- Swift code must comply with the repository SwiftLint configuration.

## Build and Test Entry Point

Agents MUST prefer XcodeBuildMCP for Apple build, test, run, Simulator,
runtime log, screenshot, and UI snapshot verification.

Before the first XcodeBuildMCP build, test, or run call in a session, run
XcodeBuildMCP `session_show_defaults`. If defaults do not point at this
repository, set them for the current session before continuing.

For app compile checks, use XcodeBuildMCP `build_sim` with the `Fluel` scheme.
For shared-library tests, use XcodeBuildMCP `test_sim` with the `FluelLibrary`
scheme. For widget compile checks, use XcodeBuildMCP `build_sim` with the
`FluelWidget` scheme when widget code or configuration changes. For runtime or
UI-sensitive checks, use XcodeBuildMCP `build_run_sim`, `launch_app_sim`,
`snapshot_ui`, and `screenshot` as appropriate.

Agents may run `bash ci_scripts/tasks/check_environment.sh --profile verify`
first to diagnose missing local prerequisites.
When Swift files are edited, agents should run
`bash ci_scripts/tasks/format_swift.sh` before the final verification gate.
Use `bash ci_scripts/tasks/verify_task_completion.sh` when the task needs the
retained aggregate shell gate or when MCP coverage is unavailable.
`bash ci_scripts/tasks/verify_pre_push.sh` is the optional Git `pre-push`
wrapper for the same non-destructive verification gate.
`bash ci_scripts/tasks/verify_repository_state.sh` is the supplemental
repository-state verification entrypoint that still writes CI run artifacts.
SwiftLint is resolved from the `SimplyDanny/SwiftLintPlugins` package declared
in `Fluel.xcodeproj`, not from a separately installed `swiftlint` binary.

Compatibility scripts write disposable CI artifacts under
`.build/ci/runs/<RUN_ID>/` and shared data under `.build/ci/shared/`. Only the
newest 5 run directories are retained.

## Release UI Smoke Audit

Release UI smoke auditing is separate from the standard verification entrypoint.
Keep it non-destructive by default: do not erase simulator data, reset
containers, or add UI test targets solely for the audit unless explicitly
requested.
