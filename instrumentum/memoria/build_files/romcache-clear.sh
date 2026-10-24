#!/usr/bin/env bash
# Boot-wipe the ROM cache. Called by memoria-romcache-clear.service.
set -euo pipefail

CONF="/etc/memoria/roms.conf"
ROMCACHE_DIR="/var/cache/memoria/roms"
[ -r "${CONF}" ] && source "${CONF}"
ROMCACHE_DIR="${ROMCACHE_DIR:-/var/cache/memoria/roms}"

[ -d "${ROMCACHE_DIR}" ] || exit 0
find "${ROMCACHE_DIR}" -mindepth 1 -delete