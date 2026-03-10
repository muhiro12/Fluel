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

if ! command -v pre-commit >/dev/null 2>&1; then
  echo "pre-commit is not installed. Install it and retry." >&2
  echo "Install with: pipx install pre-commit or brew install pre-commit" >&2
  exit 1
fi

changed_files=$(
  {
    git diff --name-only --cached
    git diff --name-only
    git ls-files --others --exclude-standard
  } | sed '/^$/d' | sort -u
)

pre_commit_targets=()
while IFS= read -r path; do
  [[ -n "$path" ]] || continue
  [[ -e "$path" ]] || continue

  case "$path" in
    *.swift|Package.swift|*/Package.swift|.swiftlint.yml|.pre-commit-config.yaml)
      pre_commit_targets+=("$path")
      ;;
  esac
done <<<"$changed_files"

if [[ ${#pre_commit_targets[@]} -eq 0 ]]; then
  echo "No relevant local changes for pre-commit."
  exit 0
fi

echo "Running pre-commit checks on local changes..."
pre-commit run --files "${pre_commit_targets[@]}"
