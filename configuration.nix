{inputs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    ./modules/system/base.nix
    ./modules/users.nix
    ./modules/services/hermes.nix
    ./modules/services/self-hosted.nix
    ./modules/web/nginx.nix
    (import ./modules/opencode-projects.nix {
      projectPaths = [
        "/home/infiniter/services/vite-portfolio"
        "/home/infiniter/services/shift-distributor"
        # "/home/infiniter/services/ai_image_edit"
      ];
      opencodePkg = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.opencode;
      createUser = false;
      user = "infiniter";
      group = null;
      home = "/home/infiniter";
      gitUserName = "Viktor Nagy (opencode)";
      gitUserEmail = "viktor.nagy1995@gmail.com";
    })
    inputs.home-manager.nixosModules.default
  ];

  system.stateVersion = "24.11";
}
