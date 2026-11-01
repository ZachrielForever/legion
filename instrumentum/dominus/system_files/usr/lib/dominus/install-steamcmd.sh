#!/bin/bash
# ==============================================================================
# Install steamcmd into /var (self-updating tool, not image material).
# Bootstrap tarball checksum-verified before install. Idempotent:
# skips install if steamcmd already present. Update STEAMCMD_SHA256
# whenever Valve ships a new bootstrap (re-harvest and paste).
# ==============================================================================

set -ouex pipefail

STEAMCMD_URL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
STEAMCMD_SHA256="cebf0046bfd08cf45da6bc094ae47aa39ebf4155e5ede41373b579b8f1071e7c"
STEAMCMD_ROOT="/var/lib/steamcmd"

if [[ -x "${STEAMCMD_ROOT}/steamcmd.sh" ]]; then
    echo "steamcmd already installed at ${STEAMCMD_ROOT}; skipping."
    exit 0
fi

mkdir -p "${STEAMCMD_ROOT}"

curl -fsL -o /tmp/steamcmd.tar.gz "${STEAMCMD_URL}"
echo "${STEAMCMD_SHA256}  /tmp/steamcmd.tar.gz" | sha256sum --check --strict

tar -xzf /tmp/steamcmd.tar.gz -C "${STEAMCMD_ROOT}"
rm -f /tmp/steamcmd.tar.gz

echo "steamcmd installed. First run will self-update:"
echo "  ${STEAMCMD_ROOT}/steamcmd.sh +quit"