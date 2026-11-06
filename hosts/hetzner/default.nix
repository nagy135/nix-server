{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware.nix
    ./networking.nix
    ./system.nix
    ./nginx.nix
    ../../modules/services/wow-browser.nix
    ../../modules/services/sentinel.nix
    ../../modules/services/websupport-ddns.nix
    (import ../../modules/opencode-projects.nix {
      enable = false;
      projectPaths = [
        "/home/infiniter/services/vite-portfolio"
        "/home/infiniter/services/shift-distributor"
      ];
      opencodePkg = pkgs.opencode;
      createUser = false;
      user = "infiniter";
      group = null;
      home = "/home/infiniter";
      gitUserName = "Viktor Nagy (opencode)";
      gitUserEmail = "viktor.nagy1995@gmail.com";
    })
  ];

  # Enroll once with `sudo tailscale up --netfilter-mode=off --ssh=false --accept-routes=false`.
  # Keep NixOS in charge of filtering and use the existing OpenSSH service.
  services.tailscale = {
    enable = true;
    openFirewall = false;
    useRoutingFeatures = "none";
    extraSetFlags = ["--netfilter-mode=off" "--ssh=false" "--accept-routes=false"];
  };

  services.infiniter.sentinel.domain = "hetzner-status.infiniter.tech";
  services.infiniter.websupportDDNS = {
    enable = true;
    zone = "infiniter.tech";
  };

  # Allow the nixpi user to connect directly to this host.
  users.users.infiniter.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMcxBodMurVsakhLxTMpSqnxrSXOI3Wmo++9MoQpNr42 infiniter@nixpi"
  ];

  # Keep the installed host's compatibility version when updating Nixpkgs.
  system.stateVersion = "24.11";
  services.hermes-agent.settings = {
    model.default = lib.mkForce "gpt-5.5";
  };
}
