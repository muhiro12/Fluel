#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/task_runtime.sh"

ci_task_require_no_arguments "$#"
ci_task_enter_repository_root "${BASH_SOURCE[0]}"

echo "Running verify pipeline (pre-commit + required builds/tests)..."
CI_RUN_ENABLE_PRE_COMMIT=auto bash "$repository_root/ci_scripts/tasks/run_required_builds.sh"
