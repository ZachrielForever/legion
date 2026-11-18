#!/bin/bash
# ==============================================================================
# legion lorica - travel node / sister to aegis
#
# Mask over bazzite (KDE, AMD iGPU, no NVIDIA, no dx layer). Upstream
# provides the desktop and gaming stack. This image adds nothing by
# design - dire-need only. Fleet identity via labels.
# Parameterized by BASE_TAG: stable / testing / unstable.
# ==============================================================================

set -ouex pipefail

# Copy system_files (fastfetch config reserved for fleet identity)
cp -avf "/ctx/system_files"/. /

### Core packages
/ctx/10-install-packages.sh

### Fleet identity
# image-info.json declares the image's own name/branch. Upstream's
# values survive derivation, so rewrite them for this node.
# install(1) resets mode to 644 — mktemp defaults to 600, which
# breaks bazzite-fetch-image for non-root users (fastfetch line).
IMAGE_INFO="/usr/share/ublue-os/image-info.json"
if [[ ! -f "${IMAGE_INFO}" ]]; then
    echo "ERROR: ${IMAGE_INFO} missing — upstream layout change?" >&2
    exit 1
fi

tmp="$(mktemp)"
jq ". + {\"image-name\": \"lorica\", \"image-branch\": \"${BASE_TAG}\"}" \
    "${IMAGE_INFO}" > "${tmp}"
install -m 644 "${tmp}" "${IMAGE_INFO}"
rm -f "${tmp}"