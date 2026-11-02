# Helius — daily driver / fleet orchestrator

Standalone legion node, sole member of the Bazzite lineage. Helius is
the workstation everything else is operated *from*: most work stays
node-based and streams to Helius over SSH and tailscale. It holds no
services, no data duties, and no specialized tooling — it's the
terminal in front of the fleet.

This image is a thin mask over upstream `bazzite-dx-nvidia`. It exists
to put the fleet's name in `rpm-ostree status`, provide a controlled
rebase target independent of upstream tag churn, and reserve the seam
where fleet-specific configuration would live if ever needed. It adds
nothing — deliberate, inspected, and doctrine.

## Built off of bazzite-dx-nvidia

Upstream DX layer (Bazzite, Universal Blue) provides:

- KDE Plasma desktop with NVIDIA open kernel modules (Ampere+)
- Docker CE, podman tooling (podman-tui, podman-machine)
- VS Code (Microsoft build) with devcontainer and remote-SSH extensions
- Virtualization stack: QEMU, libvirt, virt-manager, OVMF, guestfs
- Waypipe for streaming graphical apps from containers
- restic and rclone for backup operations
- Homebrew CLI package management
- ROCm compute stack (inert on this node's NVIDIA hardware)
- ujust recipes for VM/container management

## Doctrine

Helius mutates upstream as little as possible. Improvements to the
DX layer belong upstream (`ublue-os/bazzite-dx`), not in a fork here.
Personal runtime adjustments live in `/etc` on the node, never in
the image. Packages are added on dire need only — everything else
is reachable by SSH to the node that owns it.

Workloads that outgrow Helius migrate to purpose-built nodes
(Dominus for game servers, Solutio for analysis, Horreum for storage)
without Helius accumulating their tools on the way out.

## Planned

- Nothing, presently — that's the point