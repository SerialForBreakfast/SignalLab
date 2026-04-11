#!/usr/bin/env bash
# Backward-compatible entry: runs the full screenshot batch (see grab_screenshot.sh).
set -euo pipefail
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/grab_screenshot.sh" "$@"
