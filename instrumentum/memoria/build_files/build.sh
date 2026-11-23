#!/usr/bin/env bash
set -euo pipefail

# Memoria - emulation compute node (instrumentum)
# Base: bazzite:stable (KDE). Scope: NES -> PS2 + handhelds. No streaming stack in v1.
# NOTE: image content goes in /usr. /opt, /usr/local, /srv, /home are /var symlinks
#       on ostree/bootc and are NOT carried in the image. (Solutio lesson.)

source /ctx/pins.env

### ---------------------------------------------------------------------------
### Repositories
### ---------------------------------------------------------------------------
# Bazzite ships RPM Fusion, but verify rather than assume - pcsx2/ppsspp live there.
if ! rpm -q rpmfusion-free-release >/dev/null 2>&1; then
    dnf5 install -y \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
fi

### ---------------------------------------------------------------------------
### Emulators - Fedora proper
### ---------------------------------------------------------------------------
dnf5 install -y \
    mednafen \
    sameboy \
    mupen64plus \
    dolphin-emu \
    dolphin-emu-tool \
    mame

### ---------------------------------------------------------------------------
### Emulators - RPM Fusion
### ---------------------------------------------------------------------------
dnf5 install -y \
    pcsx2 \
    ppsspp-sdl

### ---------------------------------------------------------------------------
### Pinned upstream releases - re-scoped Nov 23 2026 (console experience, ceiling PS2/GC)
### ---------------------------------------------------------------------------
# Same discipline as Solutio's Ghidra: pinned version, SHA-256 verified,
# extracted into /usr/lib, symlinked into /usr/bin.
#
# GATED OUT (chunk-3 re-scope): melonDS, Azahar, Vita3K.
#   - melonDS: source build requires SDL2-devel -> pkgconfig(glu) chain, but
#     bazzite's base filters out mesa-libGLU-devel by exclude. Also drags a
#     full cmake/qt6 toolchain into the image. RetroArch melonDS core covers NDS.
#   - Azahar (3DS) and Vita3K (PSV): above the PS2/GC ceiling per new brief;
#     Vita3K is a rolling-release checksum tripwire that would break CI randomly.
#   Kept: blastem (Genesis/32X, within scope, checksum verified).

fetch_pinned() {
    local name="$1" url="$2" sha="$3" dest="$4"
    echo "==> ${name}"
    curl -fL --retry 3 -o "/tmp/${name}.dl" "${url}"
    echo "${sha}  /tmp/${name}.dl" | sha256sum --check --strict
    install -d "${dest}"
    shift 4
    "$@" /tmp/${name}.dl "${dest}"
    rm -f "/tmp/${name}.dl"
}

# BlastEm - Genesis / Sega CD / 32X / SMS / Game Gear
fetch_pinned blastem "${BLASTEM_URL}" "${BLASTEM_SHA256}" /usr/lib/blastem \
    bash -c 'tar -xf "$0" -C "$1" --strip-components=1'
ln -sf /usr/lib/blastem/blastem /usr/bin/blastem

# Azahar gated out 2026-11-23: 3DS is above the PS2/GC scope ceiling.
# Re-enable only if scope grows (URL/hash pins stay in pins.env).
# fetch_pinned azahar "${AZAHAR_URL}" "${AZAHAR_SHA256}" /usr/lib/azahar \
#     bash -c 'chmod +x "$0"; cd "$1" && "$0" --appimage-extract >/dev/null && mv squashfs-root/* . && rm -rf squashfs-root'
# ln -sf /usr/lib/azahar/AppRun /usr/bin/azahar

# Vita3K gated out 2026-11-23: PS Vita is above the PS2/GC scope ceiling and
# the 'continuous' rolling artifact tripped its checksum tripwire (by design).
# Re-enable only after scope grows to include Vita AND the new build is reviewed.
# fetch_pinned vita3k "${VITA3K_URL}" "${VITA3K_SHA256}" /usr/lib/vita3k \
#     bash -c 'chmod +x "$0"; cd "$1" && "$0" --appimage-extract >/dev/null && mv squashfs-root/* . && rm -rf squashfs-root'
# ln -sf /usr/lib/vita3k/AppRun /usr/bin/vita3k

# melonDS gated out 2026-11-23: source build drags the cmake/qt6 toolchain
# into the image, and SDL2-devel now requires pkgconfig(glu) which bazzite's
# base exclude-filters (mesa-libGLU-devel unavailable). zstd-devel also
# renamed to libzstd-devel in F45. RetroArch's melonDS core covers NDS.
# Pins retained in pins.env for a possible flatpak/core pivot.
# dnf5 install -y cmake ninja-build gcc-c++ qt6-qtbase-devel qt6-qtmultimedia-devel \
#     libslirp-devel zstd-devel libarchive-devel SDL2-devel libepoxy-devel
# curl -fL --retry 3 -o /tmp/melonds.tar.gz "${MELONDS_URL}"
# echo "${MELONDS_SHA256}  /tmp/melonds.tar.gz" | sha256sum --check --strict
# mkdir -p /tmp/melonds-src
# tar -xf /tmp/melonds.tar.gz -C /tmp/melonds-src --strip-components=1
# cmake -S /tmp/melonds-src -B /tmp/melonds-build -G Ninja \
#     -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
# ninja -C /tmp/melonds-build
# ninja -C /tmp/melonds-build install
# rm -rf /tmp/melonds-src /tmp/melonds-build /tmp/melonds.tar.gz

### ---------------------------------------------------------------------------
### ROM cache layer
### ---------------------------------------------------------------------------
install -Dpm0755 /ctx/romcache-sync  /usr/libexec/memoria/romcache-sync
install -Dpm0755 /ctx/romcache-prune /usr/libexec/memoria/romcache-prune
install -Dpm0755 /ctx/romcache-clear /usr/libexec/memoria/romcache-clear
install -Dpm0644 /ctx/memoria-romcache-clear.service /usr/lib/systemd/system/memoria-romcache-clear.service
install -Dpm0644 /ctx/memoria-romcache-prune.service /usr/lib/systemd/system/memoria-romcache-prune.service
install -Dpm0644 /ctx/memoria-romcache-prune.timer   /usr/lib/systemd/system/memoria-romcache-prune.timer
systemctl enable memoria-romcache-clear.service memoria-romcache-prune.timer

### ---------------------------------------------------------------------------
### Cleanup
### ---------------------------------------------------------------------------
dnf5 clean all
rm -rf /var/cache/dnf5 /var/cache/libdnf5