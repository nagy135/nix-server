#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
builder="${NIXZERO_BUILDER:-root@nixpi.tail6650cb.ts.net}"
image_name=nixos-nixzero-aarch64-linux.img

# Evaluate this working tree on the Mac; Nix transfers only the derivation's
# inputs to the ARM64 builder. No remote checkout or deployed system changes.
image_output=$(nix build \
  --eval-store auto \
  --store "ssh-ng://$builder" \
  .#nixosConfigurations.nixzero.config.system.build.sdImage \
  --no-link --print-out-paths)

mkdir -p artifacts
scp "$builder:$image_output/sd-image/$image_name" "artifacts/$image_name.partial"
mv "artifacts/$image_name.partial" "artifacts/$image_name"
shasum -a 256 "artifacts/$image_name" > "artifacts/$image_name.sha256"
printf 'Image ready: %s/artifacts/%s\n' "$PWD" "$image_name"
