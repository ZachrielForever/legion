#!/bin/bash
# ==============================================================================
# legion helius - daily driver / fleet orchestrator
#
# Mask over bazzite-dx-nvidia. Upstream DX layer already provides:
# docker, VS Code, devcontainers, VMs (QEMU/libvirt/virt-manager),
# waypipe, restic/rclone, homebrew, ROCm, podman tooling. This image
# adds nothing by design - dire-need only. Fleet identity via labels.
# ==============================================================================

set -ouex pipefail

# Copy system_files (currently empty - reserved for fleet identity)
cp -avf "/ctx/system_files"/. /

### Fleet identity
# image-info.json declares the image's own name/branch. Upstream's
# values survive derivation, so rewrite them for this node.
IMAGE_INFO="/usr/share/ublue-os/image-info.json"
if [[ -f "${IMAGE_INFO}" ]]; then
    tmp="$(mktemp)"
    jq '. + {"image-name": "helius", "image-branch": "stable"}' "${IMAGE_INFO}" > "${tmp}"
    mv "${tmp}" "${IMAGE_INFO}"
fi