# Legion

Custom OS images for the home rack fleet.

One base image, many purpose-built variants. Every rack node runs an image
built for its role — nothing more, nothing less.

> [!IMPORTANT]
> This repository is a **personal project**, maintained for a private
> home lab. It is **not affiliated with, endorsed by, or related to the
> Universal Blue team, organization, or community** in any way. Universal
> Blue's excellent work is used as a foundation — please don't bring
> legion's problems to them.

## The fleet

Two lines, split by chassis class. **Turma** is the mini PC fleet —
compact nodes for services. **Instrumentum** is the full-size fleet —
machines with room for discrete GPUs and heavier duties.

### Turma — mini PC line

| Node    | Role                                       | Image     |
| ------- | ------------------------------------------ | --------- |
| Lumen   | public WAN web/file (bastion)              | lumen     |
| Vesta   | private web/file                           | vesta     |
| Solutio | reverse engineering / forensics inspector | solutio   |
| Vigil   | monitoring, DNS, network services          | vigil     |
| Talos   | Forgejo, CI runner, container registry     | talos     |
| Vox     | private media server                       | vox       |

### Instrumentum — full PC line

| Node    | Role              | Image   |
| ------- | ----------------- | ------- |
| Dominus | game server fleet | dominus |
| Horreum | NAS               | horreum |
| Memoria | emulation dock    | memoria *(planned)* |

### Beyond the rack

Hosts that run outside the legion image system:

| Node     | Role                             |
| -------- | -------------------------------- |
| Helius   | primary workstation / build host  |
| Aegis    | macOS host                       |
| Thaumiel | Android rescue device            |

## Lineage

TBD — Dominus and Helius images are planned additions to the fleet,
with everything kept under one roof. Diagram to come once the full
roster is settled.

## Security tiers

Not everything belongs in a signed image. Three tiers, by trust boundary:

**Signed image** — role tooling, pinned and checksum-verified.
Everything a node needs to do its job ships inside the image, including
third-party tools pinned to tagged releases and verified with
`sha256sum --check --strict` at build time.

**Data layer** (`/var`) — rule sets, definitions, hash databases, and
wordlists are fetched post-deploy by manifest, verified, and atomically
installed. Tools live in the image; DATA does not.

**Quarantine boxes** — tooling whose upstream can't meet the signing bar
(unofficial repos, source-only builds) runs in disposable distrobox
images, built and signed separately from the host image.

## Built off of

This project would not exist without the work of the teams below. Their
images are pulled and built upon directly, per the inheritance chain of
each variant — full credit for the foundations belongs to them:

- **[Universal Blue](https://universal-blue.org/)** — the image
  manufacturing process, tooling, and CI patterns this entire repo is
  built on. The `ublue-os/image-template` is the direct skeleton from
  which legion derives its structure.
- **[uCore](https://projectucore.org)** — the Fedora CoreOS-based
  server images that serve as the upstream base for the turma lineage.
  Server-oriented conveniences, bootc conventions, and the sane defaults
  all originate there.
- **[Bazzite](https://bazzite.gg/)** — the gaming-focused images
  standard for the workstation and emulation side of the fleet. Helius
  runs it today, and the planned Memoria image leans on its lineage.

Any bugs introduced on top of those foundations are legion's own.

Licensed Apache-2.0, inherited from the template.