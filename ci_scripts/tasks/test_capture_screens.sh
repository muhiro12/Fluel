#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"
source "$script_directory/../lib/xcodebuild.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

if ! ci_task_should_skip_environment_check; then
  bash "$repository_root/ci_scripts/tasks/check_environment.sh" --profile build
fi

shared_directory=$(ci_xcodebuild_shared_directory "$repository_root")
work_directory=$(ci_xcodebuild_work_directory "$repository_root")
results_directory=$(ci_xcodebuild_results_directory "$repository_root")
derived_data_directory=$(ci_xcodebuild_derived_data_directory "$repository_root")
captures_directory="$results_directory/captures"
app_path="$derived_data_directory/Build/Products/Debug-iphonesimulator/Fluel.app"

mkdir -p "$captures_directory"

if [[ ! -d "$app_path" ]]; then
  echo "Built app not found at $app_path" >&2
  echo "Run build_app.sh before capture verification." >&2
  exit 1
fi

simulator_identifier=$(ci_xcodebuild_resolve_simulator_identifier)
if [[ -z "$simulator_identifier" ]]; then
  echo "Unable to resolve an iOS simulator for capture verification." >&2
  exit 1
fi

xcrun simctl boot "$simulator_identifier" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$simulator_identifier" -b >/dev/null

bundle_identifier=$(
  /usr/libexec/PlistBuddy \
    -c 'Print:CFBundleIdentifier' \
    "$app_path/Info.plist"
)

xcrun simctl terminate "$simulator_identifier" "$bundle_identifier" >/dev/null 2>&1 || true
xcrun simctl uninstall "$simulator_identifier" "$bundle_identifier" >/dev/null 2>&1 || true
xcrun simctl install "$simulator_identifier" "$app_path" >/dev/null

screens=(
  main
  home
  timeline
  dashboard
  archive
  detail
  formCreate
  formEdit
  settings
  presetSettings
  presetEditor
  licenses
)

for screen in "${screens[@]}"; do
  output_path="$captures_directory/${screen}.png"

  rm -f "$output_path"
  xcrun simctl terminate "$simulator_identifier" "$bundle_identifier" >/dev/null 2>&1 || true
  xcrun simctl launch \
    "$simulator_identifier" \
    "$bundle_identifier" \
    --codex-capture-screen \
    "$screen" \
    >/dev/null
  sleep 2
  xcrun simctl io "$simulator_identifier" screenshot "$output_path" >/dev/null

  if [[ ! -s "$output_path" ]]; then
    echo "Capture output missing for screen '$screen'." >&2
    exit 1
  fi
done

xcrun simctl terminate "$simulator_identifier" "$bundle_identifier" >/dev/null 2>&1 || true

echo "Finished Fluel capture verification. Screenshots: $captures_directory"
