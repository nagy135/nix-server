{
  config,
  lib,
  pkgs,
  ...
}: {
  # Refresh both extlinux and the headless U-Boot environment on every switch,
  # boot action, and rollback. The selected generation is passed by NixOS.
  system.build.installBootLoader = lib.mkForce (pkgs.writeShellScript "install-nixzero-boot" ''
    set -euo pipefail
    export PATH=${lib.makeBinPath [pkgs.coreutils pkgs.util-linux pkgs.ubootTools]}
    system="$1"
    mountpoint -q /boot/firmware
    ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c "$system" -d /boot
    temporary=$(mktemp -d /boot/firmware/.nixzero-update.XXXXXX)
    trap 'rm -rf "$temporary"' EXIT
    ${pkgs.python3}/bin/python3 ${../scripts/prepare-nixzero-diagnostics.py} \
      --script ${../scripts/nixzero-boot.cmd} \
      --extlinux /boot/extlinux/extlinux.conf \
      --initrd "$system/initrd" --output "$temporary/bundle"
    sync
    # Publish the environment last, after its script and initrd are in place.
    for name in nixzero-initrd nixzero-boot.scr uboot.env; do
      mv -f "$temporary/bundle/$name" "/boot/firmware/$name"
    done
    sync
  '');
}
