#!/bin/bash
# ==============================================================================
# legion dominus - game server fleet host
#
# Minimal substrate for rootless quadlet game servers. Wine + 32-bit
# multilib for legacy server binaries. steamcmd is NOT baked here -
# it self-updates, so it installs post-deploy into /var (see
# dominus-steamcmd.service). No dev tooling, no third-party repos.
# ==============================================================================

set -ouex pipefail

# Copy system_files
cp -avf "/ctx/system_files"/. /

### Substrate packages

# Legacy server binaries: wine for Windows dedicated servers,
# 32-bit multilib for ancient Linux natives
dnf5 install -y \
    wine \
    glibc.i686

# Session management for attach-and-debug
dnf5 install -y \
    tmux

# Steamcmd bootstrap (post-deploy, checksum-verified)
systemctl enable dominus-steamcmd.service