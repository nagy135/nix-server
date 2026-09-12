#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
if [[ $(uname -s) != Linux || $EUID -ne 0 || ! -d /run/current-system/sw ]]; then
  echo "Run this check as root on a NixOS machine." >&2
  exit 1
fi

network_script=$(mktemp /tmp/hetzner-network-check.XXXXXX)
trap 'rm -f "$network_script"' EXIT
nix eval --raw --no-write-lock-file \
  .#nixosConfigurations.hetzner.config.systemd.services.network-addresses-eth0.script \
  > "$network_script"

# Resolve /run/current-system before replacing /run inside the private mount
# namespace. Neither the host's interfaces nor its network state files change.
network_test_bin="$(readlink -f /run/current-system/sw)/bin"
export PATH="$network_test_bin:$PATH"
unshare --mount --net --fork --propagation private \
  "$network_test_bin/bash" --noprofile --norc -ec '
    mount -t tmpfs -o mode=755 tmpfs /run
    ip link add eth0 type dummy
    sysctl -qw net.ipv6.conf.all.disable_ipv6=1
    bash --noprofile --norc -e "$1"
    ip -4 route show default | grep -F "default via 172.31.1.1 dev eth0"
    ip -4 route get 1.1.1.1
  ' check-hetzner-network "$network_script"

echo "Hetzner IPv4 routing passed in an isolated network namespace."
