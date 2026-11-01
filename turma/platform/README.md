# Platform — turma shared base

Not a node. The common ancestor every turma-line image builds from.

Platform exists so the fleet's mini PC nodes don't each re-derive the
same foundations. One layer carries what is true of the whole line;
node variants stay purely additive. Any package present in every
turma node belongs here, exactly once. Anything node-specific does
not belong here, ever.

## What's inside

Deliberately minimal, and kept that way on principle.

**Firmware servicing** — fwupd, so every node in the line can
receive and apply firmware updates uniformly. Display and peripheral
enablement arrive via the kernel and linux-firmware already present
in uCore — verified on first boot, not duplicated here.

**Fleet policy** — the `system_files` baseline applied to every
mini PC node.

## Doctrine

This layer grows only from observed behavior on real hardware. A
package earns its place after a node demonstrated the need — never
in advance of one. The default answer to "should platform include
X" is no until a boot log says otherwise.

## Position

```
ghcr.io/ublue-os/ucore:stable
        │
        ├── solutio              builds direct — supply chain
        │                        independence for the one node
        │                        with offensive tooling
        ▼
l-turma:platform                 this layer — fleet policy + fwupd
        │
        ├── lumen      (bastion)
        ├── vesta      (private web/file)
        ├── vigil      (monitoring, DNS, network)
        ├── talos      (forgejo, CI, registry)
        └── vox        (media)
```