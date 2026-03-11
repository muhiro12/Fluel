#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/task_runtime.sh"

ci_task_require_no_arguments "$#"
ci_task_enter_repository_root "${BASH_SOURCE[0]}"

source "$repository_root/ci_scripts/lib/ci_runs.sh"
source "$repository_root/ci_scripts/lib/local_changes.sh"

ci_task_require_git_repository

ci_root="$repository_root/.build/ci"
runs_root="$ci_root/runs"
compat_runs_root="$repository_root/.build/ci_runs"
shared_directory="$ci_root/shared"
cache_directory="$shared_directory/cache"
derived_data_directory="$shared_directory/DerivedData"
shared_tmp_directory="$shared_directory/tmp"
shared_home_directory="$shared_directory/home"

ensure_compat_runs_root() {
  if [[ -L "$compat_runs_root" || ! -e "$compat_runs_root" ]]; then
    mkdir -p "$(dirname "$compat_runs_root")"
    ln -sfn "ci/runs" "$compat_runs_root"
    return 0
  fi

  if [[ -d "$compat_runs_root" ]]; then
    return 0
  fi

  echo "Compatibility path $compat_runs_root exists and is not a directory or symlink." >&2
  exit 1
}

ensure_compat_runs_root

run_directory=$(ci_run_create_dir "$runs_root")
run_identifier=$(basename "$run_directory")

if [[ -d "$compat_runs_root" && ! -L "$compat_runs_root" ]]; then
  ln -sfn "../ci/runs/$run_identifier" "$compat_runs_root/$run_identifier"
fi

commands_file="$run_directory/commands.txt"
summary_path="$run_directory/summary.md"
meta_path="$run_directory/meta.json"
logs_directory="$run_directory/logs"
results_directory="$run_directory/results"
run_work_directory="$run_directory/work"

mkdir -p \
  "$run_work_directory" \
  "$cache_directory" \
  "$derived_data_directory" \
  "$shared_tmp_directory" \
  "$shared_home_directory"

start_epoch=$(date +%s)
start_time_display=$(date +"%Y-%m-%d %H:%M:%S %z")
start_time_iso=$(date +"%Y-%m-%dT%H:%M:%S%z")

overall_result="success"
run_note="Evaluating local changes to determine required build/test steps."
failed_step=""
failed_log=""
executed_steps=()

finalize_run_artifacts() {
  local exit_code=$1
  set +e

  local end_epoch
  local end_time_display
  local end_time_iso
  local duration_seconds
  local executed_steps_markdown

  end_epoch=$(date +%s)
  end_time_display=$(date +"%Y-%m-%d %H:%M:%S %z")
  end_time_iso=$(date +"%Y-%m-%dT%H:%M:%S%z")
  duration_seconds=$((end_epoch - start_epoch))

  if [[ $exit_code -ne 0 ]]; then
    overall_result="failure"
    if [[ -z "$run_note" || "$run_note" == "Executed required CI steps based on local changes." ]]; then
      run_note="A required step failed. Review failure details and logs."
    fi
  fi

  if [[ ${#executed_steps[@]} -eq 0 ]]; then
    executed_steps_markdown="- No build/test steps were required."
  else
    executed_steps_markdown=""
    local executed_step
    for executed_step in "${executed_steps[@]}"; do
      executed_steps_markdown+="- ${executed_step}"$'\n'
    done
    executed_steps_markdown=${executed_steps_markdown%$'\n'}
  fi

  ci_run_write_summary \
    "$summary_path" \
    "$run_identifier" \
    "$start_time_display" \
    "$end_time_display" \
    "$overall_result" \
    "$run_note" \
    "$executed_steps_markdown" \
    "$failed_step" \
    "$failed_log" \
    "$logs_directory" \
    "$results_directory" \
    "$commands_file" || true

  ci_run_write_meta \
    "$meta_path" \
    "$run_identifier" \
    "$start_time_iso" \
    "$end_time_iso" \
    "$duration_seconds" \
    "$overall_result" \
    "$run_note" \
    "$failed_step" \
    "$failed_log" \
    "$commands_file" \
    "$logs_directory" \
    "$results_directory" || true

  ci_run_prune_old_runs "$runs_root" 5 || true
}

trap 'finalize_run_artifacts "$?"' EXIT

ci_run_capture_command "$commands_file" "$0" "$@"
echo "CI run artifacts: $run_directory"

run_logged_step() {
  local step_identifier=$1
  local step_description=$2
  shift 2

  local log_path="$logs_directory/${step_identifier}.log"
  executed_steps+=("$step_description")

  ci_run_capture_command \
    "$commands_file" \
    "CI_RUN_DIR=$run_directory" \
    "CI_RUN_WORK_DIR=$run_work_directory" \
    "CI_SHARED_DIR=$shared_directory" \
    "CI_CACHE_DIR=$cache_directory" \
    "CI_DERIVED_DATA_DIR=$derived_data_directory" \
    "CI_RUN_RESULTS_DIR=$results_directory" \
    "AI_RUN_RESULTS_DIR=$results_directory" \
    "AI_RUN_WORK_DIR=$run_work_directory" \
    "AI_RUN_CACHE_ROOT=$cache_directory" \
    "$@"

  echo "Running ${step_description}."
  set +e
  CI_RUN_DIR="$run_directory" \
    CI_RUN_WORK_DIR="$run_work_directory" \
    CI_SHARED_DIR="$shared_directory" \
    CI_CACHE_DIR="$cache_directory" \
    CI_DERIVED_DATA_DIR="$derived_data_directory" \
    CI_RUN_RESULTS_DIR="$results_directory" \
    AI_RUN_RESULTS_DIR="$results_directory" \
    AI_RUN_WORK_DIR="$run_work_directory" \
    AI_RUN_CACHE_ROOT="$cache_directory" \
    "$@" 2>&1 | tee "$log_path"
  local command_status=${PIPESTATUS[0]}
  set -e

  if [[ $command_status -ne 0 ]]; then
    failed_step="$step_description"
    failed_log="$log_path"
    overall_result="failure"
    run_note="A required step failed. Review failure details and logs."
    return "$command_status"
  fi

  return 0
}

changed_files=$(ci_collect_changed_files)

build_relevant_changed_files=$(printf '%s\n' "$changed_files" | grep -Ev '(^|/)xcuserdata/' || true)
pre_commit_relevant_changed_files=$(ci_collect_pre_commit_targets "$changed_files")

should_run_pre_commit=false
if [[ "${CI_RUN_ENABLE_PRE_COMMIT:-0}" == "1" || "${CI_RUN_ENABLE_PRE_COMMIT:-}" == "true" ]]; then
  should_run_pre_commit=true
elif [[ "${CI_RUN_ENABLE_PRE_COMMIT:-}" == "auto" && -n "$pre_commit_relevant_changed_files" ]]; then
  should_run_pre_commit=true
fi

if $should_run_pre_commit; then
  run_logged_step \
    "pre_commit" \
    "Run pre-commit hooks" \
    bash "$repository_root/ci_scripts/tasks/pre_commit.sh"
fi

if [[ -z "$changed_files" ]]; then
  echo "No local changes detected."
  if $should_run_pre_commit; then
    run_note="pre-commit completed. No local changes detected. Build/test steps were skipped."
  else
    run_note="No local changes detected. Build/test steps were skipped."
  fi
  exit 0
fi

needs_fluel_build=false
needs_fluel_library_tests=false

if grep -Eq '^Fluel/|^FluelWidget/|^Fluel\.xcodeproj/' <<<"$build_relevant_changed_files"; then
  needs_fluel_build=true
fi

if grep -Eq '^FluelLibrary/' <<<"$build_relevant_changed_files"; then
  needs_fluel_library_tests=true
fi

if ! $needs_fluel_build && ! $needs_fluel_library_tests; then
  echo "No changes under Fluel/, FluelWidget/, FluelLibrary/, or Fluel.xcodeproj/."
  if $should_run_pre_commit; then
    run_note="pre-commit completed. No changes under Fluel/, FluelWidget/, FluelLibrary/, or Fluel.xcodeproj/. Build/test steps were skipped."
  else
    run_note="No changes under Fluel/, FluelWidget/, FluelLibrary/, or Fluel.xcodeproj/. Build/test steps were skipped."
  fi
  exit 0
fi

run_note="Executed required CI steps based on local changes."

run_logged_step \
  "check_shared_library_boundaries" \
  "Check shared library platform boundaries" \
  bash "$repository_root/ci_scripts/tasks/check_shared_library_boundaries.sh"

if $needs_fluel_build; then
  run_logged_step \
    "build_app" \
    "Build Fluel scheme" \
    bash "$repository_root/ci_scripts/tasks/build_app.sh"
fi

if $needs_fluel_library_tests; then
  run_logged_step \
    "test_shared_library" \
    "Test FluelLibrary scheme" \
    bash "$repository_root/ci_scripts/tasks/test_shared_library.sh"
fi
