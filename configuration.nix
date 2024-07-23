{ pkgs, ... }:
let
  credentials = import credentials.nix;
in
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
    users.users.root.openssh.authorizedKeys.keys = [ ''
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnmNqABy0voX/rDdThGadpR5ZSF6NWJ2oWaGJvRJWF4H1PZHVJr/BSl/s7zQM5Tp4PH34+g8CNZAaFFP5aThGDv22cIAlZneM5t5HL0iHiN9/L9e9W3U7ySLDYdRls0QBnURUInNh8pK6IqqJTg8LDx6kfxOBhJyPtlLFhxqWtJSYTjm17B/tU8bvtslbg97Q1ck89VVX1g++2YCjOGhZv0HKp7X3F6RvTlJolYxUwvZ4qPdx2eXSWgSLAYJc7aDlJLdqEqPqA1senvcIYam+cWkxqnmEobIhmc4oDSnLO/Yf5vRANP/tw7VPgf9kxnXa7OEhbEt++Uts+FidZZC/xFnT9x2Rp8I/5MGLn52y5QPmSm3KTPSxBkFuzLA93opjOIiijov5EECZhtsWWN4z97rSeBu11OMXcbTKPTPCjOWxylDW83xFx6gl6/lmu5UirbRGqoOlzOoV2hrLy/MlOXX9lDU5LtlZShId4hbzt/lkctv7AcnE9QTSU/8651d8= infiniter@infiniter
    '' ];
    users.users.infiniter = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" "docker" "video" "podman" ];
      openssh.authorizedKeys.keys = [ ''
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnmNqABy0voX/rDdThGadpR5ZSF6NWJ2oWaGJvRJWF4H1PZHVJr/BSl/s7zQM5Tp4PH34+g8CNZAaFFP5aThGDv22cIAlZneM5t5HL0iHiN9/L9e9W3U7ySLDYdRls0QBnURUInNh8pK6IqqJTg8LDx6kfxOBhJyPtlLFhxqWtJSYTjm17B/tU8bvtslbg97Q1ck89VVX1g++2YCjOGhZv0HKp7X3F6RvTlJolYxUwvZ4qPdx2eXSWgSLAYJc7aDlJLdqEqPqA1senvcIYam+cWkxqnmEobIhmc4oDSnLO/Yf5vRANP/tw7VPgf9kxnXa7OEhbEt++Uts+FidZZC/xFnT9x2Rp8I/5MGLn52y5QPmSm3KTPSxBkFuzLA93opjOIiijov5EECZhtsWWN4z97rSeBu11OMXcbTKPTPCjOWxylDW83xFx6gl6/lmu5UirbRGqoOlzOoV2hrLy/MlOXX9lDU5LtlZShId4hbzt/lkctv7AcnE9QTSU/8651d8= infiniter@infiniter
      '' ];
    };
    environment.systemPackages = with pkgs;
    [
      lsd
      lazygit
      z-lua
      bun
      nodejs
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
      ensureDBOwnership = true;
    }
    {
      name = "dano";
      ensureDBOwnership = true;
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

      "warehouse.nagy135.eu" = (SSL // {
        locations."/".proxyPass = "http://127.0.0.1:13002/";
        serverAliases = [
          "www.warehouse.nagy135.eu"
        ];
      });
    };

    system.stateVersion = "23.11";

  }
