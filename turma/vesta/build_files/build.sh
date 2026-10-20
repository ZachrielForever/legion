#!/bin/bash

# ==============================================================================
# legion vesta - private (tailnet-only) web/file server
#
# Caddy with an internal CA for tailnet HTTPS. No fail2ban, no auditd:
# this node never sees the public internet, so intrusion response and
# forensic trails are noise. Hardening is lumen's job.
# ==============================================================================

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Web/file server (internal CA for tailnet TLS)
dnf5 install -y \
    caddy

### Services

systemctl enable caddy