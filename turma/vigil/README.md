# Vigil — monitoring, DNS, network services

Turma-line node. The fleet's observability backbone.

Vigil hosts what the fleet needs to talk to itself and to
report on its own health. No external-facing ports; all traffic
rides the tailnet. Its role expands as the fleet grows, but the
foundation is already in place: visibility into the nodes that
serve the outside world.

## What's inside

**DNS** — internal name resolution for the fleet's MagicDNS
suffix. The tailnet provides the overlay; Vigil handles the
forwarding and caching for service discovery.

**Monitoring** — Prometheus/Grafana stack (or similar) for
metrics collection and dashboards. The fleet's status lives
here, not in scattered logs on individual nodes.

**Log aggregation** — centralized log shipping from Lumen's
fail2ban and audit trails, Solutio's forensic runs, and
eventually the rest of the line. Logs die with the bastion
if they stay on the bastion; Vigil is the sink.

**Alerting** — notification hooks when metrics cross
thresholds or security events fire. The fleet doesn't sleep;
the monitoring should wake someone when it needs to.

## Position in the fleet

Vigil is the dependency chain's bottom: every other node ships
its telemetry upward. It has no inbound dependencies on the
nodes it watches. If Vigil fails, the fleet keeps working; it
just stops telling you about itself.

## Planned

- Full metrics pipeline (Prometheus exporters on each node)
- Grafana dashboard templates for fleet-wide visibility
- Alert rules for security events (failed logins, ban events)
- Backup and restore procedure for the monitoring state