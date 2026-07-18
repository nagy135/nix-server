{...}: {
  imports = [
    ./networking.nix
    ./modules/system/base.nix
    ./modules/users.nix
    ./modules/services/self-hosted.nix
    ./modules/services/hermes.nix
    ./modules/services/system-status.nix
    ./modules/web/nginx.nix
  ];

  system.stateVersion = "25.11";
}
