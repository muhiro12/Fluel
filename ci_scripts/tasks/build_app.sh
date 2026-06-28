#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

if ! ci_task_should_skip_environment_check; then
  bash "$repository_root/ci_scripts/tasks/check_environment.sh" --profile build
fi

derived_data_directory=${CI_DERIVED_DATA_DIR:-"$repository_root/.build/ci/shared/DerivedData"}
destination=${FLUEL_SIM_DESTINATION:-"platform=iOS Simulator,name=iPhone 17 Pro"}

mkdir -p "$derived_data_directory"

xcodebuild \
  -project "$repository_root/Fluel.xcodeproj" \
  -scheme Fluel \
  -configuration Debug \
  -destination "$destination" \
  -derivedDataPath "$derived_data_directory" \
  build
