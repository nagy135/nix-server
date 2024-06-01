{ pkgs, lib, ... }:
let
  functionsScripts = pkgs.writeShellScript "zshfunctions" ''
  copy_chmod_chown(){
    sudo chmod --reference=$1 $2
    sudo chown --reference=$1 $2
  }
  '';
in
  {
    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      defaultKeymap = "viins";
      shellAliases = {
        ls = "lsd";
        la = "lsd -a";
        ll = "lsd -l";

        lg = "lazygit";

        cds = "cd ~/services";

        mv = "mv -v";
        cp = "cp -v";
        rm = "rm -v";

        q = "exit";
        ":q" = "exit";

        vim = "nvim";

      };
      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = lib.cleanSource ./config;
          file = "p10k.zsh";
        }
      ];
      envExtra = ''
      export HISTFILE=$HOME/.zsh_history
      '';
      initExtra = ''
      source ${functionsScripts}


      export PATH=~/.npm-packages/bin:$PATH
      export NODE_PATH=~/.npm-packages/lib/node_modules

      bindkey '^R' history-incremental-search-backward

      bindkey '^P' history-search-backward
      bindkey '^N' history-search-forward

      setopt noincappendhistory
      setopt nosharehistory
      setopt appendhistory


      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "$${(s.:.)LS_COLORS}"
      '';
    };
  }
