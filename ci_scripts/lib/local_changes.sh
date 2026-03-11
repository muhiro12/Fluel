#!/usr/bin/env bash

ci_collect_changed_files() {
  {
    git diff --name-only --cached
    git diff --name-only
    git ls-files --others --exclude-standard
  } | sed '/^$/d' | sort -u
}

ci_is_pre_commit_relevant_path() {
  local path=$1

  case "$path" in
    *.swift|Package.swift|*/Package.swift|.swiftlint.yml|.pre-commit-config.yaml)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

ci_collect_pre_commit_targets() {
  local changed_files=${1-}

  if [[ -z "$changed_files" ]]; then
    changed_files=$(ci_collect_changed_files)
  fi

  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    [[ -e "$path" ]] || continue

    if ci_is_pre_commit_relevant_path "$path"; then
      printf '%s\n' "$path"
    fi
  done <<<"$changed_files"
}
