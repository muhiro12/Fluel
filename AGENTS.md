# AGENTS.md

Repository-specific agent contract for Fluel.

## Repository State

This repository currently preserves product documentation for a future full
rebuild. The legacy Xcode project and Swift implementation are not part of the
active repository surface.

Do not recreate an Xcode project, implement features, or make future
architecture decisions unless explicitly requested.

## Repository Rules

- Use English for branch names, code comments, documentation, and identifiers
  unless UI localization or legal content requires otherwise.
- Keep changes small and repository-local.
- Markdown must follow
  <https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md>.
- Treat `docs/` as the source of truth for preserved product knowledge.

## Current Verification

There is no active Xcode build, Swift package test suite, or retained CI script
entrypoint after the legacy implementation removal.

For documentation-only changes, verify Markdown structure and review the diff.
Do not run stale XcodeBuildMCP schemes or old shell verification commands until
a new project and repository contract are created.
