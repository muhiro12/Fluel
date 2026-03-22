#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/task_runtime.sh"

ci_task_require_no_arguments "$#"
ci_task_enter_repository_root "${BASH_SOURCE[0]}"

pbxproj_path="$repository_root/Fluel.xcodeproj/project.pbxproj"
resolved_path="$repository_root/Fluel.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
mhui_remote="https://github.com/muhiro12/MHUI.git"

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

if ! rg -q 'repositoryURL = "https://github.com/muhiro12/MHUI.git";' "$pbxproj_path"; then
  fail_check "MHUI remote reference is missing from project.pbxproj."
fi

if rg -q 'XCLocalSwiftPackageReference "MHUI"|XCLocalSwiftPackageReference "\.\./MHUI"|relativePath = \.\./MHUI;' "$pbxproj_path"; then
  fail_check "MHUI must not be referenced as a local path dependency."
fi

mhui_reference_block=$(grep -A6 'repositoryURL = "https://github.com/muhiro12/MHUI.git";' "$pbxproj_path" || true)

if [[ -z "$mhui_reference_block" ]]; then
  fail_check "MHUI remote package requirement block is missing from project.pbxproj."
fi

if ! grep -q 'kind = upToNextMajorVersion;' <<<"$mhui_reference_block" || \
  ! grep -q 'minimumVersion = 1.0.0;' <<<"$mhui_reference_block"; then
  fail_check "MHUI must use an up-to-next-major requirement with minimumVersion = 1.0.0."
fi

if grep -q 'kind = branch;' <<<"$mhui_reference_block" || grep -q 'branch = ' <<<"$mhui_reference_block"; then
  fail_check "MHUI must not track a floating branch in project.pbxproj."
fi

mhui_pin_block=$(grep -A8 '"identity" : "mhui"' "$resolved_path" || true)

if [[ -z "$mhui_pin_block" ]]; then
  fail_check "MHUI pin is missing from Package.resolved."
fi

if ! grep -q "\"location\" : \"$mhui_remote\"" <<<"$mhui_pin_block"; then
  fail_check "Package.resolved points MHUI at an unexpected remote."
fi

if grep -q '"branch"' <<<"$mhui_pin_block"; then
  fail_check "MHUI must not track a floating branch in Package.resolved."
fi

if ! grep -Eq '"version" : "1\.[0-9]+\.[0-9]+"' <<<"$mhui_pin_block"; then
  fail_check "MHUI must resolve within the approved 1.x semver range."
fi

if ! grep -Eq '"revision" : "[0-9a-f]{40}"' <<<"$mhui_pin_block"; then
  fail_check "MHUI must be pinned to a concrete revision in Package.resolved."
fi

echo "MHUI adoption check passed."
