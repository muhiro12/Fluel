#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"

matches=$(
  rg --line-number \
    --glob 'Fluel/**/Models/*.swift' \
    --glob 'FluelWidget/**/Models/*.swift' \
    '@ViewBuilder|: View\b|: LabelStyle\b' \
    Fluel FluelWidget || true
)

if [[ -n "$matches" ]]; then
  echo "Models directory consistency check failed." >&2
  echo "Move View-related code out of */Models/." >&2
  echo "$matches" >&2
  exit 1
fi

echo "Models directory consistency check passed."
