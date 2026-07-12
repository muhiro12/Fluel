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

library_non_foundation_imports=$(
  rg \
    --line-number \
    "^[[:space:]]*(@preconcurrency[[:space:]]+)?import[[:space:]]+[A-Za-z0-9_]+\\b" \
    "${library_sources[@]}" \
    -g '*.swift' || true
)

if [[ -n "$library_non_foundation_imports" ]]; then
  library_non_foundation_imports=$(
    awk -F: '$3 !~ /^[[:space:]]*(@preconcurrency[[:space:]]+)?import[[:space:]]+(Foundation|MHPlatformCore)$/ { print }' \
      <<<"$library_non_foundation_imports"
  )
fi

if [[ -n "$library_non_foundation_imports" ]]; then
  record_failure "FluelLibrary/Sources may only import Foundation and MHPlatformCore:
$library_non_foundation_imports"
fi

library_package_urls=$(
  rg \
    --line-number \
    "url: \"" \
    "$repository_root/FluelLibrary/Package.swift" || true
)

if [[ -n "$library_package_urls" ]]; then
  unexpected_library_package_urls=$(
    awk '$0 !~ /https:\/\/github\.com\/muhiro12\/MHPlatform/ { print }' \
      <<<"$library_package_urls"
  )

  if [[ -n "$unexpected_library_package_urls" ]]; then
    record_failure "FluelLibrary/Package.swift should only depend on MHPlatform for MHPlatformCore:
$unexpected_library_package_urls"
  fi
fi

mhplatformcore_dependency=$(
  rg \
    --line-number \
    "name: \"MHPlatformCore\"" \
    "$repository_root/FluelLibrary/Package.swift" || true
)

if [[ -z "$mhplatformcore_dependency" ]]; then
  record_failure "FluelLibrary/Package.swift should depend on MHPlatformCore for shared link contracts."
fi

app_domain_declarations=$(
  rg \
    --line-number \
    "^[[:space:]]*(public[[:space:]]+|private[[:space:]]+|final[[:space:]]+|struct[[:space:]]+|enum[[:space:]]+|class[[:space:]]+)*(struct|enum|final[[:space:]]+class|class)[[:space:]]+(EntryStart|StartPrecision|TimeTogetherSummary|EntryDraft|EntryInput|EntrySnapshot|EntryOperations)\\b" \
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
    "productName = MHPlatform;" \
    "$repository_root/Fluel.xcodeproj/project.pbxproj" || true
)

if [[ -z "$mhplatform_runtime_links" ]]; then
  record_failure "The Fluel app target should link MHPlatform for runtime routing and logging:
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
