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
MODES=(catalog crash breakpoint)

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

cd "${ROOT_DIR}"

extract_udid() {
  perl -ne 'if (/\Q'"$1"'\E \(([0-9A-F-]+)\) \((?:Booted|Shutdown)\)/i) { print $1; exit }'
}

resolve_destination() {
  if [[ "${DEST_WAS_OVERRIDDEN}" == "1" ]]; then
    echo "Using caller-provided destination: ${DEST}"
    return
  fi

  local booted_udid=""
  booted_udid="$(
    xcrun simctl list devices booted 2>/dev/null | extract_udid "${PREFERRED_SIM_NAME}" || true
  )"

  if [[ -n "${booted_udid}" ]]; then
    DEST="platform=iOS Simulator,id=${booted_udid}"
    echo "Reusing already-booted simulator: ${PREFERRED_SIM_NAME} (${booted_udid})"
    return
  fi

  local available_udid=""
  available_udid="$(
    xcrun simctl list devices available 2>/dev/null | extract_udid "${PREFERRED_SIM_NAME}" || true
  )"

  if [[ -n "${available_udid}" ]]; then
    echo "No booted ${PREFERRED_SIM_NAME} found. Booting simulator ${available_udid}..."
    xcrun simctl boot "${available_udid}" >/dev/null 2>&1 || true
    xcrun simctl bootstatus "${available_udid}" -b
    DEST="platform=iOS Simulator,id=${available_udid}"
    return
  fi

  echo "Preferred simulator ${PREFERRED_SIM_NAME} was not found in available runtimes."
  echo "Falling back to name-based destination resolution."
  DEST="platform=iOS Simulator,name=${PREFERRED_SIM_NAME}"
}

resolve_destination

for MODE in "${MODES[@]}"; do
  case "${MODE}" in
    catalog)
      TEST_BASE="testScreenshot_catalog"
      ;;
    crash)
      TEST_BASE="testScreenshot_crashLabDetail"
      ;;
    breakpoint)
      TEST_BASE="testScreenshot_breakpointLabDetail"
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
