#!/bin/bash

# ==============================================================================
# legion horreum - NAS storage node
#
# Second lineage: FROM ucore-hci, NOT legion:stable. Fleet policy is
# reapplied here by hand - keep it in sync with base/build_files/build.sh
# when fleet policy changes.
#
# ZFS (modules + Cockpit storage come from ucore-hci). SAS drives
# behind an HBA, split private/public pools. File services containerized.
# ==============================================================================

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Fleet policy packages
#
# NOTE: mirror the package set from base/build_files/build.sh,
# minus graphics drivers (this is a headless storage node; the 5700G's
# iGPU needs nothing beyond what ucore-hci already ships).
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

### NAS-specific packages

# ZFS snapshot management (sanoid = snapshots, syncoid = replication)
dnf5 install -y \
    sanoid

# Drive health for the SAS spindles
dnf5 install -y \
    smartmontools

# NFS/SMB server bits - deliberately NOT here; services run as containers.