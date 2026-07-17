{...}: {
  imports = [
    ./networking.nix
    ./modules/system/base.nix
    ./modules/users.nix
    ./modules/services/self-hosted.nix
    ./modules/web/nginx.nix
  ];

  system.stateVersion = "25.11";
}
