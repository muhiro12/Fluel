#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

secret_content_pattern='(BEGIN [A-Z0-9 ]*PRIVATE KEY|ghp_[A-Za-z0-9]+|github_pat_[A-Za-z0-9_]+|AIza[0-9A-Za-z_-]{20,}|AKIA[0-9A-Z]{16}|sk_live_[A-Za-z0-9]+|xox[baprs]-[A-Za-z0-9-]+)'

is_forbidden_path() {
  local path=$1

  case "$path" in
    Secret.swift|*/Secret.swift|\
    GoogleService-Info.plist|*/GoogleService-Info.plist|\
    Configuration.storekit|*/Configuration.storekit|\
    StoreKitTestCertificate.cer|*/StoreKitTestCertificate.cer|\
    *.mobileprovision|*.provisionprofile|*.p12|*.p8|*.jks|*.keystore)
      return 0
      ;;
    .env|*/.env|.env.*|*/.env.*)
      case "$path" in
        *.example|*.sample|*.template)
          return 1
          ;;
        *)
          return 0
          ;;
      esac
      ;;
    *)
      return 1
      ;;
  esac
}

collect_forbidden_paths() {
  local path

  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    if is_forbidden_path "$path"; then
      printf '%s\n' "$path"
    fi
  done
}

current_candidate_paths=$(
  {
    git ls-files
    git ls-files --others --exclude-standard
  } | sed '/^$/d' | LC_ALL=C sort -u
)

current_forbidden_paths=$(
  printf '%s\n' "$current_candidate_paths" | collect_forbidden_paths
)

historical_forbidden_paths=$(
  git rev-list --objects --all |
    awk '{print $2}' |
    sed '/^$/d' |
    LC_ALL=C sort -u |
    collect_forbidden_paths
)

working_tree_secret_matches=$(
  rg \
    --line-number \
    --hidden \
    --glob '!.git/**' \
    --glob '!.build/**' \
    --regexp "$secret_content_pattern" \
    . || true
)

history_secret_matches=$(
  git rev-list --all | xargs git grep --line-number --extended-regexp --ignore-case --textconv "$secret_content_pattern" || true
)

if [[ -n "$current_forbidden_paths" || -n "$historical_forbidden_paths" || -n "$working_tree_secret_matches" || -n "$history_secret_matches" ]]; then
  echo "Public repository safety check failed." >&2
  echo "Remove or ignore secret-bearing files before creating a public GitHub repository." >&2

  if [[ -n "$current_forbidden_paths" ]]; then
    echo >&2
    echo "Tracked or publishable local files that should stay out of the repository:" >&2
    printf '%s\n' "$current_forbidden_paths" >&2
  fi

  if [[ -n "$historical_forbidden_paths" ]]; then
    echo >&2
    echo "Sensitive-looking file paths found in git history:" >&2
    printf '%s\n' "$historical_forbidden_paths" >&2
  fi

  if [[ -n "$working_tree_secret_matches" ]]; then
    echo >&2
    echo "Secret-like content found in the current working tree:" >&2
    printf '%s\n' "$working_tree_secret_matches" >&2
  fi

  if [[ -n "$history_secret_matches" ]]; then
    echo >&2
    echo "Secret-like content found in git history:" >&2
    printf '%s\n' "$history_secret_matches" >&2
  fi

  exit 1
fi

echo "Public repository safety check passed."
