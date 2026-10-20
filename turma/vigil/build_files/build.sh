#!/bin/bash

# ==============================================================================
# legion vigil - monitoring / fleet-utility node (tailnet only)
#
# Minimal OS by design: monitoring daemons, probes, and dashboards
# run as containers/scripts. The host carries only what makes it a
# good place to diagnose the REST of the fleet from.
# ==============================================================================

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Fleet diagnosis over SSH: throughput + path
dnf5 install -y \
    btop \
    iperf3 \
    mtr \
    tcpdump