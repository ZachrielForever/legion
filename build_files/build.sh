#!/bin/bash

# ==============================================================================
# legion base image - fleet policy build script
#
# True of EVERY fleet node: tailnet membership, hardened SSH posture,
# TTY tooling, basic diagnostics. Hardware specifics live in derived
# images (ed/, variants/); role packages live in role variants.
#
# Boilerplate below is from the ublue image-template; package list is
# modeled on ZachrielForever/dominus build.sh, trimmed to fleet-common.
# ==============================================================================

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Core shell and interactive tooling
dnf5 install -y \
    btop \
    fastfetch \
    fish \
    git \
    jq \
    micro \
    tmux \
    tree \
    yq

# Console fonts for physical display
dnf5 install -y \
    terminus-fonts

# Diagnostics - the minimum every node should have for triage
dnf5 install -y \
    ethtool \
    iotop \
    lsof \
    mtr \
    strace \
    sysstat \
    bind-utils

# Transfer and verification (checksum manifests between nodes)
dnf5 install -y \
    lz4 \
    pv \
    rsync \
    xz \
    zstd

# Overlay networking
dnf5 install -y \
    tailscale

### Services

# Tailscale daemon (enrollment state persists in /var across image updates)
systemctl enable tailscaled