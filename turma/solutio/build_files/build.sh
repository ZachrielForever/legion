#!/bin/bash

# ==============================================================================
# legion solutio - reverse-engineering / forensics toolbox (tailnet only)
#
# Task contract: if it exists, it can be extracted, inspected,
# decompiled, and observed. Fat by design; coverage beats minimalism.
#
# Tools live in this signed image. DATA (rule sets, hash dbs, wordlists,
# virus defs) does not - fetched post-deploy into /var, never baked.
#
# Offensive tooling in-scope ("best defense is a good offense").
# Exceptions: metasploit (unsigned Rapid7 repo) and .NET SDKs live in
# distroboxes, not the image.
#
# Third-party repos (GPG-signed, both asserted in repolist after enable):
#   GIFT COPR @gift/stable  - plaso
#   RPM Fusion free/nonfree - ffmpeg
#
# CI gates:
#   - dnf verification pass: every package repoquery-checked before
#     any install; failures reported as a named list.
#   - pipx gate: per-tool install, failures collected and reported.
#   - Repo enables are asserted, never trusted (exit codes lie).
#
# TRIAGE LOG:
#   run 1: python3-pipx -> pipx; unguarded plumbing install moved
#          under verification pass. jadx/apktool blocks parked
#          pending checksums.
#   run 2: F44 renames: p7zip -> 7zip, libguestfs-tools ->
#          guestfs-tools, ewf-tools -> ewftools, dosbox ->
#          dosbox-staging. sqlmap -> pipx. scrcpy dropped (COPR-only,
#          GUI tool, headless node). hashdeep kept pending evidence.
#   run 3: "dnf5 copr enable" silently declined without -y (no TTY);
#          now -y + asserted. RPM Fusion absent from build container;
#          now enabled via release RPMs. xauth -> xorg-x11-xauth.
#          hashdeep removed (confirmed absent, two runs).
#   run 4: install loop quoted arrays into one argument; rewritten
#          with namerefs.
#   run 5: ffmpeg-libs conflicts with lib*-free; --allowerasing on
#          FUSION group.
#   run 6: GIFT libewf conflicts with Fedora libewf; --allowerasing
#          extended to COPR group.
#   run 7: uefi-firmware-parser -> PyPI name "uefi-firmware";
#          pipx triage gate added.
#
# GUI tools (ghidra, imhex, wireshark) run over ssh -X from a
# workstation.
# ==============================================================================

set -ouex pipefail

cp -avf "/ctx/system_files"/. /

### ------------------------------------------------------------------
### Package manifests
### ------------------------------------------------------------------

# Network capture + offense
PKGS_NETWORK=(
    tcpdump
    wireshark
    wireshark-cli
    nmap
    socat
    hydra
)

# Archives and package formats
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

# Static analysis
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

# Universal disassembly (llvm-objdump, lldb decompiler) + build toolchain
PKGS_TOOLCHAIN=(
    llvm
    gcc
    gcc-c++
    make
    cmake
)

# Runtime observation + foreign-arch execution
PKGS_OBSERVE=(
    strace
    ltrace
    valgrind
    rr
    perf
    qemu-user
    qemu-user-static
)

# Legacy OS emulation
PKGS_EMULATE=(
    qemu-system-x86
    dosbox-staging
)

# Disk / filesystem / VM image forensics
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

# Storage device interrogation
PKGS_STORAGE=(
    sg3_utils
    sdparm
    smartmontools
    nvme-cli
    hdparm
)

# Hardware boundary (serial, flash, JTAG, buses, SDR)
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

# Windows artifact parsing (registry, PST, installers, SMB)
PKGS_WINARTIFACT=(
    hivex
    libpst
    innoextract
    samba-client
)

# IDS / protocol reconstruction
PKGS_NETFORENSICS=(
    suricata
)

# Media / document metadata
PKGS_MEDIA=(
    mediainfo
    sox
    perl-Image-ExifTool
    poppler-utils
    pdfgrep
)

# RPM Fusion (third-party repo - conflicts with lib*-free, needs
# --allowerasing in install loop)
PKGS_FUSION=(
    ffmpeg
)

# Optical disc handling (RAW/subchannel reads)
PKGS_OPTICAL=(
    cdrdao
    cuetools
)

# Password recovery
PKGS_PWCRACK=(
    john
    hashcat
)

# Malware triage (definitions in /var, post-deploy)
PKGS_MALWARE=(
    clamav
)

# OCI / cloud
PKGS_CLOUD=(
    skopeo
    rclone
)

# Database clients
PKGS_DB=(
    mariadb
    postgresql
    sqlite
)

# Fuzzy hashing (hashdeep absent from Fedora; ssdeep + sha256sum
# manifest workflow covers exact hashing)
PKGS_HASH=(
    ssdeep
)

# Large-image acquisition plumbing
PKGS_BIGIMAGE=(
    pigz
    pbzip2
    miller
)

# Mobile device access
PKGS_MOBILE=(
    android-tools
    libimobiledevice-utils
)

# Windows execution for native RE
PKGS_WINDOWS=(
    wine
    mono-core
)

# Plumbing (includes pipx C-extension build deps)
PKGS_PLUMBING=(
    xorg-x11-xauth
    java-25-openjdk
    unzip
    curl
    pipx
    python3-devel
)

# COPR additions (third-party - conflicts with Fedora libewf, needs
# --allowerasing in install loop)
PKGS_COPR=(
    plaso-tools
)

### ------------------------------------------------------------------
### Repo setup - only unguarded installs; enables asserted below
### ------------------------------------------------------------------

dnf5 install -y dnf5-plugins

# RPM Fusion (absent from the ucore build container)
FEDORA_VERSION="$(rpm -E %fedora)"
curl -fL -o /tmp/rpmfusion-free.rpm \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm"
curl -fL -o /tmp/rpmfusion-nonfree.rpm \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm"
dnf5 install -y /tmp/rpmfusion-free.rpm /tmp/rpmfusion-nonfree.rpm
rm -f /tmp/rpmfusion-free.rpm /tmp/rpmfusion-nonfree.rpm

# GIFT COPR for plaso
dnf5 -y copr enable @gift/stable
dnf5 makecache

# Assertions - exit codes lie, repolists don't
if ! dnf5 repolist | grep -qi "gift"; then
    echo "FATAL: GIFT COPR missing from repolist after enable"
    exit 1
fi
if ! dnf5 repolist | grep -qi "rpmfusion-free"; then
    echo "FATAL: RPM Fusion free missing from repolist after enable"
    exit 1
fi

### ------------------------------------------------------------------
### Verification pass - name every missing package before installing
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
    "${PKGS_FUSION[@]}"
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
    echo "Enabled repos:"
    dnf5 repolist
    exit 1
fi

### ------------------------------------------------------------------
### Install
### ------------------------------------------------------------------

for group in NETWORK ARCHIVE BINARY TOOLCHAIN OBSERVE EMULATE DISK \
             STORAGE HARDWARE WINARTIFACT NETFORENSICS MEDIA FUSION \
             OPTICAL PWCRACK MALWARE CLOUD DB HASH BIGIMAGE MOBILE \
             WINDOWS PLUMBING COPR; do
    declare -n pkgs="PKGS_${group}"
    echo ">>> Installing group: ${group} (${#pkgs[@]} packages)"

    # Third-party groups replace Fedora counterparts; allow the swap
    if [[ "${group}" == "FUSION" || "${group}" == "COPR" ]]; then
        dnf5 install -y --allowerasing "${pkgs[@]}"
    else
        dnf5 install -y "${pkgs[@]}"
    fi
    unset -n pkgs
done

### -------------------------------------------------------------------
### Ghidra - pinned release, checksum-verified
# /usr/lib, not /opt: on ostree/bootc, /opt symlinks into /var and
# is machine-local state, not carried in the image.
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
### jadx - parked pending release checksum (see run 1 triage log)
### -------------------------------------------------------------------

# JADX_VERSION="1.5.6"
# JADX_URL="https://github.com/skylot/jadx/releases/download/v${JADX_VERSION}/jadx-${JADX_VERSION}.zip"
# JADX_SHA256="fill from release page before enabling"
#
# curl -fL -o /tmp/jadx.zip "${JADX_URL}"
# echo "${JADX_SHA256}  /tmp/jadx.zip" | sha256sum --check --strict
# unzip -q /tmp/jadx.zip -d /usr/lib/jadx
# ln -sf /usr/lib/jadx/bin/jadx /usr/bin/jadx
# ln -sf /usr/lib/jadx/bin/jadx-gui /usr/bin/jadx-gui
# rm -f /tmp/jadx.zip

### -------------------------------------------------------------------
### apktool - parked pending release checksum (see run 1 triage log)
### -------------------------------------------------------------------

# APKTOOL_VERSION="3.0.0"
# APKTOOL_URL="https://github.com/iBotPeaches/Apktool/releases/download/v${APKTOOL_VERSION}/apktool_${APKTOOL_VERSION}.jar"
# APKTOOL_SHA256="fill from release page before enabling"
#
# curl -fL -o /usr/lib/java/apktool.jar "${APKTOOL_URL}"
# echo "${APKTOOL_SHA256}  /usr/lib/java/apktool.jar" | sha256sum --check --strict
# cat > /usr/bin/apktool <<'EOF'
# #!/bin/sh
# exec java -jar /usr/lib/java/apktool.jar "$@"
# EOF
# chmod +x /usr/bin/apktool

### -------------------------------------------------------------------
### Python tooling via pipx - gated, failures collected and reported
# /usr (not ~/.local): /root is machine-local state on bootc, not
# carried in the image.
# Names are PyPI distribution names, which often differ from the
# installed command (e.g. uefi-firmware installs uefi-firmware-parser).
### -------------------------------------------------------------------

export PIPX_HOME=/usr/lib/pipx
export PIPX_BIN_DIR=/usr/bin

PIPX_TOOLS=(
    frida-tools        # dynamic instrumentation
    volatility3        # memory dump analysis
    oletools           # OLE/office macro inspection
    mitmproxy          # HTTPS interception
    pwntools           # exploit dev
    androguard         # APK static analysis
    regipy             # registry hive parsing
    uefi-firmware      # UEFI/ME/Dell firmware parsing
    jefferson          # JFFS2 extraction
    ubi_reader         # UBI/UBIFS extraction
    urh                # SDR signal inspection
    awscli             # cloud inspection
    sqlmap             # SQL injection (offense)
    impacket           # AD post-exploitation (offense)
    responder          # LLMNR/NBT-NS poisoning (offense)
    # angr             # symbolic execution; enable on demand
)

PIPX_FAILED=()
for tool in "${PIPX_TOOLS[@]}"; do
    echo ">>> pipx: ${tool}"
    if ! pipx install "${tool}"; then
        PIPX_FAILED+=("${tool}")
    fi
done

if ((${#PIPX_FAILED[@]} > 0)); then
    echo "================================================================"
    echo "PIPX TRIAGE REPORT - failed installs:"
    echo "================================================================"
    for tool in "${PIPX_FAILED[@]}"; do
        echo "  FAILED: ${tool}"
    done
    echo ""
    echo "Per-tool pip logs: /usr/lib/pipx/logs/cmd_*_pip_errors.log"
    exit 1
fi

### -------------------------------------------------------------------
### DEFERRED:
#   data layer (/var, manifest-verified): yara rules, NSRL, clamav
#   defs, volatility symbols, suricata rules, wordlists
#   pinned-release candidates: jadx, apktool, UEFITool, bettercap,
#   chdman, sasquatch
#   distrobox: metasploit, dotnet SDKs
# REMOVED (see triage log): scrcpy, hashdeep, zeek (OBS-only)
### -------------------------------------------------------------------