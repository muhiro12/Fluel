#!/usr/bin/env bash

ci_resolve_simulator_identifier() {
  local booted_simulator_identifier
  booted_simulator_identifier=$(xcrun simctl list devices | awk -F'[()]' '/Booted/ {print $2; exit}' || true)
  if [[ -n "$booted_simulator_identifier" ]]; then
    echo "$booted_simulator_identifier"
    return 0
  fi

  local candidate_simulator_identifier
  candidate_simulator_identifier=$(xcrun simctl list devices | awk -F'[()]' '/iPhone/ && /(Shutdown|Booted)/ {print $2; exit}' || true)
  if [[ -n "$candidate_simulator_identifier" ]]; then
    xcrun simctl boot "$candidate_simulator_identifier" >/dev/null 2>&1 || true
    echo "$candidate_simulator_identifier"
    return 0
  fi

  echo ""
}

ci_run_xcodebuild_task() {
  local repository_root=$1
  local scheme=$2
  local action=$3
  local result_bundle_prefix=$4
  local completion_message=$5

  local project_path="Fluel.xcodeproj"
  local shared_directory="${CI_SHARED_DIR:-$repository_root/.build/ci/shared}"
  local work_directory="${CI_RUN_WORK_DIR:-${AI_RUN_WORK_DIR:-$shared_directory/work}}"
  local cache_directory="${CI_CACHE_DIR:-${AI_RUN_CACHE_ROOT:-$shared_directory/cache}}"
  local derived_data_path="${CI_DERIVED_DATA_DIR:-$shared_directory/DerivedData}"
  local results_directory="${CI_RUN_RESULTS_DIR:-${AI_RUN_RESULTS_DIR:-$work_directory/results}}"

  local local_home_directory="$shared_directory/home"
  local temporary_directory="$shared_directory/tmp"
  local clang_module_cache_directory="$cache_directory/clang/ModuleCache"
  local package_cache_directory="$cache_directory/package"
  local cloned_source_packages_directory="$cache_directory/source_packages"
  local swiftpm_cache_directory="$cache_directory/swiftpm/cache"
  local swiftpm_config_directory="$cache_directory/swiftpm/config"

  mkdir -p \
    "$work_directory" \
    "$local_home_directory/Library/Caches" \
    "$local_home_directory/Library/Developer" \
    "$local_home_directory/Library/Logs" \
    "$cache_directory" \
    "$clang_module_cache_directory" \
    "$package_cache_directory" \
    "$cloned_source_packages_directory" \
    "$swiftpm_cache_directory" \
    "$swiftpm_config_directory" \
    "$temporary_directory" \
    "$derived_data_path" \
    "$results_directory"

  local resolved_simulator_identifier
  resolved_simulator_identifier=$(ci_resolve_simulator_identifier)

  local -a destination
  if [[ -n "$resolved_simulator_identifier" ]]; then
    destination=(-destination "id=$resolved_simulator_identifier")
  else
    destination=(-destination "platform=iOS Simulator,OS=latest")
  fi

  local timestamp
  timestamp=$(date +%s)

  local result_bundle_path="$results_directory/${result_bundle_prefix}_${timestamp}.xcresult"

  HOME="$local_home_directory" \
  TMPDIR="$temporary_directory" \
  XDG_CACHE_HOME="$cache_directory" \
  CLANG_MODULE_CACHE_PATH="$clang_module_cache_directory" \
  SWIFTPM_CACHE_PATH="$swiftpm_cache_directory" \
  SWIFTPM_CONFIG_PATH="$swiftpm_config_directory" \
  PLL_SOURCE_PACKAGES_PATH="$cloned_source_packages_directory" \
  xcodebuild \
    -project "$project_path" \
    -scheme "$scheme" \
    "${destination[@]}" \
    -derivedDataPath "$derived_data_path" \
    -resultBundlePath "$result_bundle_path" \
    -clonedSourcePackagesDirPath "$cloned_source_packages_directory" \
    -packageCachePath "$package_cache_directory" \
    "CLANG_MODULE_CACHE_PATH=$clang_module_cache_directory" \
    "$action"

  echo "$completion_message Result bundle: $result_bundle_path"
}
