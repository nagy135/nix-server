{ pkgs, inputs, ... }:
let 
  nixvimModule = inputs.nixvim.legacyPackages.x86_64-linux.makeNixvimWithModule {
    inherit pkgs;
    module = import ../nixvim;
  };
in
{
  imports = [
    ./zsh.nix
  ];
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;


  home.packages = [
    nixvimModule
  ];
}
