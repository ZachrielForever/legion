# lorica: fleet QOL — fish side

function drez
    kbuildsycoca6 --noincremental >/dev/null 2>&1
    and systemctl --user restart plasma-plasmashell.service
    echo "plasma reset. compositor-level artifacts still need a re-login."
end

function fleet
    echo "── tailnet ─────────────────────"
    tailscale status 2>/dev/null | grep -v '^#' | head -15
    echo ""
    echo "── probes ──────────────────────"
    for node in helius dominus
        if tailscale ping -c 1 --timeout 3s $node >/dev/null 2>&1
            echo "  $node: reachable"
        else
            echo "  $node: no response"
        end
    end
    echo ""
    echo "── game fleet (dominus) ────────"
    ssh -o ConnectTimeout=5 dominus \
        'systemctl --user list-units --type=service --all --no-pager --plain' \
        2>/dev/null | grep -Ei 'openra|q[23]|quake|tribes|ut(99|2004)'
        or echo "  (ssh to dominus failed)"
end

alias dev='distrobox-enter dev'
alias dotnet='distrobox-enter dotnet'