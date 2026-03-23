#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

legacy_matches=$(
  rg \
    --line-number \
    --glob '!.git/**' \
    --glob '!.build/**' \
    --glob '!ci_scripts/tasks/check_repository_contracts.sh' \
    --glob '!Fluel.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved' \
    --regexp 'ci_scripts/tasks/(verify|run_required_builds|pre_commit)\.sh|docs/product-overview\.md|\.build/ci_runs' \
    "$repository_root" || true
)

if [[ -n "$legacy_matches" ]]; then
  echo "Repository contract check failed." >&2
  echo "Remove legacy script names, legacy docs aliases, and legacy artifact paths." >&2
  printf '%s\n' "$legacy_matches" >&2
  exit 1
fi

echo "Repository contract check passed."
