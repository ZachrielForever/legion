#!/bin/bash

# ==============================================================================
# legion solutio - reverse-engineering / forensics toolbox (tailnet only)
#
# The powerhouse: the fleet's RE and analysis toolset lives HERE and
# nowhere else. Fat by design - when you're on solutio mid-task, the
# tool is already there. .NET SDKs stay in distroboxes (container
# discipline); compiled-binary analysis is THIS node's job.
#
# GUI tools (ghidra, imhex, wireshark) run over `ssh -X` from a
# workstation; xauth enables it on this otherwise-headless host.
# ==============================================================================

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Packet archaeology (wiretest lineage)
dnf5 install -y \
    tcpdump \
    wireshark-cli \
    nmap

# Archive & format excavation
dnf5 install -y \
    p7zip \
    p7zip-plugins \
    unar \
    unrar \
    bsdtar \
    xorriso \
    unshield

# Binary inspection & disassembly
dnf5 install -y \
    radare2 \
    gdb \
    binutils \
    binwalk \
    imhex \
    imhex-patterns \
    hexedit \
    file

# Filesystem forensics & recovery
dnf5 install -y \
    sleuthkit \
    testdisk \
    ddrescue

# Runtime observation
dnf5 install -y \
    strace \
    ltrace

# Windows binary execution for native RE (wine + mono for .NET)
dnf5 install -y \
    wine

# Database clients (trickemu schema work)
dnf5 install -y \
    mariadb \
    sqlite

# Plumbing
dnf5 install -y \
    xauth \
    java-25-openjdk


### Ghidra - pinned release, checksum-verified
#
# Source: https://github.com/NationalSecurityAgency/ghidra/releases/tag/Ghidra_12.1.4_build
GHIDRA_ZIP_URL="https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_12.1.4_build/ghidra_12.1.4_PUBLIC_20260921.zip"
GHIDRA_SHA256="ddac49f903da9d5bac833e5cc79395098b9c33cfd3279be5f31bd00387d2d4db"

curl -fL -o /tmp/ghidra.zip "${GHIDRA_ZIP_URL}"

echo "${GHIDRA_SHA256}  /tmp/ghidra.zip" | sha256sum --check --strict

unzip -q /tmp/ghidra.zip -d /opt
GhidraDir=$(echo /opt/ghidra_*)
ln -sf "${GhidraDir}/ghidraRun" /usr/local/bin/ghidra
ln -sf "${GhidraDir}/support/analyzeHeadless" /usr/local/bin/ghidra-headless
rm -f /tmp/ghidra.zip