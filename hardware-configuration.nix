{modulesPath, ...}: {
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  boot.zfs.forceImportRoot = false;

  hardware.raspberry-pi.firmware = {
    enable = true;
    uboot.enable = true;
  };
}
