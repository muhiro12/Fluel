#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

pbxproj_path="$repository_root/Fluel.xcodeproj/project.pbxproj"
resolved_path="$repository_root/Fluel.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
package_manifest="$repository_root/FluelLibrary/Package.swift"
package_resolved="$repository_root/FluelLibrary/Package.resolved"
mhplatform_remote="https://github.com/muhiro12/MHPlatform.git"
core_safe_modules=(
  MHDeepLinking
  MHLogging
  MHNotificationPayloads
  MHNotificationPlans
  MHRouteExecution
  MHPersistenceMaintenance
  MHPreferences
)

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

if [[ ! -f "$package_manifest" ]]; then
  fail_check "Missing FluelLibrary package manifest at $package_manifest."
fi

if [[ ! -f "$package_resolved" ]]; then
  fail_check "Missing FluelLibrary Package.resolved at $package_resolved."
fi

extract_manifest_dependency_block() {
  local remote_url=$1

  awk -v remote_url="$remote_url" '
    index($0, "url: \"" remote_url "\"") { capture = 1 }
    capture { print }
    capture && $0 ~ /^[[:space:]]*\),?$/ { exit }
  ' "$package_manifest"
}

extract_resolved_pin_block() {
  local resolved_file=$1
  local remote_url=$2

  awk -v remote_url="$remote_url" '
    index($0, "\"location\" : \"" remote_url "\"") { capture = 1 }
    capture { print }
    capture && $0 ~ /^    },?$/ { exit }
  ' "$resolved_file"
}

if rg -q 'XCLocalSwiftPackageReference "MHPlatform"|relativePath = \.\./MHPlatform;' "$pbxproj_path" ||
  rg -q '\.package\(\s*path:\s*"[^"]*MHPlatform' "$package_manifest"; then
  fail_check "MHPlatform must not be referenced as a local path dependency."
fi

if ! rg -q "repositoryURL = \"$mhplatform_remote\";" "$pbxproj_path"; then
  fail_check "Fluel.xcodeproj must reference the canonical MHPlatform remote."
fi

mhplatform_manifest_block=$(extract_manifest_dependency_block "$mhplatform_remote")
if [[ -z "$mhplatform_manifest_block" ]]; then
  fail_check "FluelLibrary/Package.swift must reference the canonical MHPlatform remote."
fi

if ! grep -q --fixed-strings '"1.0.0"..<"2.0.0"' <<<"$mhplatform_manifest_block"; then
  fail_check "FluelLibrary/Package.swift must declare the MHPlatform 1.x semver range 1.0.0..<2.0.0."
fi

if grep -q --fixed-strings 'branch:' <<<"$mhplatform_manifest_block" ||
  grep -q --fixed-strings 'revision:' <<<"$mhplatform_manifest_block"; then
  fail_check "FluelLibrary/Package.swift must not track MHPlatform by branch or exact revision."
fi

if rg -q 'name:\s*"MHPlatform"' "$package_manifest"; then
  fail_check "FluelLibrary must not depend on the umbrella MHPlatform product."
fi

if ! rg -q 'name:\s*"MHPlatformCore"' "$package_manifest"; then
  fail_check "FluelLibrary must depend on the MHPlatformCore product."
fi

for module_name in "${core_safe_modules[@]}"; do
  if rg -q "name:\\s*\"$module_name\"" "$package_manifest"; then
    fail_check "FluelLibrary must not declare direct MHPlatform core-safe module dependency $module_name."
  fi
done

mhplatform_pin_block=$(extract_resolved_pin_block "$resolved_path" "$mhplatform_remote")

if [[ -z "$mhplatform_pin_block" ]]; then
  fail_check "MHPlatform pin is missing from Package.resolved."
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

mhplatform_library_pin_block=$(extract_resolved_pin_block "$package_resolved" "$mhplatform_remote")

if [[ -z "$mhplatform_library_pin_block" ]]; then
  fail_check "FluelLibrary/Package.resolved must resolve MHPlatform from the canonical remote."
fi

if ! grep -Eq '"version" : "1\.[0-9]+\.[0-9]+"' <<<"$mhplatform_library_pin_block"; then
  fail_check "FluelLibrary/Package.resolved must resolve MHPlatform within the approved 1.x semver range."
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

echo "MHPlatform boundary check passed."
