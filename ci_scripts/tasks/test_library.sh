#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

if ! ci_task_should_skip_environment_check; then
  bash "$repository_root/ci_scripts/tasks/check_environment.sh" --profile test
fi

shared_directory=${CI_SHARED_DIR:-"$repository_root/.build/ci/shared"}
cache_directory=${CI_CACHE_DIR:-"$shared_directory/cache"}
temporary_directory="$shared_directory/tmp"
local_home_directory="$shared_directory/home"
swiftpm_cache_directory="$cache_directory/swiftpm/cache"
swiftpm_config_directory="$cache_directory/swiftpm/config"
swiftpm_security_directory="$cache_directory/swiftpm/security"
scratch_directory="$shared_directory/FluelLibraryBuild"

mkdir -p \
  "$temporary_directory" \
  "$local_home_directory/Library/Caches" \
  "$swiftpm_cache_directory" \
  "$swiftpm_config_directory" \
  "$swiftpm_security_directory" \
  "$scratch_directory"

HOME="$local_home_directory" \
  TMPDIR="$temporary_directory" \
  XDG_CACHE_HOME="$cache_directory" \
  SWIFTPM_CACHE_PATH="$swiftpm_cache_directory" \
  SWIFTPM_CONFIG_PATH="$swiftpm_config_directory" \
  swift test \
    --disable-sandbox \
    --disable-dependency-cache \
    --manifest-cache local \
    --cache-path "$swiftpm_cache_directory" \
    --config-path "$swiftpm_config_directory" \
    --security-path "$swiftpm_security_directory" \
    --scratch-path "$scratch_directory" \
    --package-path "$repository_root/FluelLibrary"
