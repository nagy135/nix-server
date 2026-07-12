{...}: {
  config.vim.keymaps = [
    {
      key = "<leader><leader>e";
      mode = "n";
      silent = true;
      desc = "File Explorer";
      action = "<cmd>lua Snacks.explorer()<CR>";
    }
    {
      key = "<leader>e";
      mode = "n";
      silent = true;
      desc = "Explorer";
      action = "<cmd>lua Snacks.explorer()<CR>";
    }
    {
      key = "<leader>E";
      mode = "n";
      silent = true;
      desc = "Explorer focus";
      action = "<cmd>lua Snacks.explorer()<CR>";
    }
    {
      key = "<leader>fB";
      mode = "n";
      silent = true;
      desc = "[F]ind [B]uffers";
      action = "<cmd>lua Snacks.picker.buffers()<CR>";
    }
    {
      key = "<leader>fm";
      mode = "n";
      silent = true;
      desc = "[F]ile [M]ini-explorer";
      action = "<cmd>lua require('mini.files').open(vim.api.nvim_buf_get_name(0), true)<CR>";
    }
    {
      key = "<leader>S";
      mode = "n";
      silent = true;
      desc = "Open Snipe buffer menu";
      action = "<cmd>lua require('snipe').open_buffer_menu()<CR>";
    }
    {
      key = "<leader>cb";
      mode = "n";
      silent = true;
      desc = "[C]ode [B]readcrumbs";
      action = "<cmd>NavicNotify<CR>";
    }
    {
      key = "<leader>cs";
      mode = "x";
      silent = true;
      desc = "[C]ode [S]creenshot";
      action = ":'<,'>CodeSnap<CR>";
    }
    {
      key = "<leader>uu";
      mode = "n";
      silent = true;
      desc = "Undotree (toggle)";
      action = "<cmd>UndotreeToggle<CR>";
    }
    {
      key = "<leader>uf";
      mode = "n";
      silent = true;
      desc = "Undotree (focus)";
      action = "<cmd>UndotreeFocus<CR>";
    }
    {
      key = "<leader>xx";
      mode = "n";
      silent = true;
      desc = "Diagnostics (Trouble)";
      action = "<cmd>Trouble diagnostics toggle<CR>";
    }
    {
      key = "<leader>xX";
      mode = "n";
      silent = true;
      desc = "Buffer Diagnostics (Trouble)";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
    }
    {
      key = "<leader>cl";
      mode = "n";
      silent = true;
      desc = "LSP Definitions / references / ... (Trouble)";
      action = "<cmd>Trouble lsp toggle focus=false win.position=right<CR>";
    }
    {
      key = "<leader>xL";
      mode = "n";
      silent = true;
      desc = "Location List (Trouble)";
      action = "<cmd>Trouble loclist toggle<CR>";
    }
    {
      key = "<leader>xQ";
      mode = "n";
      silent = true;
      desc = "Quickfix List (Trouble)";
      action = "<cmd>Trouble qflist toggle<CR>";
    }
    {
      key = "<leader>z";
      mode = "n";
      silent = true;
      desc = "Toggle Zen Mode";
      action = "<cmd>lua Snacks.zen()<CR>";
    }
    {
      key = "<leader>Z";
      mode = "n";
      silent = true;
      desc = "Toggle Zoom";
      action = "<cmd>lua Snacks.zen.zoom()<CR>";
    }
    {
      key = "<leader>.";
      mode = "n";
      silent = true;
      desc = "Toggle Scratch Buffer";
      action = "<cmd>lua Snacks.scratch()<CR>";
    }
    {
      key = "<leader>bd";
      mode = "n";
      silent = true;
      desc = "Delete Buffer";
      action = "<cmd>lua Snacks.bufdelete()<CR>";
    }
    {
      key = "<leader>cR";
      mode = "n";
      silent = true;
      desc = "Rename File";
      action = "<cmd>lua Snacks.rename.rename_file()<CR>";
    }
    {
      key = "<leader>un";
      mode = "n";
      silent = true;
      desc = "Dismiss All Notifications";
      action = "<cmd>lua Snacks.notifier.hide()<CR>";
    }
    {
      key = "<C-/>";
      mode = ["n" "t"];
      silent = true;
      desc = "Toggle Terminal";
      action = "<cmd>lua Snacks.terminal()<CR>";
    }
    {
      key = "<C-_>";
      mode = ["n" "t"];
      silent = true;
      desc = "which_key_ignore";
      action = "<cmd>lua Snacks.terminal()<CR>";
    }
    {
      key = "]]";
      mode = ["n" "t"];
      silent = true;
      desc = "Next Reference";
      action = "<cmd>lua Snacks.words.jump(vim.v.count1)<CR>";
    }
    {
      key = "[[";
      mode = "n";
      silent = true;
      desc = "Prev Reference";
      action = "<cmd>lua Snacks.words.jump(-vim.v.count1)<CR>";
    }
    {
      key = "<leader>ml";
      mode = "n";
      silent = true;
      desc = "Theme light";
      action = "<cmd>lua vim.cmd.colorscheme('catppuccin-latte')<CR>";
    }
    {
      key = "<leader>md";
      mode = "n";
      silent = true;
      desc = "Theme dark";
      action = "<cmd>lua vim.o.background = 'dark'; vim.cmd.colorscheme('gruvbox-material')<CR>";
    }
    {
      key = "<leader>clr";
      mode = "n";
      silent = true;
      desc = "LSP restart";
      action = "<cmd>lua for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do client:stop() end; vim.defer_fn(function() vim.cmd.edit() end, 100)<CR>";
    }
    {
      key = "<leader>cls";
      mode = "n";
      silent = true;
      desc = "LSP stop buffer";
      action = "<cmd>lua for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do client:stop() end<CR>";
    }
    {
      key = "<leader><leader>j";
      mode = "n";
      silent = true;
      desc = "Get JSON Path";
      action = "<cmd>lua GetJsonPath()<CR>";
    }
    {
      key = "<leader><leader>tb";
      mode = "n";
      silent = true;
      desc = "Typebreak";
      action = "<cmd>lua require('typebreak').start(true)<CR>";
    }
    {
      key = "<leader>ccr";
      mode = "n";
      silent = true;
      desc = "Restart SuperMaven (Code Completion Restart)";
      action = "<cmd>SupermavenRestart<CR>";
    }
    {
      key = "<leader>cct";
      mode = "n";
      silent = true;
      desc = "Toggle SuperMaven (Code Completion Toggle)";
      action = "<cmd>lua NvfToggleSupermaven()<CR>";
    }
    {
      key = "s";
      mode = "n";
      silent = true;
      desc = "Flash";
      action = "<cmd>lua require('flash').jump()<CR>";
    }
    {
      key = "S";
      mode = ["n" "x" "o"];
      silent = true;
      desc = "Flash Treesitter";
      action = "<cmd>lua require('flash').treesitter()<CR>";
    }
    {
      key = "r";
      mode = "o";
      silent = true;
      desc = "Remote Flash";
      action = "<cmd>lua require('flash').remote()<CR>";
    }
    {
      key = "R";
      mode = ["o" "x"];
      silent = true;
      desc = "Treesitter Search";
      action = "<cmd>lua require('flash').treesitter_search()<CR>";
    }
    {
      key = "<C-s>";
      mode = "c";
      silent = true;
      desc = "Toggle Flash Search";
      action = "<cmd>lua require('flash').toggle()<CR>";
    }
  ];
}
