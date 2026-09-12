{pkgs, ...}: let
  sshKeys = import ./ssh-keys.nix;
in {
  programs.ssh.startAgent = true;

  users.users.root.openssh.authorizedKeys.keys = sshKeys;

  users.users.infiniter = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ["wheel" "docker" "video" "podman" "jellyfin"];
    openssh.authorizedKeys.keys = sshKeys;
  };
}
