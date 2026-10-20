# Legion

Custom [uCore](https://projectucore.org)-derived OS images for the home rack fleet.

One base image, many purpose-built variants. Every rack node runs an image
built for its role — nothing more, nothing less.

## Lineage

ghcr.io/ublue-os/ucore:stable upstream base │ ▼ ghcr.io/ZachrielForever/legion:stable this repo — fleet policy │ ├── janus public WAN web/file (bastion) ├── vesta private web/file ├── orpheus private media ├── hephaestus dev server ├── heimdall toolbox: monitoring, DNS, network services ├── talos forgejo, CI runner, container registry ├── yggdrasil NAS └── mnemosyne emulation dock

ghcr.io/ublue-os/ucore:stable-nvidia-lts separate lineage │ ▼ dominus game servers (GTX 1060)

## The fleet

| Node | Role | Image |
|---|---|---|
| Helius | primary workstation / build host | Bazzite |
| Dominus | game server fleet | dominus |
| Aegis | macOS host | — |
| Thaumiel | Android rescue device | — |
| Lumen | public WAN web/file | lumen |
| Vesta | private web/file | vesta |
| Vox | private media | vox |
| Solutio | dev server | solutio *(planned)* |
| Vigil | monitoring, DNS, network | vigil |
| Talos | forgejo, runner, registry | talos *(planned)* |
| Horreum | NAS | horreum |
| Memoria | emulation dock | memoria *(planned)* |

## What's in the base

Fleet policy only — what is true of *every* node:

- Tailscale (tailnet membership, enrollment persisted in `/var`)
- Hardened SSH posture (keys only, no root login)
- Interactive tooling: fish, micro, btop, fastfetch, tmux, git, jq, yq
- Triage diagnostics: ethtool, iotop, lsof, mtr, strace, sysstat, bind-utils
- Transfer and verification: rsync, pv, lz4, xz, zstd

Hardware specifics live in derived images. Role packages live in role variants.

## Building

Local build:

just build

Disk images for provisioning (ISO / qcow2 / raw):

just build-iso just build-qcow2 just build-raw

CI builds and pushes on every push to `main` via GitHub Actions.

## Credits

Built on the shoulders of:

- **[uCore](https://projectucore.org)** — Fedora CoreOS-based server images with batteries included
- **[Universal Blue](https://universal-blue.org)** — the image manufacturing process this all rests on
- **[ublue-os/image-template](https://github.com/ublue-os/image-template)** — the build skeleton this repo derives from

Licensed Apache-2.0, inherited from the template.