# Vesta — private web/file server

Turma-line node. Fleet-internal counterpart to Lumen.

Vesta mirrors Lumen's Caddy-based serving but stays off the public
internet. It serves web and file sharing behind the tailnet
boundary — no ACME, no WAN-facing ports, just authenticated
access for the fleet. Where Lumen is a sacrificial front door,
Vesta is the internal pantry.

## What's inside

Same serving stack as Lumen, without the WAN exposure:

**Caddy** — Fedora package, no automatic HTTPS. Traffic rides
over the tailnet so TLS termination happens there if desired;
for now it serves plaintext on internal addresses only.

**Access control** — no public firewall zone. Authentication
happens at the application layer (basicauth in Caddyfile, or
reverse-proxying to an auth-capable backend) rather than network
topology.

## Difference from Lumen

Lumen and Vesta share the same base (l-turma:platform) and the
same Caddy core. Lumen carries the fail2ban jail and public zone
config; Vesta carries neither. The separation is explicit:
public-facing security stays with the bastion; private sharing
relies on tailnet isolation.

## Planned

- Internal file-sharing use cases (team assets, shared docs)
- Basicauth user accounts for shared resources
- Integration with Zammad or similar if authentication gets
  centralized later