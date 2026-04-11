#!/usr/bin/env bash
#
# Capture SignalLab UI screenshots by running one XCTest per surface, exporting PNG attachments
# from the .xcresult bundle (same workflow as JoesProxy memlog/utility_scripts/grab_screenshot.sh).
#
# Output: memlog/ui-review/signallab-screenshot-<mode>-<timestamp>.png
#         (accessibility: ...-<mode>-accessibility-<timestamp>.png)
#
# Usage (from anywhere):
#   SignalLab/Scripts/grab_screenshot.sh
#   SignalLab/Scripts/grab_screenshot.sh --text-size accessibility
#   SignalLab/Scripts/grab_screenshot.sh --destination 'platform=iOS Simulator,name=iPhone 17 Pro'
#
# Modes (see MODES): catalog, crash, exception, breakpoint, retain, hang, cpu, thread, zombie, tsan, malloc — one UI test + PNG export each.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${ROOT_DIR}/memlog/ui-review"
TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
TEXT_SIZE="standard"
PREFERRED_SIM_NAME="iPhone 17"
DEST=""
DEST_WAS_OVERRIDDEN=0
SCHEME="SignalLab"
UITEST_TARGET="SignalLabUITests"
TEST_CLASS="SignalLabScreenshotUITests"
# Order matches curriculum: MVP labs, then diagnostics (thread perf → zombie → tsan → malloc).
MODES=(catalog crash exception breakpoint retain hang cpu thread zombie tsan malloc)
LOCK_DIR="${OUTPUT_DIR}/.grab-screenshot.lock"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --text-size)
      TEXT_SIZE="${2:-}"
      shift 2
      ;;
    --destination|-d)
      DEST="${2:-}"
      DEST_WAS_OVERRIDDEN=1
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      echo "Usage: $0 [--text-size standard|accessibility] [--destination <xcodebuild-destination>]"
      exit 1
      ;;
  esac
done

if [[ "${TEXT_SIZE}" != "standard" && "${TEXT_SIZE}" != "accessibility" ]]; then
  echo "Unsupported text size: ${TEXT_SIZE} (use standard or accessibility)"
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"
find "${OUTPUT_DIR}" -maxdepth 1 -type d -name '.grab-screenshot-*' -exec rm -rf {} + 2>/dev/null || true

acquire_lock() {
  if mkdir "${LOCK_DIR}" 2>/dev/null; then
    echo "$$" > "${LOCK_DIR}/pid"
    trap release_lock EXIT
    return
  fi

  local existing_pid=""
  if [[ -f "${LOCK_DIR}/pid" ]]; then
    existing_pid="$(<"${LOCK_DIR}/pid")"
  fi

  if [[ -n "${existing_pid}" ]] && kill -0 "${existing_pid}" 2>/dev/null; then
    echo "Another screenshot capture is already running (pid ${existing_pid})."
    echo "Wait for it to finish or remove ${LOCK_DIR} if that process is gone."
    exit 1
  fi

  rm -rf "${LOCK_DIR}"
  mkdir "${LOCK_DIR}"
  echo "$$" > "${LOCK_DIR}/pid"
  trap release_lock EXIT
}

release_lock() {
  rm -rf "${LOCK_DIR}"
}

cd "${ROOT_DIR}"

boot_simulator_if_needed() {
  local udid="$1"
  if [[ -z "${udid}" ]]; then
    return
  fi

  local state=""
  state="$(xcrun simctl list devices "${udid}" 2>/dev/null | perl -ne 'if (/\(([0-9A-F-]+)\) \((Booted|Shutdown)\)/) { print $2; exit }' || true)"
  if [[ "${state}" == "Booted" ]]; then
    return
  fi

  echo "Booting simulator ${udid}..."
  xcrun simctl boot "${udid}" >/dev/null 2>&1 || true
  xcrun simctl bootstatus "${udid}" -b
}

udid_from_destination() {
  perl -ne 'if (/id=([0-9A-F-]+)/i) { print $1; exit }'
}

resolve_preferred_simulator() {
  xcrun simctl list devices available --json | jq -r --arg name "${PREFERRED_SIM_NAME}" '
    .devices
    | to_entries
    | map(select(.key | startswith("com.apple.CoreSimulator.SimRuntime.iOS-")))
    | map(. as $runtime | .value[] | select(.name == $name and .isAvailable == true) | {
        runtime: $runtime.key,
        udid: .udid,
        state: .state
      })
    | sort_by(.runtime | capture("iOS-(?<version>.*)$").version | split("-") | map(tonumber))
    | last // empty
    | [.udid, .runtime, .state] | @tsv
  '
}

resolve_destination() {
  if [[ "${DEST_WAS_OVERRIDDEN}" == "1" ]]; then
    echo "Using caller-provided destination: ${DEST}"
    local overridden_udid=""
    overridden_udid="$(printf '%s\n' "${DEST}" | udid_from_destination || true)"
    boot_simulator_if_needed "${overridden_udid}"
    return
  fi

  local preferred_info=""
  preferred_info="$(resolve_preferred_simulator)"

  if [[ -z "${preferred_info}" ]]; then
    echo "Preferred simulator ${PREFERRED_SIM_NAME} was not found in available iOS runtimes."
    echo "Falling back to name-based destination resolution."
    DEST="platform=iOS Simulator,name=${PREFERRED_SIM_NAME}"
    return
  fi

  local preferred_udid=""
  local preferred_runtime=""
  local preferred_state=""
  IFS=$'\t' read -r preferred_udid preferred_runtime preferred_state <<< "${preferred_info}"

  if [[ "${preferred_state}" == "Booted" ]]; then
    DEST="platform=iOS Simulator,id=${preferred_udid}"
    echo "Reusing already-booted simulator: ${PREFERRED_SIM_NAME} (${preferred_udid}, ${preferred_runtime})"
    return
  fi

  echo "Booting preferred simulator: ${PREFERRED_SIM_NAME} (${preferred_udid}, ${preferred_runtime})..."
  boot_simulator_if_needed "${preferred_udid}"
  DEST="platform=iOS Simulator,id=${preferred_udid}"
}

acquire_lock
resolve_destination

for MODE in "${MODES[@]}"; do
  case "${MODE}" in
    catalog)
      TEST_BASE="testScreenshot_catalog"
      ;;
    crash)
      TEST_BASE="testScreenshot_crashLabDetail"
      ;;
    exception)
      TEST_BASE="testScreenshot_exceptionBreakpointLabDetail"
      ;;
    breakpoint)
      TEST_BASE="testScreenshot_breakpointLabDetail"
      ;;
    retain)
      TEST_BASE="testScreenshot_retainCycleLabDetail"
      ;;
    hang)
      TEST_BASE="testScreenshot_hangLabDetail"
      ;;
    cpu)
      TEST_BASE="testScreenshot_cpuHotspotLabDetail"
      ;;
    thread)
      TEST_BASE="testScreenshot_threadPerformanceCheckerLabDetail"
      ;;
    zombie)
      TEST_BASE="testScreenshot_zombieObjectsLabDetail"
      ;;
    tsan)
      TEST_BASE="testScreenshot_threadSanitizerLabDetail"
      ;;
    malloc)
      TEST_BASE="testScreenshot_mallocStackLoggingLabDetail"
      ;;
    *)
      echo "Unsupported mode: ${MODE}"
      exit 1
      ;;
  esac

  if [[ "${TEXT_SIZE}" == "accessibility" ]]; then
    TEST_NAME="${TEST_BASE}_accessibilityText"
  else
    TEST_NAME="${TEST_BASE}"
  fi

  TEST_IDENTIFIER="${TEST_CLASS}/${TEST_NAME}()"
  ONLY_TESTING="${UITEST_TARGET}/${TEST_CLASS}/${TEST_NAME}"

  if [[ "${TEXT_SIZE}" == "standard" ]]; then
    FINAL_IMAGE="${OUTPUT_DIR}/signallab-screenshot-${MODE}-${TIMESTAMP}.png"
  else
    FINAL_IMAGE="${OUTPUT_DIR}/signallab-screenshot-${MODE}-accessibility-${TIMESTAMP}.png"
  fi

  SCRATCH_DIR="${OUTPUT_DIR}/.grab-screenshot-${MODE}-${TEXT_SIZE}-${TIMESTAMP}"
  RESULT_BUNDLE="${SCRATCH_DIR}/screenshot-${MODE}-${TEXT_SIZE}-${TIMESTAMP}.xcresult"
  EXPORT_DIR="${SCRATCH_DIR}/attachments"
  KEEP_SCRATCH_ON_EXIT=1

  cleanup() {
    if [[ "${KEEP_SCRATCH_ON_EXIT}" == "1" ]]; then
      echo
      echo "Preserving screenshot scratch artifacts for inspection:"
      echo "  ${SCRATCH_DIR}"
      return
    fi
    rm -rf "${SCRATCH_DIR}"
  }
  trap cleanup EXIT

  rm -rf "${SCRATCH_DIR}"
  mkdir -p "${SCRATCH_DIR}"

  echo "Running ${MODE} screenshot UI test (${TEXT_SIZE})..."
  echo "  -only-testing:${ONLY_TESTING}"
  echo "Output image: ${FINAL_IMAGE}"

  xcodebuild test \
    -scheme "${SCHEME}" \
    -destination "${DEST}" \
    -only-testing:"${ONLY_TESTING}" \
    -resultBundlePath "${RESULT_BUNDLE}" \
    CODE_SIGNING_ALLOWED=NO

  echo
  echo "Exporting ${MODE} screenshot attachment..."

  xcrun xcresulttool export attachments \
    --path "${RESULT_BUNDLE}" \
    --output-path "${EXPORT_DIR}" \
    --test-id "${TEST_IDENTIFIER}"

  ATTACHMENT_IMAGE="$(find "${EXPORT_DIR}" -type f -name "*.png" 2>/dev/null | head -n 1)"

  if [[ -z "${ATTACHMENT_IMAGE}" ]]; then
    echo "No PNG attachment was exported from ${RESULT_BUNDLE}."
    echo "Try opening the bundle in Xcode, or inspect: xcrun xcresulttool get --path \"${RESULT_BUNDLE}\" --format json"
    exit 1
  fi

  cp "${ATTACHMENT_IMAGE}" "${FINAL_IMAGE}"
  KEEP_SCRATCH_ON_EXIT=0
  cleanup
  trap - EXIT

  echo
  echo "Saved ${MODE} screenshot:"
  echo "  ${FINAL_IMAGE}"
  echo
done

echo "All screenshot modes finished."
