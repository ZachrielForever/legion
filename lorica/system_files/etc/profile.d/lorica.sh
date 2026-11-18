# lorica: fleet QOL — bash side (fish twins in /etc/fish/conf.d/lorica.fish)

drez() {
    # rebuild KDE service/icon caches, bounce plasmashell in place
    kbuildsycoca6 --noincremental >/dev/null 2>&1
    systemctl --user restart plasma-plasmashell.service
    echo "plasma reset. compositor-level artifacts still need a re-login."
}

fleet() {
    echo "── tailnet ─────────────────────"
    tailscale status 2>/dev/null | grep -v '^#' | head -15
    echo ""
    echo "── probes ──────────────────────"
    local node
    for node in helius dominus; do
        if tailscale ping -c 1 --timeout 3s "$node" >/dev/null 2>&1; then
            echo "  ${node}: reachable"
        else
            echo "  ${node}: no response"
        fi
    done
    echo ""
    echo "── game fleet (dominus) ────────"
    ssh -o ConnectTimeout=5 dominus \
        'systemctl --user list-units --type=service --all --no-pager --plain' \
        2>/dev/null | grep -Ei 'openra|q[23]|quake|tribes|ut(99|2004)' \
        || echo "  (ssh to dominus failed)"
}

# box entry shortcuts: host shell owns these names; inside the box
# the real binaries take over (box shells don't load host profile.d)
alias dev='distrobox-enter dev'
alias dotnet='distrobox-enter dotnet'