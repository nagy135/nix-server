{ pkgs, lib, ... }:
let
  functionsScripts = pkgs.writeShellScript "zshfunctions" ''
    fzfvim(){
    # find file in $1, open it with vim and put it into clipboard
    file=$(find -L $1 | fzf)
    if [[ ! -z $file ]]; then
    vim $file
    fi
    echo $file
    echo -n "$file" | pbcopy
    }
    cf(){
    fzfvim "$HOME/.config"
    }
    cdot(){
    fzfvim "$HOME/.dots"
    }
    sc(){
    fzfvim "$HOME/.scripts"
    }
    co(){
    fzfvim "$HOME/Code"
    }
    c() {
    # change directory and list its files
    cd "$@" && ls;
    }

    gop() { # go project
    choice=$(find ~ -maxdepth 6 -type d -o -type l | fzf)
    [[ ! -z $choice ]] \
    && cd $choice \
    && ls -l
    }

    zat() {
    # open zathura in background
    zathura $1 & exit;
    }

    copy_chmod_chown(){
    sudo chmod --reference=$1 $2
    sudo chown --reference=$1 $2
    }

    f(){
    q=$(echo "$@" | sed 's/\s\+/%20/g')
    open "https://google.com/search?q=$q";
    }

    git-last-commits(){
    NL=$'\n'

    branches=$(git branch -r | awk '{print $1}')
    results="";

    while read branch_name; do
    result=$(git show \
    --color=always \
    --pretty=format:"%Cgreen%ci %Cblue%cr %Cred%cn %Creset" $branch_name \
    | head -n 1)
    results="$results''${NL}$result#$branch_name"
    done <<< "$branches"
    echo "$results" | sort -r | column -t -s'#' | tr '#' ' '
    }

    video_to_facebook(){
    filename=$(basename $1 .mp4)
    ffmpeg -i $1 -c:v libx264 -preset slow -crf 20 -c:a aac -b:a 160k -vf format=yuv420p -movflags +faststart "$filename"_h264.mp4
    }

    proj(){
    folder=~/Apps
    choice=$(ls $folder | fzf)
    [[ ! -z $choice ]] && cd "$folder/$choice" && ls -la
    }

    lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
    dir="$(cat "$tmp")"
    rm -f "$tmp"
    [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
    }
    '';
in
  {
  home.packages = with pkgs; [
    zsh-powerlevel10k
    atuin
  ];

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [
      "--disable-up-arrow"
    ];
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    defaultKeymap = "viins";
    shellAliases = {
      ll = "lsd -la";
      ls = "lsd";
      lg = "lazygit --ucf ~/.config/lazygit/config.yml";
      lgs = "lazygit --ucf ~/.config/lazygit/config_side-by-side.yml";
      lzd = "lazydocker";

      cdc = "cd ~/Code";
      cdd = "cd ~/.dots";

      mv = "mv -v";
      cp = "cp -v";
      rm = "rm -v";

      q = "exit";
      ":q" = "exit";

      vim = "nvim";
      nvim-tmux = "nvim ~/.tmux.conf";

      cd-nix = "cd ~/Code/nix-darwin";
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
            export EDITOR=nvim
            export HISTFILE=$HOME/.zsh_history
            export PATH=$PATH:$HOME/.scripts

            export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
    '';
    initExtra = ''
                        source ${functionsScripts}

            [ -f ~/.zshenv_secret ] && source ~/.zshenv_secret

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

                autoload -z edit-command-line
                zle -N edit-command-line
                bindkey "^E" edit-command-line

            # export NVM_DIR="$HOME/.nvm"
            # [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm
    '';
  };
}

