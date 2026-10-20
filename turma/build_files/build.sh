#!/bin/bash

# ==============================================================================
# legion turma - EliteDesk 800 G4 platform layer
#
# Six identical minis: i5-8500T, 16GB, UHD 630, NVMe. Firmware servicing
# only. i915/UHD 630 display support arrives via the kernel + linux-firmware
# already present in uCore - verified on first boot, not added here.
# This layer grows only from OBSERVED behavior on real hardware.
# ==============================================================================

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Firmware servicing for the 800 G4 platform
dnf5 install -y \
    fwupd