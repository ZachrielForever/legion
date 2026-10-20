#!/bin/bash

# ==============================================================================
# legion vox - private media server (UHD 630 media stack)
#
# Drivers/codecs for hardware transcoding; actual media serving (Jellyfin)
# runs as containers via quadlet. No public exposure; Tailscale-only access.
# ==============================================================================

set -ouex pipefail

cp -avf "/ctx/system_files"/. /

### Install packages

# Intel QuickSync VA-API driver stack (UHD 630 decode/encode)
dnf5 install -y \
    intel-media-driver \
    libva-utils \
    vainfo

# Media transcoding utilities (used by Jellyfin for format conversion)
dnf5 install -y \
    ffmpeg

# Audio codec support (OPUS, FLAC, AAC for music library)
dnf5 install -y \
    gstreamer1-plugins-base \
    gstreamer1-plugins-good \
    gstreamer1-plugins-bad-free