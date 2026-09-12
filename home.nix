{...}: {
  imports = [./home/zsh.nix];

  home = {
    username = "infiniter";
    homeDirectory = "/home/infiniter";
    stateVersion = "24.11";
    sessionVariables.EDITOR = "nvim";
  };

  programs.home-manager.enable = true;
}
