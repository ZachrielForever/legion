#!/usr/bin/env bash
# Delete cached ROMs untouched longer than RETENTION_DAYS.
# WARNING: relies on atime. relatime (default) is adequate for >=1 day
# thresholds; a noatime mount silently breaks this. See docs.
set -euo pipefail

CONF="/etc/memoria/roms.conf"
[ -r "${CONF}" ] || exit 0   # unconfigured node - nothing to prune
# shellcheck source=/dev/null
source "${CONF}"

RETENTION_DAYS="${RETENTION_DAYS:-30}"
ROMCACHE_DIR="${ROMCACHE_DIR:-/var/cache/memoria/roms}"
[ -d "${ROMCACHE_DIR}" ] || exit 0

find "${ROMCACHE_DIR}" -type f -atime "+${RETENTION_DAYS}" -delete
find "${ROMCACHE_DIR}" -depth -mindepth 1 -type d -empty -delete