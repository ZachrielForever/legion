#!/bin/bash

# ==============================================================================
# legion solutio - reverse-engineering / forensics toolbox (tailnet only)
#
# The powerhouse: the fleet's RE and analysis toolset lives HERE and
# nowhere else. Fat by design - when you're on solutio mid-task, the
# tool is already there. .NET SDKs stay in distroboxes (container
# discipline); compiled-binary analysis is THIS node's job.
#
# Task contract: if it exists, it can be extracted, inspected,
# decompiled, and observed. Coverage beats minimalism on this node.
#
# PHILOSOPHY: tools live in this signed image; DATA does not. Rule
# sets, hash databases, and definition files (yara, NSRL, clamav,
# volatility symbols, zeek/suricata rules, wordlists - rockyou,
# seclists) churn constantly and are fetched post-deploy into
# mutable /var storage, not baked here.
#
# OFFENSE: "the best defense is a good offense" - attack tooling is
# in-scope on this node (sqlmap, hydra, impacket, responder, netexec,
# nmap scripts, hashcat). EXCEPTION: metasploit ships only through
# Rapid7's own nightly RPM repo - an unsigned third-party channel -
# and belongs in a disposable distrobox on this host, NOT in the
# signed image.
#
# VERIFICATION PASS: every package below is checked against enabled
# repos (dnf5 repoquery) BEFORE any bulk install. Missing packages
# are reported as a complete named list plus the enabled repolist
# (so repo-visibility anomalies like the 2026-10-31 xauth/ffmpeg
# case can be diagnosed from the same output) and the build fails
# there. Only dnf5-plugins is installed unguarded (needed to enable
# the COPR before the check can see its contents). This is the
# triage gate: the CI failure output IS the why/where/how.
#
# TRIAGE HISTORY:
#   2026-10-31 run 1 - "python3-pipx" does not exist in Fedora;
#                correct name is "pipx". Plumbing moved under the
#                verification pass after it failed ahead of the
#                triage report.
#   2026-10-31 run 1 - jadx + apktool blocks commented out pending
#                checksum hunt; promote after first green build.
#   2026-10-31 run 2 - F44 retirement wave renamed four packages:
#                p7zip/p7zip-plugins -> 7zip (upstream abandoned
#                2016; RAR covered by unrar), libguestfs-tools ->
#                guestfs-tools (upstream split 2021), ewf-tools ->
#                ewftools (Fedora subpackage naming), dosbox ->
#                dosbox-staging (classic dosbox retired from Fedora).
#                sqlmap moved to pipx (not packaged in Fedora at
#                all). scrcpy dropped (COPR-only AND a workstation
#                GUI tool - a headless node has no use for it).
#                hashdeep KEPT deliberately: could not confirm
#                either way, so the gate itself arbitrates; if it
#                reappears, drop it and rely on ssdeep + sha256sum
#                manifest workflow. xauth/ffmpeg anomalies: kept,
#                repolist now dumped on failure to diagnose.
#
# KNOWN NOT PACKAGED (do not add to arrays - handled by pinned
# release blocks or documented routes below):
#   plaso           -> GIFT COPR @gift/stable (enabled below);
#                       array entry MUST read "plaso-tools" exactly
#   zeek            -> openSUSE Build Service repos only; left OUT.
#                      suricata covers protocol reconstruction.
#   bettercap       -> Go binary; candidate for pinned-release block
#   metasploit      -> Rapid7 nightly repo only; distrobox instead
#   scrcpy          -> COPR-only (zeno/scrcpy); workstation tool,
#                      run from your desktop, not this headless node
#   sqlmap          -> pipx (see Python tier below)
#   jadx, apktool   -> pinned GitHub releases; BLOCKED pending
#                      checksums (see commented blocks below)
#
# GUI tools (ghidra, imhex, wireshark) run over `ssh -X` from a
# workstation; xauth enables it on this otherwise-headless host.
# ==============================================================================

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### ------------------------------------------------------------------
### Package manifests - single source of truth
### ------------------------------------------------------------------

# Packet archaeology (wiretest lineage) + active network offense
PKGS_NETWORK=(
    tcpdump
    wireshark
    wireshark-cli
    nmap
    socat
    hydra
)

# Archive & format excavation (XP-era and modern)
# NOTE: p7zip/p7zip-plugins were RETIRED in Fedora 44; the official
# upstream 7-Zip port replaces them. RAR handled by unrar.
PKGS_ARCHIVE=(
    7zip
    unar
    unrar
    bsdtar
    xorriso
    unshield
    cabextract
    msitools
    cpio
    squashfs-tools
    arj
    xar
    lhasa
)

# Binary inspection & disassembly
PKGS_BINARY=(
    radare2
    gdb
    binutils
    elfutils
    patchelf
    nasm
    yara
    binwalk
    imhex
    imhex-patterns
    hexedit
    file
)

# LLVM: llvm-objdump disassembles EVERY architecture (x86/ARM/MIPS/
# PowerPC/RISC-V) from one binary; lldb carries a built-in
# decompiler. Plus compilers: RE produces hypotheses, hypotheses
# need test binaries (PoCs, harnesses, patched rebuilds).
PKGS_TOOLCHAIN=(
    llvm
    gcc
    gcc-c++
    make
    cmake
)

# Runtime observation & foreign-architecture execution
PKGS_OBSERVE=(
    strace
    ltrace
    valgrind
    rr
    perf
    qemu-user
    qemu-user-static
)

# Full-system emulation for legacy OSes wine cannot serve
# (Win9x/XP-era software in a sandboxed period-correct guest).
# NOTE: classic dosbox was retired from Fedora; dosbox-staging is
# the maintained successor (modern renderer, active development).
PKGS_EMULATE=(
    qemu-system-x86
    dosbox-staging
)

# Filesystem, disk & VM image forensics
# NOTE: guestfs-tools is the post-2021 split of libguestfs-tools
# (carries guestfish, virt-*); ewftools is Fedora's subpackage name
# for the libewf EWF utilities (Debian calls it ewf-tools).
PKGS_DISK=(
    sleuthkit
    testdisk
    ddrescue
    qemu-img
    guestfs-tools
    ewftools
    mtools
    cryptsetup
    dislocker
    mdadm
    lvm2
)

# Storage/device interrogation (RAW SCSI/NVMe/SATA commands, SMART)
PKGS_STORAGE=(
    sg3_utils
    sdparm
    smartmontools
    nvme-cli
    hdparm
)

# Hardware boundary tooling (the M80 rear serial port earns its keep)
PKGS_HARDWARE=(
    minicom
    picocom
    screen
    lrzsz
    flashrom
    openocd
    i2c-tools
    can-utils
    sigrok-cli
    pulseview
    sigrok-firmware-fx2lafw
    rtl-sdr
)

# Windows artifact parsing (registry hives, Outlook PST/OST, legacy
# installers beyond MSI/CAB - the classic "dead box" evidence tier)
PKGS_WINARTIFACT=(
    hivex
    libpst
    innoextract
    samba-client
)

# Network forensics - capture PLUS protocol reconstruction/IDS analysis
PKGS_NETFORENSICS=(
    suricata
)

# Audio/video/document stream extraction & metadata
PKGS_MEDIA=(
    ffmpeg
    mediainfo
    sox
    perl-Image-ExifTool
    poppler-utils
    pdfgrep
)

# Legacy optical disc handling (subchannel/RAW reads - disc-protection era)
PKGS_OPTICAL=(
    cdrdao
    cuetools
)

# Password & crypto recovery (GPU acceleration via hashcat on
# instrumentum-class hardware with a dGPU)
PKGS_PWCRACK=(
    john
    hashcat
)

# Malware triage on unknown binaries (definitions live in /var,
# updated post-deploy - see PHILOSOPHY above)
PKGS_MALWARE=(
    clamav
)

# OCI/container & cloud artifact inspection
PKGS_CLOUD=(
    skopeo
    rclone
)

# Database clients (trickemu schema work)
PKGS_DB=(
    mariadb
    postgresql
    sqlite
)

# Integrity & fuzzy hashing
# hashdeep deliberately retained despite run 2 triage flag: could
# not confirm either way from outside; the gate arbitrates. If it
# reappears as MISSING, remove it - ssdeep + sha256sum manifest
# workflow covers integrity auditing.
PKGS_HASH=(
    hashdeep
    ssdeep
)

# Big-image acquisition plumbing (parallel compression for disk dumps)
PKGS_BIGIMAGE=(
    pigz
    pbzip2
    miller
)

# Mobile device access & mirroring.
# scrcpy REMOVED: COPR-only packaging, and it is a display-mirroring
# GUI tool - useless on a headless node. Run it from a workstation
# against the USB-connected phone instead.
PKGS_MOBILE=(
    android-tools
    libimobiledevice-utils
)

# Windows binary execution for native RE (wine + mono for .NET)
PKGS_WINDOWS=(
    wine
    mono-core
)

# Plumbing (incl. build-time deps for pinned installs below)
PKGS_PLUMBING=(
    xauth
    java-25-openjdk
    unzip
    curl
    pipx
)

# Third-party COPR additions (enabled below before verification)
# SPELLING MATTERS: "plaso-tools" exactly - run 2 failed partly on
# a spelling drift here.
PKGS_COPR=(
    plaso-tools
)

### ------------------------------------------------------------------
### Repository setup - the ONLY unguarded install in the script.
### dnf5-plugins is required to enable the COPR at all; everything
### else waits for the verification pass.
### ------------------------------------------------------------------

dnf5 install -y dnf5-plugins

# GIFT COPR for plaso (official Plaso packaging; supports current
# Fedora stable). NOTE: when ucore rebases to a newer Fedora before
# the COPR catches up, THIS is where the build will fail - expected.
dnf5 copr enable @gift/stable
dnf5 makecache

### ------------------------------------------------------------------
### Verification pass - fail fast, name EVERYTHING that is missing
###
### Runs before any bulk install. A missing package aborts the build
### with a complete list plus the enabled repolist, so a red CI run
### is both the triage report AND the diagnostic context.
### ------------------------------------------------------------------

ALL_PKGS=(
    "${PKGS_NETWORK[@]}"
    "${PKGS_ARCHIVE[@]}"
    "${PKGS_BINARY[@]}"
    "${PKGS_TOOLCHAIN[@]}"
    "${PKGS_OBSERVE[@]}"
    "${PKGS_EMULATE[@]}"
    "${PKGS_DISK[@]}"
    "${PKGS_STORAGE[@]}"
    "${PKGS_HARDWARE[@]}"
    "${PKGS_WINARTIFACT[@]}"
    "${PKGS_NETFORENSICS[@]}"
    "${PKGS_MEDIA[@]}"
    "${PKGS_OPTICAL[@]}"
    "${PKGS_PWCRACK[@]}"
    "${PKGS_MALWARE[@]}"
    "${PKGS_CLOUD[@]}"
    "${PKGS_DB[@]}"
    "${PKGS_HASH[@]}"
    "${PKGS_BIGIMAGE[@]}"
    "${PKGS_MOBILE[@]}"
    "${PKGS_WINDOWS[@]}"
    "${PKGS_PLUMBING[@]}"
    "${PKGS_COPR[@]}"
)

MISSING_PKGS=()
for pkg in "${ALL_PKGS[@]}"; do
    if [[ -z "$(dnf5 -q repoquery "${pkg}")" ]]; then
        MISSING_PKGS+=("${pkg}")
    fi
done

if ((${#MISSING_PKGS[@]} > 0)); then
    echo "================================================================"
    echo "TRIAGE REPORT - packages not found in enabled repos:"
    echo "================================================================"
    for pkg in "${MISSING_PKGS[@]}"; do
        echo "  MISSING: ${pkg}"
    done
    echo ""
    echo "Enabled repos at time of check (for visibility diagnostics,"
    echo "e.g. RPM Fusion availability):"
    dnf5 repolist
    echo ""
    echo "Routes to resolution: correct the package name, verify the"
    echo "COPR/third-party repo is enabled, or move the tool to the"
    echo "pinned-release pattern (see Ghidra block) - never delete"
    echo "silently."
    exit 1
fi

### ------------------------------------------------------------------
### Install
### ------------------------------------------------------------------

for group in NETWORK ARCHIVE BINARY TOOLCHAIN OBSERVE EMULATE DISK \
             STORAGE HARDWARE WINARTIFACT NETFORENSICS MEDIA OPTICAL \
             PWCRACK MALWARE CLOUD DB HASH BIGIMAGE MOBILE WINDOWS \
             PLUMBING COPR; do
    dnf5 install -y "$(eval echo \${PKGS_${group}[@]})"
done

### -------------------------------------------------------------------
### Ghidra - pinned release, checksum-verified
#
# Source: https://github.com/NationalSecurityAgency/ghidra/releases/tag/Ghidra_12.1.4_build
# Installed under /usr/lib: on ostree/bootc systems /opt and /usr/local are
# symlinks into /var, which is machine-local state and NOT carried in the image.
### -------------------------------------------------------------------

GHIDRA_ZIP_URL="https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_12.1.4_build/ghidra_12.1.4_PUBLIC_20260921.zip"
GHIDRA_SHA256="ddac49f903da9d5bac833e5cc79395098b9c33cfd3279be5f31bd00387d2d4db"

curl -fL -o /tmp/ghidra.zip "${GHIDRA_ZIP_URL}"

echo "${GHIDRA_SHA256}  /tmp/ghidra.zip" | sha256sum --check --strict

mkdir -p /usr/lib/ghidra
unzip -q /tmp/ghidra.zip -d /usr/lib/ghidra
GhidraDir=$(echo /usr/lib/ghidra/ghidra_*)
ln -sf "${GhidraDir}/ghidraRun" /usr/bin/ghidra
ln -sf "${GhidraDir}/support/analyzeHeadless" /usr/bin/ghidra-headless
rm -f /tmp/ghidra.zip


### -------------------------------------------------------------------
### jadx - pinned release, checksum-verified
#
# BLOCKED pending checksum hunt - intentionally commented out until
# the first green build. Promote by: downloading the tagged release,
# recording its SHA256 into JADX_SHA256 below, and uncommenting.
#
# NOT in Fedora repos (upstream documents Arch/brew/Flathub/manual
# only). DEX->Java decompiler: the fastest path from APK/JAR to
# readable source. Complements apktool (resource/smali layer).
### -------------------------------------------------------------------

# JADX_VERSION="1.5.6"
# JADX_URL="https://github.com/skylot/jadx/releases/download/v${JADX_VERSION}/jadx-${JADX_VERSION}.zip"
# JADX_SHA256="VERIFY-BEFORE-BUILD: see https://github.com/skylot/jadx/releases tag v${JADX_VERSION}"
#
# curl -fL -o /tmp/jadx.zip "${JADX_URL}"
#
# echo "${JADX_SHA256}  /tmp/jadx.zip" | sha256sum --check --strict
#
# unzip -q /tmp/jadx.zip -d /usr/lib/jadx
# ln -sf /usr/lib/jadx/bin/jadx /usr/bin/jadx
# ln -sf /usr/lib/jadx/bin/jadx-gui /usr/bin/jadx-gui
# rm -f /tmp/jadx.zip


### -------------------------------------------------------------------
### apktool - pinned release, checksum-verified
#
# BLOCKED pending checksum hunt - intentionally commented out until
# the first green build. Promote by: downloading the tagged release,
# recording its SHA256 into APKTOOL_SHA256 below, and uncommenting.
#
# NOT in Fedora repos (upstream documents manual jar + wrapper
# script). Single jar + wrapper; Java already on image. Resource
# and smali layer of APK analysis (jadx covers the Java layer).
### -------------------------------------------------------------------

# APKTOOL_VERSION="3.0.0"
# APKTOOL_URL="https://github.com/iBotPeaches/Apktool/releases/download/v${APKTOOL_VERSION}/apktool_${APKTOOL_VERSION}.jar"
# APKTOOL_SHA256="VERIFY-BEFORE-BUILD: see https://github.com/iBotPeaches/Apktool/releases tag v${APKTOOL_VERSION}"
#
# curl -fL -o /usr/lib/java/apktool.jar "${APKTOOL_URL}"
#
# echo "${APKTOOL_SHA256}  /usr/lib/java/apktool.jar" | sha256sum --check --strict
#
# cat > /usr/bin/apktool <<'EOF'
# #!/bin/sh
# exec java -jar /usr/lib/java/apktool.jar "$@"
# EOF
# chmod +x /usr/bin/apktool


### -------------------------------------------------------------------
### Python analysis tooling via pipx
#
# PIPX_HOME/PIPX_BIN_DIR redirect into /usr because pipx defaults to
# ~/.local, and /root on bootc systems is machine-local state,
# NOT carried in the image - same reasoning as the Ghidra /usr/lib
# install.
### -------------------------------------------------------------------

export PIPX_HOME=/usr/lib/pipx
export PIPX_BIN_DIR=/usr/bin

# Dynamic instrumentation (inject into black-box processes at runtime)
pipx install frida-tools

# Memory dump analysis
pipx install volatility3

# Office macro / OLE document inspection
pipx install oletools

# Interactive HTTPS interception (game client/server traffic)
pipx install mitmproxy

# Exploit dev / CTF swiss-army knife
pipx install pwntools

# Android APK static analysis
pipx install androguard

# Registry hive parsing with CLI (complements hivex for Windows images)
pipx install regipy

# Firmware/container format parsing: UEFI capsules, Intel ME, Dell BIOS
pipx install uefi-firmware-parser

# JFFS2 extraction (embedded firmware)
pipx install jefferson

# UBI/UBIFS extraction (raw NAND images from embedded devices)
pipx install ubi_reader

# SDR signal inspection (GUI over ssh -X)
pipx install urh

# Cloud account inspection
pipx install awscli

# --- offensive tier ---
# Automatic SQL injection and database takeover - NOT packaged in
# Fedora (everyone else ships it; Fedora doesn't), pure Python
pipx install sqlmap

# Windows/AD post-exploitation primitives (secretsdump, wmiexec, ...)
pipx install impacket

# LLMNR/NBT-NS/MDNS poisoner (capture and relay)
pipx install responder

# Network situational awareness / lateral movement (crackmapexec successor)
pipx install netexec

# Symbolic execution - heavyweight; enable on demand if ever needed
# pipx install angr


### -------------------------------------------------------------------
### DEFERRED - data layer (post-deploy into /var, manifest-verified):
#   yara rules, NSRL hash sets, clamav definitions, volatility
#   symbol tables, ghidra FID updates, suricata ET rules,
#   wordlists (rockyou.txt, SecLists)
###
### DEFERRED - candidates for the pinned-release Ghidra pattern:
#   jadx, apktool (blocked pending checksums - blocks retained,
#                 commented, at top of this section's history)
#   UEFITool     - UEFI image inspection/editing
#   bettercap    - MITM/traffic interception (Go binary)
#   chdman       - MAME compressed disc format (needs build recipe)
#   sasquatch    - patched unsquashfs for odd firmware squashfs
###
### DEFERRED - distrobox, not signed image:
#   metasploit (Rapid7 nightly repo only), dotnet SDKs
###
### REMOVED - reasoned out, do not re-add without updating the
### triage history at the top:
#   scrcpy - COPR-only AND a display-mirroring GUI tool; run from a
#            workstation, not this headless node
### -------------------------------------------------------------------