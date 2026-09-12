{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  sshKeys = import ../../modules/ssh-keys.nix;
in {
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
    (modulesPath + "/profiles/minimal.nix")
    ../../modules/nixzero-boot-diagnostics.nix
    ../../modules/nixzero-updates.nix
  ];

  # The generic image supplies Zero 2 W firmware, U-Boot and extlinux.
  # Omit its installer/rescue package collection on this 512 MB machine.
  disabledModules = ["profiles/base.nix"];
  nixpkgs.hostPlatform = "aarch64-linux";
  networking.hostName = "nixzero";
  time.timeZone = "Europe/Berlin";
  system.stateVersion = "26.05";

  image.baseName = "nixos-nixzero-aarch64-linux";
  sdImage = {
    compressImage = false;
    firmwareSize = 64;
    populateFirmwareCommands = lib.mkAfter ''
      mkdir -p "$TMPDIR/nixzero-boot"
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} \
        -c ${config.system.build.toplevel} -d "$TMPDIR/nixzero-boot"
      export PATH=${lib.makeBinPath [pkgs.ubootTools]}:$PATH
      ${pkgs.python3}/bin/python3 ${../../scripts/prepare-nixzero-diagnostics.py} \
        --script ${../../scripts/nixzero-boot.cmd} \
        --extlinux "$TMPDIR/nixzero-boot/extlinux/extlinux.conf" \
        --initrd ${config.system.build.initialRamdisk}/initrd \
        --output "$TMPDIR/nixzero-diagnostics"
      cp "$TMPDIR/nixzero-diagnostics/"{uboot.env,nixzero-boot.scr,nixzero-initrd} firmware/
    '';
  };
  boot.loader.generic-extlinux-compatible.configurationLimit = 3;
  boot.initrd.systemd.tpm2.enable = false;
  boot.kernelParams = ["cfg80211.ieee80211_regdom=DE"];

  # Only this board's wireless firmware is needed, not the full PC bundle.
  hardware.enableRedistributableFirmware = lib.mkForce false;
  hardware.firmware = [pkgs.raspberrypiWirelessFirmware];
  hardware.wirelessRegulatoryDatabase = true;

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  networking.firewall.enable = true;

  # A profile placed on the FAT partition from macOS is imported before NM
  # starts. Credentials never enter the flake or the world-readable Nix store.
  fileSystems."/boot/firmware".options = lib.mkForce ["defaults" "umask=0077"];
  systemd.services.nixzero-import-wifi = {
    description = "Import the Wi-Fi profile from the SD firmware partition";
    wantedBy = ["multi-user.target"];
    before = ["NetworkManager.service"];
    after = ["local-fs.target"];
    unitConfig = {
      RequiresMountsFor = "/boot/firmware";
      ConditionPathExists = "/boot/firmware/nixzero.nmconnection";
    };
    serviceConfig.Type = "oneshot";
    path = [pkgs.coreutils];
    script = ''
      install -d -m 0700 /etc/NetworkManager/system-connections
      install -m 0600 /boot/firmware/nixzero.nmconnection \
        /etc/NetworkManager/system-connections/nixzero.nmconnection
      sync
      rm /boot/firmware/nixzero.nmconnection
    '';
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
  users.mutableUsers = false;
  users.users.root.openssh.authorizedKeys.keys = sshKeys;
  users.users.infiniter = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    openssh.authorizedKeys.keys = sshKeys;
  };
  security.sudo.wheelNeedsPassword = false;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };
  services.tailscale = {
    enable = true;
    openFirewall = false;
    useRoutingFeatures = "none";
    extraSetFlags = ["--netfilter-mode=off" "--ssh=false" "--accept-routes=false"];
  };

  zramSwap.enable = true;
  # Evaluation happens on the Zero even with a remote build worker. Give the
  # 512 MB board disk-backed swap for evaluating the repository's flake.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 2048;
    }
  ];
  services.journald.extraConfig = "SystemMaxUse=64M";
  nix.distributedBuilds = true;
  programs.ssh.knownHosts."nixpi.tail6650cb.ts.net".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2SIZwh/go5ExVFdABBVwXvulYb1YTW7+Sg1r+AWASA";
  nix.buildMachines = [
    {
      hostName = "nixpi.tail6650cb.ts.net";
      protocol = "ssh-ng";
      sshUser = "root";
      sshKey = "/root/.ssh/nixzero-builder";
      system = "aarch64-linux";
      maxJobs = 2;
      supportedFeatures = ["big-parallel"];
    }
  ];
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    builders-use-substitutes = true;
    max-jobs = 0;
    cores = 1;
  };
  environment.systemPackages = with pkgs; [gitMinimal vim htop];
}
