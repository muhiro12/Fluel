#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/task_runtime.sh"

ci_task_require_no_arguments "$#"
ci_task_enter_repository_root "${BASH_SOURCE[0]}"

source "$repository_root/ci_scripts/lib/xcodebuild_runner.sh"

ci_task_require_git_repository

shared_directory="${CI_SHARED_DIR:-$repository_root/.build/ci/shared}"
work_directory="${CI_RUN_WORK_DIR:-${AI_RUN_WORK_DIR:-$shared_directory/work}}"
results_directory="${CI_RUN_RESULTS_DIR:-${AI_RUN_RESULTS_DIR:-$work_directory/results}}"
derived_data_directory="${CI_DERIVED_DATA_DIR:-$shared_directory/DerivedData}"
captures_directory="$results_directory/captures"
app_path="$derived_data_directory/Build/Products/Debug-iphonesimulator/Fluel.app"

mkdir -p "$captures_directory"

if [[ ! -d "$app_path" ]]; then
  echo "Built app not found at $app_path" >&2
  echo "Run build_app.sh before capture verification." >&2
  exit 1
fi

simulator_identifier=$(ci_resolve_simulator_identifier)
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
