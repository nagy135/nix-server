{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect

  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  zramSwap.enable = true;
  networking.hostName = "nixos";
  networking.domain = "";
  services.openssh.enable = true;
  programs.zsh.enable = true;

  programs.neovim = {
    enable = true;
    vimAlias = true;
  };

  boot.tmp.cleanOnBoot = true;
  users.users.root.openssh.authorizedKeys.keys = [
    ''PUBLIC_KEY''
  ];
  users.users.infiniter = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" "video" "podman" ];
    openssh.authorizedKeys.keys = [ ''PUBLIC_KEY'' ];
  };
  environment.systemPackages = with pkgs;
  [
    neovim
    lsd
    lazygit

    docker-compose
    git
    postgresql
    docker-client
  ];


# Arion works with Docker, but for NixOS-based containers, you need Podman
# since NixOS 21.05.
virtualisation.docker.enable = true;
#  virtualisation.podman.enable = true;
#  virtualisation.podman.dockerSocket.enable = true;
#
#  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

services.postgresql = {
  enable = true;
  authentication = ''
  local   all             all                                     trust
  host    all             all             0.0.0.0/0               trust
  host    all             all             ::1/128                 trust
  '';

  enableTCPIP = true;
  ensureDatabases = [ "3dprints" "dano" ];
  ensureUsers = [
    {
      name = "3dprints";
      ensurePermissions = {
        "DATABASE \"3dprints\"" = "ALL PRIVILEGES";
      };
    }
    {
      name = "dano";
      ensurePermissions = {
        "DATABASE \"dano\"" = "ALL PRIVILEGES";
      };
    }
  ];
};

networking.firewall.allowedTCPPorts = [
  80
  443
  5432
];

swapDevices = [{
  device = "/var/lib/swapfile";
  size = 8 * 1024;
}];


security.acme = {
  acceptTerms = true;

  defaults.email = "viktor.nagy1995@gmail.com";
};


services.nginx.enable = true;
services.nginx.virtualHosts =
  let
    SSL = {
      enableACME = true;
      forceSSL = true;
    }; in
    {
      "metaverse-api.nagy135.eu" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:13000/";
        serverAliases = [
          "www.metaverse-api.nagy135.eu"
        ];
      });

      "metaverse.nagy135.eu" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:3000/";
        serverAliases = [
          "www.metaverse.nagy135.eu"
        ];
      });

      "drive.nagy135.eu" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:13001/";
        serverAliases = [
          "www.drive.nagy135.eu"
        ];
      });
    };

    system.stateVersion = "23.11";

  }
