#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

library_sources=(
  "$repository_root/FluelLibrary/Sources"
)

app_sources=(
  "$repository_root/Fluel"
)

failures=()

record_failure() {
  failures+=("$1")
}

library_runtime_imports=$(
  rg \
    --line-number \
    "^import (SwiftData|SwiftUI|MHUI|MHDesign|MHPlatform)\\b" \
    "${library_sources[@]}" \
    -g '*.swift' || true
)

if [[ -n "$library_runtime_imports" ]]; then
  record_failure "FluelLibrary must stay domain-safe and avoid app/runtime UI imports:
$library_runtime_imports"
fi

app_domain_declarations=$(
  rg \
    --line-number \
    "^[[:space:]]*(public[[:space:]]+|private[[:space:]]+|final[[:space:]]+|struct[[:space:]]+|enum[[:space:]]+|class[[:space:]]+)*(struct|enum|final[[:space:]]+class|class)[[:space:]]+(StartPrecision|TimeTogetherSummary|EntryDraft|EntryInput|EntrySnapshot|EntryOperations)\\b" \
    "${app_sources[@]}" \
    -g '*.swift' || true
)

if [[ -n "$app_domain_declarations" ]]; then
  record_failure "Reusable entry domain types belong in FluelLibrary, not the app target:
$app_domain_declarations"
fi

direct_app_fetches=$(
  rg \
    --line-number \
    "\\bmodelContext\\.fetch(First|Count)?\\(" \
    "${app_sources[@]}" \
    -g '*.swift' || true
)

if [[ -n "$direct_app_fetches" ]]; then
  record_failure "App UI adapters should not grow direct ModelContext fetch logic:
$direct_app_fetches"
fi

mhplatform_runtime_links=$(
  rg \
    --line-number \
    "MHPlatform in Frameworks" \
    "$repository_root/Fluel.xcodeproj/project.pbxproj" || true
)

if [[ -n "$mhplatform_runtime_links" ]]; then
  record_failure "MHPlatform should stay declared but unlinked until a concrete runtime feature needs it:
$mhplatform_runtime_links"
fi

if [[ ${#failures[@]} -ne 0 ]]; then
  echo "Library boundary check failed." >&2

  for failure in "${failures[@]}"; do
    printf -- '- %s\n' "$failure" >&2
  done

  exit 1
fi

echo "Library boundary check passed."
