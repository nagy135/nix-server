{ nixvim, lib, pkgs, ... }:
let
  recursiveMerge = with lib; attrList:
    let
      f = attrPath:
        zipAttrsWith (n: values:
          if tail values == [ ]
          then head values
          else if all isList values
          then unique (concatLists values)
          else if all isAttrs values
          then f (attrPath ++ [ n ]) values
          else last values
        );
    in
    f [ ] attrList;
  nixvimConfiguration = {
    plugins = {
      autoclose.enable = true;
      treesitter.enable = true;
      noice.enable = true;
      comment.enable = true;
      nix.enable = true;
      surround.enable = true;
      emmet.enable = true;
      todo-comments.enable = true;
      which-key.enable = true;
      treesitter-context.enable = true;
    };
    extraPlugins = [ 
      pkgs.vimPlugins.gruvbox-material
      pkgs.vimPlugins.dressing-nvim
      pkgs.vimPlugins.neogit
    ];
    colorscheme = "gruvbox-material";
    # colorschemes.catppuccin.enable = true;
    
    clipboard.register = "unnamedplus";

    globals = {
      mapleader = " ";
    };
    options = {
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers
      shiftwidth = 2; # Tab width should be 2
      tabstop = 2; # Tab width should be 2
      laststatus = 3; # Single line status bar
      splitright = true;
      splitbelow = true;
    };
    keymaps = [
      {
        key = "<leader><C-h>";
        action = "<CMD>nohlsearch<CR>";
      }
      {
        key = "<C-h>";
        action = "<c-w>h";
      }
      {
        key = "<C-l>";
        action = "<c-w>l";
      }
      {
        key = "<C-j>";
        action = "<c-w>j";
      }
      {
        key = "<C-k>";
        action = "<c-w>k";
      }
      {
        key = ";";
        action = ":";
      }
      {
        key = "<C-c>";
        action = "<cmd>cclose<CR>";
      }
      {
        key = "<leader>bb";
        action = "<cmd>b#<CR>";
      }
      {
        key = "H";
        action = "<cmd>bprevious<CR>";
      }
      {
        key = "L";
        action = "<cmd>bnext<CR>";
      }
    ];

    extraConfigLua = ''
    require('neogit').setup {};

    vim.cmd("set undodir=~/.vim/undodir");
    vim.cmd("set undofile");

    vim.cmd([[ cnoreabbrev W w ]])
    vim.cmd([[ cnoreabbrev Q q ]])

    vim.cmd([[ cnoreabbrev Wq wq ]])
    vim.cmd([[ cnoreabbrev wQ wq ]])

    vim.cmd([[ cnoreabbrev Qa qa ]])

    vim.cmd([[ cnoreabbrev wQa wqa ]])
    vim.cmd([[ cnoreabbrev Wqa wqa ]])
    vim.cmd([[ cnoreabbrev wqA wqa ]])
    vim.cmd([[ cnoreabbrev WQa wqa ]])
    vim.cmd([[ cnoreabbrev wQA wqa ]])
    vim.cmd([[ cnoreabbrev WQA wqa ]])

    local cmp = require'cmp'

    cmp.setup({
      snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
        end,
      },
      window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' }, -- For vsnip users.
        -- { name = 'luasnip' }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
      }, {
        { name = 'buffer' },
      })
    })

    -- Set configuration for specific filetype.
    cmp.setup.filetype('gitcommit', {
      sources = cmp.config.sources({
        { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
      }, {
        { name = 'buffer' },
      })
    })

    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' }
      }
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' }
      }, {
        { name = 'cmdline' }
      }),
      matching = { disallow_symbol_nonprefix_matching = false }
    })
    '';
  };
in
  {

   config = recursiveMerge
    [
      nixvimConfiguration
      (import ./bufferline.nix)
      (import ./telescope.nix)
      (import ./cmp.nix)
      (import ./oil.nix)
      (import ./lsp.nix)
      (import ./neotree.nix)
      (import ./neogit.nix)
      (import ./harpoon.nix)
      (import ./copilot.nix)
      (import ./lualine.nix)
      (import ./flash.nix)
      (import ./undotree.nix)
      (import ./gitsigns.nix)
      (import ./lspsaga.nix)

      (import ./ftplugin.nix)
    ];
  }
