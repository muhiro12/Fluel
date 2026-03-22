#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/task_runtime.sh"

ci_task_require_no_arguments "$#"
ci_task_enter_repository_root "${BASH_SOURCE[0]}"

forbidden_import_matches=$(
  rg --line-number \
    '^import (SwiftUI|TipKit|PhotosUI|WidgetKit|MHPlatform|MHAppRuntime|MHAppRuntimeCore|MHMutationFlow|MHReviewPolicy|MHUI|AppIntents|StoreKit|StoreKitWrapper|GoogleMobileAds|GoogleMobileAdsWrapper|UserNotifications)$' \
    --glob '!FluelLibrary/Sources/Preview/**' \
    FluelLibrary/Sources || true
)

if [[ -n "$forbidden_import_matches" ]]; then
  echo "Shared library boundary check failed." >&2
  echo "Keep app-only and app-facing platform modules out of FluelLibrary/Sources." >&2
  echo "$forbidden_import_matches" >&2
  exit 1
fi

echo "Shared library boundary check passed."
