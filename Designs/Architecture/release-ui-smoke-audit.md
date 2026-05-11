# Release UI Smoke Audit

## Purpose

Release UI smoke auditing is a release-time visual confidence pass for the real
Fluel app running in Simulator. It complements the repository's build,
shared-library test, boundary-check, and capture-screen posture without
replacing it.

Use this audit to catch issues that library tests, app builds, and static
capture flows cannot fully prove:

- launch failures
- blank or frozen primary screens
- unreachable core tab navigation
- obvious clipping, overlap, or unreadable text
- broken sheets, confirmation dialogs, and full-screen presentations
- iPad layout gaps that need human follow-up
- widget coverage gaps when the available tool surface cannot inspect WidgetKit
- visual issues a human release reviewer can spot from captured screenshots

## Relationship to Verification

The standard completion gate remains:

```sh
bash ci_scripts/tasks/verify_task_completion.sh
```

That gate verifies repository health through environment checks, SwiftLint,
boundary checks, the required app build, shared-library tests, and capture
screen verification when the changed paths require them. Release UI smoke
auditing is separate from that gate and should not be added to the normal task
completion flow by default.

## Workflow

Use the global `$xcode-ui-smoke-auditor` skill when performing this audit. The
skill owns the XcodeBuildMCP details for building, launching, inspecting the
live UI hierarchy, capturing screenshots, and reporting findings.

The repository expectation is:

1. Run the normal verification gate for code readiness.
2. Run release UI smoke only when preparing a release or when a UI-sensitive
   change needs live Simulator evidence.
3. Prefer representative iPhone and iPad Simulator coverage when available.
4. Cover Home, Timeline, Dashboard, Settings, Archive, Detail, create/edit
   forms, preset settings, licenses, and diagnostics when the state is safely
   reachable.
5. Treat WidgetKit inspection as separate target coverage. Audit it when the
   available tool surface supports widget gallery or extension inspection;
   otherwise, report it as a coverage gap with the concrete blocker.
6. Keep screenshots and findings in the audit report, not as committed test
   artifacts.
7. Group screenshots by device, orientation, and screen so the report can be
   used both as agent evidence and as a human release review gallery.
8. Treat skipped screens and state-dependent coverage as explicit coverage
   gaps.

## Safety Rules

Release UI smoke auditing is non-destructive by default.

- Do not erase simulators, delete app data, reset keychains, or wipe containers
  unless explicitly requested.
- Do not perform purchases, account actions, sends, deletes, or other
  externally visible actions.
- Do not add UI test targets, snapshot tests, accessibility identifiers, or
  debug routes solely as part of the audit.
- Use repository-provided debug or sample data flows only when they are clearly
  safe.
- If deterministic state is needed, prefer debug-only launch arguments that do
  not remove existing data.

## Reporting

Reports should be evidence-backed and concise. Use the structure from
`$xcode-ui-smoke-auditor`:

1. `blocking issues`
2. `warnings`
3. `notes`
4. `coverage gaps`
5. `screenshots`
6. `session defaults`

When no issue is found, state that no blocking issue was observed in the
audited coverage and still list remaining gaps.

Screenshot evidence should be reviewable. Prefer inline images when the
environment supports local image rendering, and call out screenshots that are
sideways, cropped, blank, obscured, or otherwise insufficient for human review.
