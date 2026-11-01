# Talos — Forgejo, CI runner, container registry

Turma-line node. The fleet's source of truth and supply chain.

Talos hosts the Git hosting, continuous integration, and private
container registry for legion. Every signed image in the fleet
passes through Talos at some point — either as a source repository
or as a destination after signing. The fleet's provenance lives
here.

## What's inside

**Forgejo** — self-hosted Git hosting, the upstream that forks
Gitea. Contains the fleet's repositories, issue trackers, and
documentation.

**Drone CI** — the CI runner that executes builds and pushes
signed images to GHCR. The `build-*` workflows in the legion
repo run on Talos's runners.

**Registry** — private container registry for the fleet's
internal images (distrobox bases, staging builds, anything not
pushed to public registries). Signed by cosign, stored here.

## Supply chain position

Talos occupies the center of the fleet's signing graph:

GitHub (source) → Talos (build + sign) → GHCR (public) ↓ legion fleet (verify)

The signed image's cosign signature chains back to Talos's
identity. A build that doesn't pass through Talos's pipeline
isn't considered part of the fleet policy.

## Planned

- Mirrored backups of Forgejo data (to Horreum or external)
- Registry cleanup policies (garbage collection, retention)
- Runner scaling for concurrent builds
- Migration plan if Talos hardware needs replacement