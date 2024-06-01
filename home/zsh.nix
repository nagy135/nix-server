{ pkgs, ... }:
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

      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "$${(s.:.)LS_COLORS}"
      '';
    };
  }
