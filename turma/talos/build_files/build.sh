#!/bin/bash

# ==============================================================================
# legion talos - CI / Forgejo forge (tailnet only)
#
# Single-purpose: runs Forgejo and its runners as containers.
# The host carries only what's strictly necessary for the forge
# to function; all tooling lives inside the runners themselves.
# ==============================================================================

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Git Large File Support - required for repositories with binary assets
dnf5 install -y \
    git-lfs