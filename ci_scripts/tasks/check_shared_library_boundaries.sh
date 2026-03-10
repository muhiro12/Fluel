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

forbidden_import_matches=$(
  rg --line-number \
    '^import (SwiftUI|TipKit|PhotosUI|WidgetKit|MHAppRuntimeCore|MHUI|AppIntents|StoreKit|StoreKitWrapper|GoogleMobileAds|GoogleMobileAdsWrapper|UserNotifications)$' \
    --glob '!FluelLibrary/Sources/Preview/**' \
    FluelLibrary/Sources || true
)

if [[ -n "$forbidden_import_matches" ]]; then
  echo "Shared library boundary check failed." >&2
  echo "Keep app-only frameworks out of FluelLibrary/Sources." >&2
  echo "$forbidden_import_matches" >&2
  exit 1
fi

echo "Shared library boundary check passed."
