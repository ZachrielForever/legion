#!/usr/bin/env bash
# lorica: core CLI kit. Personal toolset, repo-confirmed packages only.
set -euo pipefail

PKGS=(
    fzf
    ncdu
    bind-utils
    mtr
    tree
    unzip
    7zip
    jq
    yq
    playerctl
    tcpdump
    lazygit
    atuin
    fish
    papirus-icon-theme
    # xh: not in official F45 repos — installed via brew in lorica-setup
)

dnf5 -y install "${PKGS[@]}"