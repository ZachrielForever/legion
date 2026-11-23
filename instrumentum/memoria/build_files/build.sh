#!/usr/bin/env bash
set -euo pipefail

# Memoria - emulation console node (instrumentum), v1 rewrite 2026-11-23.
# Fresh start: native components only, each proven green in earlier runs.
# Removed in rewrite (return as separate chunks): romcache layer (broken
# /ctx filenames, logic was sound), melonDS/Azahar/Vita3K pins (GLU exclude
# wall / above PS2-GC scope). Containerfile drops COPY system_files until
# system files exist again.

### ---------------------------------------------------------------------------
### RPM Fusion - required for pcsx2 / ppsspp
### ---------------------------------------------------------------------------
if ! rpm -q rpmfusion-free-release >/dev/null 2>&1; then
    dnf5 install -y \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
fi

### ---------------------------------------------------------------------------
### Emulators - native packages only
### Fedora: retro span up to Dreamcast/MAME. RPM Fusion: PS2 + PSP.
### (GLU caveat: only the Fedora-package set, no -devel chains.)
### ---------------------------------------------------------------------------
dnf5 install -y \
    mednafen \
    sameboy \
    mupen64plus \
    dolphin-emu \
    dolphin-emu-tool \
    mame

dnf5 install -y \
    pcsx2 \
    ppsspp-sdl

### ---------------------------------------------------------------------------
### Pinned upstream - blastem (no RPM exists; checksum verified 2026-11-23)
### ---------------------------------------------------------------------------
source /ctx/pins.env

fetch_pinned() {
    local name="$1" url="$2" sha="$3" dest="$4"
    echo "==> ${name}"
    curl -fL --retry 3 -o "/tmp/${name}.dl" "${url}"
    echo "${sha}  /tmp/${name}.dl" | sha256sum --check --strict
    install -d "${dest}"
    shift 4
    "$@" "/tmp/${name}.dl" "${dest}"
    rm -f "/tmp/${name}.dl"
}

# BlastEm - Genesis / Sega CD / 32X / SMS / Game Gear
fetch_pinned blastem "${BLASTEM_URL}" "${BLASTEM_SHA256}" /usr/lib/blastem \
    bash -c 'tar -xf "$0" -C "$1" --strip-components=1'
ln -sf /usr/lib/blastem/blastem /usr/bin/blastem

### ---------------------------------------------------------------------------
### Cleanup
### ---------------------------------------------------------------------------
dnf5 clean all
rm -rf /var/cache/dnf5 /var/cache/libdnf5
