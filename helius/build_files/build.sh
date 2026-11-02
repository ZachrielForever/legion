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