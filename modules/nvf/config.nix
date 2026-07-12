{
  pkgs,
  lib,
  ...
}: let
  typebreakPlugin = pkgs.vimUtils.buildVimPlugin {
    pname = "typebreak.nvim";
    version = "unstable-2026-03-31";
    dependencies = [pkgs.vimPlugins.plenary-nvim];
    src = pkgs.fetchFromGitHub {
      owner = "nagy135";
      repo = "typebreak.nvim";
      rev = "51f4e4410272df8a9b31eda06be2e81bc4260aa6";
      sha256 = "sha256-TJbhl9CsbCwma3w+IzY0a0nwMw826U04AKXd0nW2lvo=";
    };
  };

  polarPlugin = pkgs.vimUtils.buildVimPlugin {
    pname = "polar.vim";
    version = "unstable-2026-03-31";
    src = pkgs.fetchFromGitHub {
      owner = "weihanglo";
      repo = "polar.vim";
      rev = "0a4bc09d5a542f62ce97b9135b55793b09ecdfe7";
      sha256 = "18fbphj8nhvp9m7i6lbciwqprvx1c4z6rmlg4bm07k1b8brjsdyz";
    };
  };
in {
  config.vim = {
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    enableLuaLoader = true;

    clipboard.enable = true;

    opts = {
      number = true;
      relativenumber = true;
      clipboard = lib.mkForce "unnamedplus";
      winborder = "rounded";
      mouse = "a";
      showmode = false;
      termguicolors = true;
      wrap = true;
      cursorline = true;
      scrolloff = 10;
      signcolumn = "yes";
      splitright = true;
      splitbelow = true;
      list = true;
      inccommand = "split";
      confirm = true;
      foldmethod = "marker";
      tabstop = 2;
      softtabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      breakindent = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      updatetime = 250;
      timeoutlen = 300;
    };

    extraPackages = with pkgs; [
      alejandra
      black
      isort
      prettierd
      stylua
    ];

    lsp = {
      enable = true;
      formatOnSave = false;
      lspSignature.enable = false;
      trouble.enable = false;
    };

    lsp.servers.lua_ls.settings.Lua.completion.callSnippet = "Replace";

    autocomplete.blink-cmp = {
      enable = true;
      mappings = {
        next = "<C-n>";
        previous = "<C-p>";
        scrollDocsUp = "<C-b>";
        scrollDocsDown = "<C-f>";
        confirm = "<C-y>";
        complete = "<C-Space>";
      };
      setupOpts.keymap = {
        preset = "none";
        "<C-l>" = ["snippet_forward" "fallback"];
        "<C-h>" = ["snippet_backward" "fallback"];
      };
    };
    autopairs.nvim-autopairs = {
      enable = true;
      setupOpts = {
        disable_filetype = [
          "TelescopePrompt"
          "spectre_panel"
          "snacks_picker_input"
          "typebreak"
        ];
      };
    };
    snippets.luasnip.enable = true;

    binds.whichKey = {
      enable = true;
      setupOpts.notify = false;
    };

    git = {
      enable = true;
      gitsigns.enable = true;
      # neogit.enable = false;
    };

    telescope.enable = true;

    filetree.neo-tree.enable = false;
    tabline.nvimBufferline.enable = true;

    notify.nvim-notify.enable = true;

    visuals = {
      nvim-web-devicons.enable = true;
      fidget-nvim.enable = true;
      indent-blankline.enable = false;
    };

    languages = {
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;

      typescript = {
        enable = true;
        format.enable = true;
      };

      bash.enable = true;
      html.enable = true;
      json.enable = true;
      lua.enable = true;
      markdown.enable = false;
      nix.enable = true;
      python.enable = true;
      yaml.enable = true;
    };

    startPlugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      gruvbox-material
      kanagawa-nvim
      nord-nvim
      vague-nvim
      vim-sleuth
      mini-nvim
      mini-pick
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      polarPlugin
    ];

    lazy.enable = true;
    lazy.plugins = {
      "flash.nvim" = {
        package = pkgs.vimPlugins.flash-nvim;
        lazy = false;
        setupModule = "flash";
        setupOpts = {};
      };

      "lazydev.nvim" = {
        package = pkgs.vimPlugins.lazydev-nvim;
        ft = ["lua"];
        after = ''
          require("lazydev").setup({
            library = {
              { path = "''${3rd}/luv/library", words = { "vim%.uv" } },
            },
          })
        '';
      };

      "telescope-file-browser.nvim" = {
        package = pkgs.vimPlugins.telescope-file-browser-nvim;
      };

      "snacks.nvim" = {
        package = pkgs.vimPlugins.snacks-nvim;
        lazy = false;
        setupModule = "snacks";
        setupOpts = {
          picker.sources.lazy = false;
        };
      };

      "nvim-colorizer.lua" = {
        package = pkgs.vimPlugins.nvim-colorizer-lua;
        event = ["BufReadPre" "BufNewFile"];
        setupModule = "colorizer";
        setupOpts = {
          filetypes = ["*"];
          buftypes = ["terminal"];
          user_commands = true;
          options = {
            parsers = {
              hex.default = true;
              css = true;
            };
            display.mode = "background";
          };
        };
      };

      "noice.nvim" = {
        package = pkgs.vimPlugins.noice-nvim;
        lazy = false;
        setupModule = "noice";
        setupOpts = {
          lsp = {
            progress.enabled = true;
            hover.enabled = true;
            signature.enabled = true;
          };

          presets = {
            bottom_search = false;
            command_palette = true;
            long_message_to_split = true;
            inc_rename = false;
            lsp_doc_border = true;
          };

          cmdline = {
            enabled = true;
            view = "cmdline_popup";
          };

          messages = {
            enabled = true;
            view = "notify";
            view_error = "notify";
            view_warn = "notify";
          };

          popupmenu.enabled = true;

          notify.enabled = true;
        };
      };

      "nvim-navic" = {
        package = pkgs.vimPlugins.nvim-navic;
        lazy = false;
        setupModule = "nvim-navic";
        setupOpts = {};
      };

      "nvim-surround" = {
        package = pkgs.vimPlugins.nvim-surround;
        lazy = false;
        setupModule = "nvim-surround";
        setupOpts = {};
      };

      "align.nvim" = {
        package = pkgs.vimPlugins.align-nvim;
        keys = [
          {
            key = "aw";
            mode = ["x"];
          }
        ];
      };

      "quicker.nvim" = {
        package = pkgs.vimPlugins.quicker-nvim;
        ft = ["qf"];
        setupModule = "quicker";
        setupOpts = {};
      };

      "vim-qf" = {
        package = pkgs.vimPlugins.vim-qf;
        ft = ["qf"];
      };

      "nvim-bqf" = {
        package = pkgs.vimPlugins.nvim-bqf;
        ft = ["qf"];
        setupModule = "bqf";
        setupOpts = {
          func_map = {
            prevhist = "<C-p>";
            nexthist = "<C-n>";
          };
        };
      };

      "trouble.nvim" = {
        package = pkgs.vimPlugins.trouble-nvim;
        cmd = ["Trouble"];
        setupModule = "trouble";
        setupOpts = {};
      };

      "codesnap.nvim" = {
        package = pkgs.vimPlugins.codesnap-nvim;
        cmd = ["CodeSnap" "CodeSnapHighlight" "CodeSnapSave" "CodeSnapSaveHighlight" "CodeSnapASCII"];
        setupModule = "codesnap";
        setupOpts.snapshot_config = {
          watermark.content = "";
          window.margin = {
            x = 41;
            y = 41;
          };
        };
      };

      "diffview.nvim" = {
        package = pkgs.vimPlugins.diffview-nvim;
        cmd = ["DiffviewOpen" "DiffviewFileHistory"];
        setupModule = "diffview";
        setupOpts.view = {
          default.disable_diagnostics = true;
          file_history.disable_diagnostics = true;
        };
      };

      # "neogit" = {
      #   package = pkgs.vimPlugins.neogit;
      #   cmd = ["Neogit"];
      # };

      "undotree" = {
        package = pkgs.vimPlugins.undotree;
        cmd = ["UndotreeToggle" "UndotreeFocus"];
      };

      "nvim-window-picker" = {
        package = pkgs.vimPlugins.nvim-window-picker;
        lazy = false;
        setupModule = "window-picker";
        setupOpts.hint = "floating-big-letter";
      };

      "snipe.nvim" = {
        package = pkgs.vimPlugins.snipe-nvim;
        keys = [
          {
            key = "<leader>S";
            mode = ["n"];
          }
        ];
        setupModule = "snipe";
        setupOpts = {
          ui = {
            preselect_current = true;
            position = "center";
            open_win_override.border = "rounded";
            text_align = "file-first";
          };
        };
      };

      "kulala.nvim" = {
        package = pkgs.vimPlugins.kulala-nvim;
        ft = ["http" "rest"];
        after = ''
          require("kulala").setup({
            global_keymaps = {
              ["Send request"] = {
                "<leader>Rs",
                function()
                  require("kulala").run()
                end,
                mode = { "n", "v" },
                desc = "Send request",
              },
              ["Send all requests"] = {
                "<leader>Ra",
                function()
                  require("kulala").run_all()
                end,
                mode = { "n", "v" },
                ft = "http",
              },
              ["Replay the last request"] = {
                "<leader>Rr",
                function()
                  require("kulala").replay()
                end,
                ft = { "http", "rest" },
              },
            },
            lsp = {
              enable = true,
              filetypes = { "http", "rest", "json", "yaml", "bruno" },
              keymaps = false,
              formatter = {
                split_params = 4,
                sort = {
                  metadata = true,
                  variables = true,
                  commands = false,
                  json = true,
                },
                quote_json_variables = true,
                indent = 2,
              },
            },
            ui = {
              win_opts = {
                wo = {
                  foldenable = false,
                },
              },
            },
          })
        '';
      };

      "supermaven-nvim" = {
        package = pkgs.vimPlugins.supermaven-nvim;
        lazy = false;
        setupModule = "supermaven-nvim";
        setupOpts = {
          color = {
            suggestion_color = "#DBDBDB";
            cterm = 244;
          };
        };
      };

      "typebreak.nvim" = {
        package = typebreakPlugin;
      };
    };

    luaConfigPre = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "
      vim.g.have_nerd_font = true
    '';

    luaConfigRC = {
      theme = builtins.readFile ./lua/theme.lua;
      miniConfig = builtins.readFile ./lua/mini.lua;
      commandAbbreviations = builtins.readFile ./lua/command-abbreviations.lua;
      telescopeConfig = builtins.readFile ./lua/telescope.lua;
      cmpAndFormatting = builtins.readFile ./lua/cmp-formatting.lua;
      diagnosticsAndLsp = builtins.readFile ./lua/diagnostics-lsp.lua;
      quickfixAndAutocmds = builtins.readFile ./lua/quickfix-autocmds.lua;
      scriptsAndKeymaps = builtins.readFile ./lua/scripts-keymaps.lua;
      whichKeyGroups = builtins.readFile ./lua/which-key.lua;
    };
  };
}
