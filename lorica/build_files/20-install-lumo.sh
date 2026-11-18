#!/usr/bin/env bash
# lorica: bake the Lumo desktop app (first-party RPM, checksum-pinned).
# Version/url/hash live in /ctx/lumo.conf, updated by the lumo watcher.
set -euo pipefail

CONF="/ctx/lumo.conf"
# Sourced from /ctx inside the build container; the repo-relative
# path cannot be resolved at lint time, so suppress the follow hint.
# shellcheck source=/dev/null disable=SC1091
source "${CONF}"

: "${LUMO_RPM_URL:?LUMO_RPM_URL unset}"
: "${LUMO_SHA512:?LUMO_SHA512 unset}"

RPM_PATH="/tmp/lumo.rpm"
curl -fsL -o "${RPM_PATH}" "${LUMO_RPM_URL}"

# First-party verification: proton.me publishes SHA512 per release in
# version.json; the conf pins the value the build was vetted against.
echo "${LUMO_SHA512}  ${RPM_PATH}" | sha512sum --check --strict

dnf5 -y install "${RPM_PATH}"
rm -f "${RPM_PATH}"

# Confirm the image contains the pinned release
rpm -q lumo
