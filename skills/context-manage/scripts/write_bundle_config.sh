#!/usr/bin/env bash
# shellcheck shell=bash
# Writes bootstrap/bundle-config (first line only). Gateway reads this before BODHI_BOOTSTRAP_BUNDLE.
# Valid values: complete | basic | minimal
# Usage: echo basic | bash skills/context-manage/scripts/write_bundle_config.sh
#     or: bash skills/context-manage/scripts/write_bundle_config.sh minimal
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
TARGET="${ROOT}/bootstrap/bundle-config"

if [[ -n "${1:-}" ]]; then
  RAW="$1"
else
  RAW="$(cat)"
fi

ID="$(echo "${RAW}" | head -n1 | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
case "${ID}" in
  complete|basic|minimal) ;;
  *)
    echo "write_bundle_config: invalid bundle '${ID}' (use complete, basic, or minimal)" >&2
    exit 1
    ;;
esac

mkdir -p "$(dirname "${TARGET}")"
printf '%s\n' "${ID}" >"${TARGET}"
echo "write_bundle_config: wrote ${TARGET} -> ${ID}" >&2
