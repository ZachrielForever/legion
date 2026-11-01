# Lumen — public WAN web/file server (bastion)

Turma-line node. The fleet's sacrificial front door.

Lumen is the only node the internet can touch. It serves web and file
downloads to the public, holds nothing precious, trusts nobody, and
fails closed. Everything about its build is shaped by one constraint:
it is reachable by everyone, so it gets to contain almost nothing.

## What's inside

Intentionally minimal. If a package has no justification for existing
on an internet-exposed box, it isn't there — no development tooling,
nothing that compiles an exploit, nothing beyond what the public
service and its defense require.

### Serving

Caddy (Fedora package) with automatic HTTPS via ACME, serving static
files from `/srv/public`. The initial deployment serves a placeholder
until a domain is acquired; the production Caddyfile block is staged
and commented in-tree.

### Intrusion response

fail2ban, with a custom Caddy jail watching the systemd journal for
401/403 events from the Caddy access log — bans repeat offenders on
80/443, not just SSH. Auditd provides the audit trail with baseline
rules shipped in-image.

### Access control

Nothing here is complicated on purpose:

- **Firewall** — the WAN-visible zone allows http/https and nothing
  else. A second source-bound zone grants SSH to the tailnet range
  (`100.64.0.0/10`) only.
- **SSH** — one user, keys only, no passwords, no root login.
  Tailnet-only enforcement lives in the firewall zone, not sshd —
  sshd cannot bind a CIDR, and a literal node IP does not belong in
  a fleet image.
- **Logging** — structured JSON access logs feed the fail2ban jail;
  auditd covers system-level events.

## Defense posture

Lumen inverts the fleet's usual maximization: where other nodes bake
in every tool plausibly relevant to the role, Lumen excludes
everything not strictly required by it. The attack surface is the
deliverable. Layered defenses — firewall zone separation, keys-only
SSH, fail2ban on the public service, audit rules — exist so that a
compromise of the web tier does not become a foothold in the fleet.

Public-facing applications with heavy attack surfaces (ticketing,
databases, user input processing) do not live here. They run on
internal nodes and are fronted by Lumen's reverse proxy when public
reach is needed — a breach lands on an internal, unexposed host
rather than the bastion itself.

## Planned

- Domain acquisition and ACME provisioning (production Caddyfile
  block, uncommented and populated)
- Reverse proxy entries for internal services requiring public reach
- Log shipping to Vigil once that node is stood up
- Ticketing system (candidate: Zammad) hosted internally, fronted
  here