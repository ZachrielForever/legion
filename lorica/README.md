# Lorica

Travel node — the sister to aegis. A portable dev and productivity
image for the fleet's ThinkPad: SSH to the fleet from anywhere,
light development in distroboxes, and couch gaming up to the FFXIV
tier. Connected to the tailnet at all times.

## Built off of

[bazzite](https://bazzite.gg) (KDE) by the Universal Blue project —
upstream provides the desktop, gaming stack, and Homebrew. Lorica
is a thin mask: identity, a CLI kit, and a tailscale uplink.

## What's in the image

- **Fleet identity** — image-info declares `lorica` so fastfetch
  and rpm-ostree status show the node, not upstream.
- **CLI kit** — fzf, ncdu, lazygit, atuin, tree, mtr, bind-utils,
  jq, yq, 7zip, unzip, playerctl, tcpdump. The everyday toolset,
  repo-confirmed packages only. (xh ships via brew instead — not
  in official repos.)
- **Tailscale quadlet** — rootful tailscaled with a published UDP
  41641 for direct connections. Persistent state volume; auth
  survives reboots.
- **`ujust lorica-setup`** — first-boot recipe: VSCodium via the
  ublue tap, Floorp and OnlyOffice flatpaks, and two general
  distroboxes (dev: Fedora+Python, dotnet: .NET 10 LTS).

## Branches

`stable`, `testing`, and `unstable` mirror upstream bazzite's
channels, built from the same Containerfile.