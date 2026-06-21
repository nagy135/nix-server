{
  lib,
  pkgs,
  ...
}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # without this is starts eating all CPU for some reason, nscd is something with cache that should not matter
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "nixos";
  networking.domain = "";
  networking.enableIPv6 = false;
  services.openssh.enable = true;

  nixpkgs.overlays = [
    (self: super: {
      paperless-ngx = super.paperless-ngx.overrideAttrs (old: {
        doCheck = false;
        doInstallCheck = false;
      });
    })
  ];

  programs.neovim = {
    enable = true;
    vimAlias = true;
  };

  environment.systemPackages = with pkgs; [
    gcc
    lsd
    ripgrep
    sops
    lua
    lazygit
    z-lua
    bun
    nodejs
    docker-compose
    git
    # postgresql
    docker-client
    neovim
    python3
  ];

  # Arion works with Docker, but for NixOS-based containers, you need Podman
  # since NixOS 21.05.
  virtualisation.docker.enable = true;
  #  virtualisation.podman.enable = true;
  #  virtualisation.podman.dockerSocket.enable = true;
  #
  #  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  networking.firewall.allowedTCPPorts = [
    25 # SMTP
    80 # ACME / web
    143 # IMAP
    443 # webmail
    587 # submission
    993 # IMAPS
    4190 # ManageSieve
  ];

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
    }
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "viktor.nagy1995@gmail.com";
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    openssl
  ];

  services.cron.enable = true;
  services.cron.systemCronJobs = [
    "0 * * * * root mkdir -p /home/infiniter/services/shift-distributor/data/backups && cp /home/infiniter/services/shift-distributor/data/sqlite.db /home/infiniter/services/shift-distributor/data/backups/sqlite-$(date +\\%F-\\%R).db &> /tmp/heh.log"
  ];
}
