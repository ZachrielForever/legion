#!/usr/bin/env bash
# Memoria ROM cache sync - pull from Horreum into local cache.
# Config: /etc/memoria/roms.conf (machine state, set at first boot).
set -euo pipefail

CONF="/etc/memoria/roms.conf"
[ -r "${CONF}" ] || { echo "romcache: ${CONF} missing - configure at first boot" >&2; exit 1; }

# shellcheck source=/dev/null
source "${CONF}"

: "${ROMCACHE_SOURCE:?ROMCACHE_SOURCE unset in ${CONF}}"
ROMCACHE_DIR="${ROMCACHE_DIR:-/var/cache/memoria/roms}"

mkdir -p "${ROMCACHE_DIR}"
rsync --archive --partial --info=stats1 "${ROMCACHE_SOURCE%/}/" "${ROMCACHE_DIR}/"