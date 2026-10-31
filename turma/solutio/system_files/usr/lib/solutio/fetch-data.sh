#!/bin/bash
# ==============================================================================
# solutio data layer fetcher - manifest-verified, atomic installs
#
# Tools live in the signed image; DATA lives in /var. This fetcher
# pulls rule sets / definitions / wordlists, sha256-verifies each,
# and atomically moves them into place. A bad checksum aborts that
# item without touching existing data.
#
# Sources are curated in /etc/solutio/data-manifest.conf:
#   name|url|sha256|relative_dest_dir|filename
# Harvest checksums by downloading once and running shasum -a 256,
# then pin the value in the manifest. Never trust a mirror's
# published hash alone.
# ==============================================================================

set -uo pipefail

MANIFEST="/etc/solutio/data-manifest.conf"
DATA_ROOT="/var/lib/solutio/data"
STAGING="$(mktemp -d)"
trap 'rm -rf "${STAGING}"' EXIT

mkdir -p "${DATA_ROOT}"

FAILURES=()

# --- Manifest-driven fetches -------------------------------------------
while IFS='|' read -r name url sha256 destdir filename; do
    # skip blanks and comments
    [[ -z "${name}" || "${name}" =~ ^[[:space:]]*# ]] && continue

    echo ">>> data: ${name}"

    dest="${DATA_ROOT}/${destdir}"
    target="${dest}/${filename}"

    if ! curl -fsL -o "${STAGING}/${filename}" "${url}"; then
        echo "  FAILED: download error"
        FAILURES+=("${name}")
        continue
    fi

    if ! echo "${sha256}  ${STAGING}/${filename}" | sha256sum --check --strict; then
        echo "  FAILED: checksum mismatch"
        FAILURES+=("${name}")
        continue
    fi

    mkdir -p "${dest}"
    mv -f "${STAGING}/${filename}" "${target}"
    echo "  OK: ${target}"
done < "${MANIFEST}"

# --- Specialized updaters (official mechanisms beat manifests) --------
if command -v freshclam >/dev/null 2>&1; then
    echo ">>> data: clamav definitions (freshclam)"
    freshclam --quiet || FAILURES+=("clamav-freshclam")
fi

if command -v suricata-update >/dev/null 2>&1; then
    echo ">>> data: suricata ET rules (suricata-update)"
    suricata-update --quiet || FAILURES+=("suricata-et-rules")
fi

# --- Report -------------------------------------------------------------
if ((${#FAILURES[@]} > 0)); then
    echo "================================================================"
    echo "DATA FETCH REPORT - failures:"
    echo "================================================================"
    for item in "${FAILURES[@]}"; do
        echo "  FAILED: ${item}"
    fi
    echo ""
    echo "Existing data was NOT modified for failed items."
    exit 1
fi

echo "Data layer fetch complete."
exit 0