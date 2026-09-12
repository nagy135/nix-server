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
    (import ../../modules/opencode-projects.nix {
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

  # Keep the installed host's compatibility version when updating Nixpkgs.
  system.stateVersion = "24.11";
  services.hermes-agent.settings = {
    model.default = lib.mkForce "gpt-5.5";
  };
}
