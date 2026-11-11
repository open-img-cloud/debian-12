#!/usr/bin/env bash
# Customize hook called by the build-libguestfs-image reusable workflow.
# Receives the qcow2 path as $1.
#
# The upstream Debian 12 cloud image already ships cloud-init,
# openssh-server, a serial console (console=ttyS0) and the `debian`
# default user. The org-wide cloud-init policy drop-in (datasource_list,
# disable_root, ssh_pwauth=false, mount_default_fields) is injected by the
# reusable workflow after this script runs. Here we only add
# qemu-guest-agent (started by udev when the virtio-serial channel exists,
# so there is nothing to enable) and drop the apt caches.

set -euo pipefail

QCOW2="${1:?usage: customize.sh <path-to-qcow2>}"

if [[ ! -f "$QCOW2" ]]; then
  echo "::error::qcow2 not found: $QCOW2" >&2
  exit 1
fi

echo "[customize] target: $QCOW2"

virt-customize -a "$QCOW2" \
  --run-command 'export DEBIAN_FRONTEND=noninteractive; apt-get update -q && apt-get install -y -q --no-install-recommends qemu-guest-agent' \
  --run-command 'apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*'

echo "[customize] done"
