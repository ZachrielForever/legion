# Solutio — reverse engineering / forensics inspector

Turma-line node. Mission statement: **if it exists, it can be decompiled
and inspected.**

Solutio is the fleet's inspector box. Anything thrown at it — software
binaries, disk images, network captures, firmware, phones, hardware —
should find the right tool for extraction, analysis, or observation
already present on the node. Tailnet-only; it exposes nothing.

## What's inside

The image is intentionally fat: every tool plausibly relevant to the
node's task gets baked in, subject to the repo-wide
[security tiers](../../README.md#security-tiers).

### Extraction and archives

If data can be extracted from it, it's supported — including legacy and
obscure formats: 7z/RAR/ARJ/LHA/XAR, CD/DVD images, MSI/CAB/InnoSetup
installers, InstallShield archives, SquashFS, optical media (cdrdao),
and UEFI capsules.

### Binary analysis

Radare2, Ghidra (pinned release), and the LLVM/GCC toolchains for
rebuilding what gets torn apart. Binwalk for embedded payloads, file
magic, hex editors for hands-on work.

### Mobile

jadx (pinned) and apktool (pinned) for Android reversing, backed by
androguard. android-tools (adb/fastboot) and libimobiledevice for iOS
extraction.

### Disk and volume forensics

Sleuth Kit, testdisk, ddrescue, qemu-img, guestfs-tools for VM disks,
EWF for EnCase images, and the LVM/RAID/cryptsetup/dislocker stack for
anything that holds its volumes behind a layer.

### Windows artifacts

hivex (registry), libpst (Outlook), innoextract, samba-client, plus
wine and mono for executing Windows payloads in containment.

### Network

tcpdump, Wireshark, nmap, and bettercap (pinned) for active
reconnaissance. Suricata for protocol reconstruction from captures.

### Hardware

Serial and console access (minicom, picocom, screen), flashrom and
openocd for chip-level work, i2c-tools and can-utils for buses,
sigrok and rtl-sdr for test equipment and RF. The hardware tier assumes
USB adapters — this is the box you walk up to with a bricked device.

### Emulation

QEMU (system and user-mode) and dosbox-staging to execute legacy
payloads in containment — WinXP-era and earlier is in scope.

### Supporting cast

Media/container identification (ffmpeg, exiftool, mediainfo), password
recovery (john, hashcat, ssdeep fuzzy hashing), ClamAV for triage,
SQLite/PostgreSQL/MariaDB clients for dumped databases, cloud tooling
(skopeo, rclone, awscli) for examining container and bucket artifacts,
and sqlmap/mitmproxy for web target inspection.

## Pinned releases

Tools without acceptable distro packaging are pinned to tagged GitHub
releases and checksum-verified (`sha256sum --check --strict`) at build
time. Current pins:

| Tool                | Version | Role                                |
| ------------------- | ------- | ----------------------------------- |
| Ghidra              | 12.1.4  | disassembler / decompiler           |
| jadx                | 1.5.6   | DEX → Java decompiler               |
| apktool             | 3.0.3   | APK resource/smali unpacking         |
| UEFIExtract/UEFIFind | A75    | UEFI firmware parsing and search    |
| bettercap           | 2.41.7  | network MITM / recon framework       |

## Data layer

Definitions and rule sets (ClamAV signatures, YARA rules, symbol
tables, wordlists) are **not** baked in. A manifest-driven fetcher
(`/usr/lib/solutio/fetch-data.sh`, daily systemd timer) pulls them
post-deploy into `/var`, sha256-verified per item. Tools live in the
image; DATA does not.

## Quarantine

Tooling that can't meet the signing bar runs in separate distrobox
images, built and signed independently:

- **solutio-offense** — metasploit, netexec, impacket, responder
- **solutio-dotnet** — .NET SDKs for managed-code analysis