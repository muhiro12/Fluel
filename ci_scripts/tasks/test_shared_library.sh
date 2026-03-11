#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/task_runtime.sh"

ci_task_require_no_arguments "$#"
ci_task_enter_repository_root "${BASH_SOURCE[0]}"

source "$repository_root/ci_scripts/lib/xcodebuild_runner.sh"

ci_task_require_git_repository

ci_run_xcodebuild_task \
  "$repository_root" \
  "FluelLibrary" \
  "test" \
  "TestResults_FluelLibrary" \
  "Finished FluelLibrary tests."
