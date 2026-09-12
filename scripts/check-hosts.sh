#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

for host in hetzner nixpi nixzero; do
  printf 'Evaluating %s...\n' "$host"
  nix eval --raw --no-write-lock-file \
    ".#nixosConfigurations.$host.config.system.build.toplevel.drvPath"
  printf '\n'
done

printf 'Evaluating nixzero SD image...\n'
nix eval --raw --no-write-lock-file \
  .#nixosConfigurations.nixzero.config.system.build.sdImage.drvPath
printf '\nAll host derivations evaluated; no systems built or activated.\n'
