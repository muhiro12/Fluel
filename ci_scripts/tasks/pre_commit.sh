#!/usr/bin/env bash
set -euo pipefail

argument_count=$#
if [[ $argument_count -ne 0 ]]; then
  echo "This script does not accept arguments." >&2
  exit 2
fi

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repository_root=$(cd "$script_directory/../.." && pwd)
cd "$repository_root"

source "$repository_root/ci_scripts/lib/local_changes.sh"

if ! command -v pre-commit >/dev/null 2>&1; then
  echo "pre-commit is not installed. Install it and retry." >&2
  echo "Install with: pipx install pre-commit or brew install pre-commit" >&2
  exit 1
fi

changed_files=$(ci_collect_changed_files)

pre_commit_targets=()
while IFS= read -r path; do
  pre_commit_targets+=("$path")
done < <(ci_collect_pre_commit_targets "$changed_files")

if [[ ${#pre_commit_targets[@]} -eq 0 ]]; then
  echo "No relevant local changes for pre-commit."
  exit 0
fi

echo "Running pre-commit checks on local changes..."
pre-commit run --files "${pre_commit_targets[@]}"
