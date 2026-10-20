#!/bin/bash

# ==============================================================================
# legion lumen - public WAN web/file server
#
# Hardened bastion: Caddy with automatic HTTPS, fail2ban, auditd.
# Deliberately NO development tooling - nothing that compiles an
# exploit belongs on a publicly-exposed node.
# ==============================================================================

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Web/file server
dnf5 install -y \
    caddy

# Intrusion response
dnf5 install -y \
    fail2ban \
    fail2ban-firewalld

# Auditing
dnf5 install -y \
    audit

### Services

# Caddy web server (TCP 80/443)
systemctl enable caddy

# fail2ban watching auth logs
systemctl enable fail2ban

# Audit trail
systemctl enable auditd