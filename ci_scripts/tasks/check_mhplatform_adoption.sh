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

# Fluel intentionally keeps MHPlatform on a rolling remote 1.x semver contract
# even though upstream release guidance recommends exact tags for released apps.
mhplatform_reference_block=$(grep -A6 'repositoryURL = "https://github.com/muhiro12/MHPlatform.git";' "$pbxproj_path" || true)

if [[ -z "$mhplatform_reference_block" ]]; then
  fail_check "MHPlatform remote package requirement block is missing from project.pbxproj."
fi

if ! grep -q 'kind = upToNextMajorVersion;' <<<"$mhplatform_reference_block" || \
  ! grep -q 'minimumVersion = 1.0.0;' <<<"$mhplatform_reference_block"; then
  fail_check "Fluel keeps MHPlatform on an up-to-next-major 1.x requirement with minimumVersion = 1.0.0."
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
  fail_check "MHPlatform must resolve within Fluel's approved 1.x semver range."
fi

if ! grep -Eq '"revision" : "[0-9a-f]{40}"' <<<"$mhplatform_pin_block"; then
  fail_check "MHPlatform must be pinned to a concrete revision in Package.resolved."
fi

forbidden_import_matches=$(
  rg --line-number '^(@testable )?import MHPlatform$' \
    Fluel \
    FluelWidget \
    FluelLibrary \
    --glob '*.swift' || true
)

if [[ -n "$forbidden_import_matches" ]]; then
  echo "MHPlatform umbrella import check failed." >&2
  echo "Keep this repository on narrow MHPlatform modules instead of the full umbrella product." >&2
  echo "$forbidden_import_matches" >&2
  exit 1
fi

if rg -q 'productName = MHPlatform;' "$pbxproj_path"; then
  fail_check "This repository must not adopt the full MHPlatform umbrella product."
fi

echo "MHPlatform adoption check passed."
