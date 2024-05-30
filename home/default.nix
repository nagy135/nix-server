{ config, pkgs, ... }:
{
  imports = [
    ./zsh.nix
  ];
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
