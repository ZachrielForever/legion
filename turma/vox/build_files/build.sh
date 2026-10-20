#!/bin/bash

# ==============================================================================
# legion vox - private media server (tailnet only)
#
# Host carries only the driver stack for the UHD 630: VA-API for
# hardware decode/encode, passthrough via /dev/dri to containers.
# Media services (Jellyfin, etc.) run as quadlets with their own
# bundled ffmpeg - no transcoding binaries on the host.
# ==============================================================================

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Hardware video decode/encode (Quick Sync on UHD 630)
# libva-intel-media-driver is in Fedora proper; intel-media-driver is RPM Fusion
dnf5 install -y \
    libva-intel-media-driver \
    libva-utils