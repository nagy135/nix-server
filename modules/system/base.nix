{
  lib,
  nvf,
  pkgs,
  ...
}: let
  neovimPackage = (import ../nvf {inherit nvf pkgs;}).neovim;
in {
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfreePredicate = package:
    builtins.elem (lib.getName package) [
      "netdata"
      "nvim-dap-vscode-js"
      "vscode-js-debug"
    ];

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  virtualisation.docker.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  environment.systemPackages = with pkgs; [
    lsd
    ripgrep
    git
    neovimPackage
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "viktor.nagy1995@gmail.com";
  };
}
