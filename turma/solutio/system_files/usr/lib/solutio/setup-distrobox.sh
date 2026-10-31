#!/bin/bash
# ==============================================================================
# Create or refresh solutio distrobox instances
#
# Run on the Solutio node after deploy to instantiate the boxes.
# Boxes persist locally but pull fresh images on demand.
# ==============================================================================

set -euo pipefail

BOXES=(
    "solutio-offense:ghcr.io/zachrielforever/solutio-offense:latest"
    "solutio-dotnet:ghcr.io/zachrielforever/solutio-dotnet:latest"
)

for box_spec in "${BOXES[@]}"; do
    IFS=':' read -r name image <<<"${box_spec}"
    echo ">>> Setting up distrobox: ${name}"

    if distrobox list | grep -q "^${name}$"; then
        echo "  Removing existing box..."
        distrobox rm -f "${name}"
    fi

    distrobox create --name "${name}" --image "${image}" --home --init
    echo "  Done. Run: distrobox enter ${name}"
done