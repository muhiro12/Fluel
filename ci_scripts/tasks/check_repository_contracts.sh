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
    --regexp 'ci_scripts/tasks/(verify|run_required_builds|pre_commit|verify_pre_commit|test_app_integration)\.sh|docs/product-overview\.md|\.build/ci_runs|FluelTests' \
    "$repository_root" || true
)

legacy_files=()
if [[ -f "$repository_root/.pre-commit-config.yaml" ]]; then
  legacy_files+=("$repository_root/.pre-commit-config.yaml")
fi

if [[ -n "$legacy_matches" || ${#legacy_files[@]} -ne 0 ]]; then
  echo "Repository contract check failed." >&2
  echo "Remove legacy script names, legacy hook files, legacy docs aliases, legacy test targets, and legacy artifact paths." >&2
  if [[ -n "$legacy_matches" ]]; then
    printf '%s\n' "$legacy_matches" >&2
  fi
  if [[ ${#legacy_files[@]} -ne 0 ]]; then
    printf '%s\n' "${legacy_files[@]}" >&2
  fi
  exit 1
fi

echo "Repository contract check passed."
