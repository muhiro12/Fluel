#!/usr/bin/env bash

ci_task_require_no_arguments() {
  local argument_count=$1

  if [[ $argument_count -ne 0 ]]; then
    echo "This script does not accept arguments." >&2
    exit 2
  fi
}

ci_task_enter_repository_root() {
  local script_path=$1
  local script_directory

  script_directory=$(cd "$(dirname "$script_path")" && pwd)
  repository_root=$(cd "$script_directory/../.." && pwd)
  cd "$repository_root"
}

ci_task_require_git_repository() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This script must run inside a git repository." >&2
    exit 1
  fi
}
