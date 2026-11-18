# lorica: first-boot setup — flatpaks, vscodium, general devboxes
lorica-setup:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "=== Trusting ublue tap ==="
    brew trust ublue-os/tap

    echo "=== VSCodium (via ublue tap) ==="
    brew install --cask ublue-os/tap/vscodium-linux

    echo "=== CLI extras via brew (xh not in official repos) ==="
    brew install xh

    echo "=== Flatpaks: Floorp, OnlyOffice ==="
    flatpak install -y flathub one.ablaze.floorp
    flatpak install -y flathub org.onlyoffice.desktopeditors

    echo "=== Distrobox: general devbox (Fedora + Python) ==="
    distrobox create --yes --name dev --image registry.fedoraproject.org/fedora-toolbox:45
    distrobox run dev -- bash -c 'dnf -y install python3 python3-pip git'

    echo "=== Distrobox: general dotnet box (.NET 10 LTS current) ==="
    distrobox create --yes --name dotnet --image registry.fedoraproject.org/fedora-toolbox:45
    distrobox run dotnet -- bash -c 'dnf -y install dotnet-sdk-10.0'
    # .NET 8 went EOL Nov 10, 2026. If genuine 8.0 runtime needed:
    # distrobox run dotnet -- bash -c 'dnf -y install dotnet-sdk-8.0'

    echo "Done. Reboot or re-login for flatpak menus, then:"
    echo "  sudo podman exec tailscaled tailscale up   # join the tailnet"
