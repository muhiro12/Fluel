#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/task_runtime.sh"

ci_task_require_no_arguments "$#"
ci_task_enter_repository_root "${BASH_SOURCE[0]}"

pbxproj_path="$repository_root/Fluel.xcodeproj/project.pbxproj"
resolved_path="$repository_root/Fluel.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
mhplatform_remote="https://github.com/muhiro12/MHPlatform.git"

fail_check() {
  echo "$1" >&2
  exit 1
}

if [[ ! -f "$pbxproj_path" ]]; then
  fail_check "Missing Xcode project file at $pbxproj_path."
fi

if [[ ! -f "$resolved_path" ]]; then
  fail_check "Missing Package.resolved at $resolved_path."
fi

if ! rg -q 'repositoryURL = "https://github.com/muhiro12/MHPlatform.git";' "$pbxproj_path"; then
  fail_check "MHPlatform remote reference is missing from project.pbxproj."
fi

if rg -q 'XCLocalSwiftPackageReference "MHPlatform"|relativePath = \.\./MHPlatform;' "$pbxproj_path"; then
  fail_check "MHPlatform must not be referenced as a local path dependency."
fi

mhplatform_reference_block=$(grep -A6 'repositoryURL = "https://github.com/muhiro12/MHPlatform.git";' "$pbxproj_path" || true)

if [[ -z "$mhplatform_reference_block" ]]; then
  fail_check "MHPlatform remote package requirement block is missing from project.pbxproj."
fi

if ! grep -q 'kind = upToNextMajorVersion;' <<<"$mhplatform_reference_block" || \
  ! grep -q 'minimumVersion = 1.0.0;' <<<"$mhplatform_reference_block"; then
  fail_check "MHPlatform must use an up-to-next-major 1.x requirement with minimumVersion = 1.0.0."
fi

if grep -q 'kind = branch;' <<<"$mhplatform_reference_block" || grep -q 'branch = ' <<<"$mhplatform_reference_block"; then
  fail_check "MHPlatform must not track a floating branch in project.pbxproj."
fi

mhplatform_pin_block=$(grep -A8 '"identity" : "mhplatform"' "$resolved_path" || true)

if [[ -z "$mhplatform_pin_block" ]]; then
  fail_check "MHPlatform pin is missing from Package.resolved."
fi

if ! grep -q "\"location\" : \"$mhplatform_remote\"" <<<"$mhplatform_pin_block"; then
  fail_check "Package.resolved points MHPlatform at an unexpected remote."
fi

if grep -q '"branch"' <<<"$mhplatform_pin_block"; then
  fail_check "MHPlatform must not track a floating branch in Package.resolved."
fi

if ! grep -Eq '"version" : "1\.[0-9]+\.[0-9]+"' <<<"$mhplatform_pin_block"; then
  fail_check "MHPlatform must resolve within the approved 1.x semver range."
fi

if ! grep -Eq '"revision" : "[0-9a-f]{40}"' <<<"$mhplatform_pin_block"; then
  fail_check "MHPlatform must be pinned to a concrete revision in Package.resolved."
fi

if ! rg -q 'productName = MHPlatform;' "$pbxproj_path"; then
  fail_check "Fluel app target must adopt MHPlatform as its base product."
fi

if rg -q 'productName = MHAppRuntime;' "$pbxproj_path"; then
  fail_check "Fluel app target must not keep MHAppRuntime as a separate base product dependency."
fi

forbidden_non_app_umbrella_imports=$(
  rg --line-number '^(@testable )?import MHPlatform$' \
    FluelWidget \
    FluelLibrary \
    FluelTests \
    --glob '*.swift' || true
)

if [[ -n "$forbidden_non_app_umbrella_imports" ]]; then
  echo "MHPlatform umbrella import boundary check failed." >&2
  echo "Keep MHPlatform umbrella imports in the app target and out of shared-library, widget, and test support code." >&2
  echo "$forbidden_non_app_umbrella_imports" >&2
  exit 1
fi

forbidden_app_narrow_imports=$(
  rg --line-number '^import (MHAppRuntime|MHLogging|MHMutationFlow)$' \
    Fluel \
    --glob '*.swift' || true
)

if [[ -n "$forbidden_app_narrow_imports" ]]; then
  echo "Fluel app-side MHPlatform import check failed." >&2
  echo "Use MHPlatform as the app target base import instead of direct MHAppRuntime, MHLogging, or MHMutationFlow imports." >&2
  echo "$forbidden_app_narrow_imports" >&2
  exit 1
fi

echo "MHPlatform adoption check passed."
