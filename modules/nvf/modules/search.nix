{...}: {
  config.vim.keymaps = [
    {
      key = "<leader><space>";
      mode = "n";
      silent = true;
      desc = "Smart Find Files";
      action = "<cmd>lua Snacks.picker.smart()<CR>";
    }
    {
      key = "<leader>,";
      mode = "n";
      silent = true;
      desc = "Buffers";
      action = "<cmd>lua Snacks.picker.buffers()<CR>";
    }
    {
      key = "<leader>/";
      mode = "n";
      silent = true;
      desc = "Grep";
      action = "<cmd>lua Snacks.picker.grep()<CR>";
    }
    {
      key = "<leader>:";
      mode = "n";
      silent = true;
      desc = "Command History";
      action = "<cmd>lua Snacks.picker.command_history()<CR>";
    }
    {
      key = "<leader>nn";
      mode = "n";
      silent = true;
      desc = "Notification History";
      action = "<cmd>lua Snacks.notifier.show_history()<CR>";
    }
    {
      key = "<leader>na";
      mode = "n";
      silent = true;
      desc = "Noice All";
      action = "<cmd>NoiceAll<CR>";
    }
    {
      key = "<leader>fb";
      mode = "n";
      silent = true;
      desc = "Buffers";
      action = "<cmd>lua Snacks.picker.buffers()<CR>";
    }
    {
      key = "<leader>fc";
      mode = "n";
      silent = true;
      desc = "Find Config File";
      action = "<cmd>lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })<CR>";
    }
    {
      key = "<leader>ff";
      mode = "n";
      silent = true;
      desc = "Find Files";
      action = "<cmd>lua Snacks.picker.files()<CR>";
    }
    {
      key = "<leader>fF";
      mode = "n";
      silent = true;
      desc = "Find Files (Ignored)";
      action = "<cmd>lua Snacks.picker.files({ ignored = true; hidden = true })<CR>";
    }
    {
      key = "<leader>fg";
      mode = "n";
      silent = true;
      desc = "Find Git Files";
      action = "<cmd>lua Snacks.picker.git_files()<CR>";
    }
    {
      key = "<leader>fp";
      mode = "n";
      silent = true;
      desc = "Projects";
      action = "<cmd>lua Snacks.picker.projects()<CR>";
    }
    {
      key = "<leader>fr";
      mode = "n";
      silent = true;
      desc = "Recent";
      action = "<cmd>lua Snacks.picker.recent()<CR>";
    }
    {
      key = "<leader>sB";
      mode = "n";
      silent = true;
      desc = "Grep Open Buffers";
      action = "<cmd>lua Snacks.picker.grep_buffers()<CR>";
    }
    {
      key = "<leader>sw";
      mode = ["n" "x"];
      silent = true;
      desc = "Visual selection or word";
      action = "<cmd>lua Snacks.picker.grep_word()<CR>";
    }
    {
      key = ''<leader>s"'';
      mode = "n";
      silent = true;
      desc = "Registers";
      action = "<cmd>lua Snacks.picker.registers()<CR>";
    }
    {
      key = "<leader>sa";
      mode = "n";
      silent = true;
      desc = "Autocmds";
      action = "<cmd>lua Snacks.picker.autocmds()<CR>";
    }
    {
      key = "<leader>sb";
      mode = "n";
      silent = true;
      desc = "Buffer Lines";
      action = "<cmd>lua Snacks.picker.lines()<CR>";
    }
    {
      key = "<leader>sc";
      mode = "n";
      silent = true;
      desc = "Command History";
      action = "<cmd>lua Snacks.picker.command_history()<CR>";
    }
    {
      key = "<leader>sC";
      mode = "n";
      silent = true;
      desc = "Commands";
      action = "<cmd>lua Snacks.picker.commands()<CR>";
    }
    {
      key = "<leader>sd";
      mode = "n";
      silent = true;
      desc = "Diagnostics";
      action = "<cmd>lua Snacks.picker.diagnostics()<CR>";
    }
    {
      key = "<leader>sD";
      mode = "n";
      silent = true;
      desc = "Buffer Diagnostics";
      action = "<cmd>lua Snacks.picker.diagnostics_buffer()<CR>";
    }
    {
      key = "<leader>sh";
      mode = "n";
      silent = true;
      desc = "Help Pages";
      action = "<cmd>lua Snacks.picker.help()<CR>";
    }
    {
      key = "<leader>sH";
      mode = "n";
      silent = true;
      desc = "Highlights";
      action = "<cmd>lua Snacks.picker.highlights()<CR>";
    }
    {
      key = "<leader>si";
      mode = "n";
      silent = true;
      desc = "Icons";
      action = "<cmd>lua Snacks.picker.icons()<CR>";
    }
    {
      key = "<leader>sj";
      mode = "n";
      silent = true;
      desc = "Jumps";
      action = "<cmd>lua Snacks.picker.jumps()<CR>";
    }
    {
      key = "<leader>sk";
      mode = "n";
      silent = true;
      desc = "Keymaps";
      action = "<cmd>lua Snacks.picker.keymaps()<CR>";
    }
    {
      key = "<leader>sl";
      mode = "n";
      silent = true;
      desc = "Location List";
      action = "<cmd>lua Snacks.picker.loclist()<CR>";
    }
    {
      key = "<leader>sm";
      mode = "n";
      silent = true;
      desc = "Marks";
      action = "<cmd>lua Snacks.picker.marks()<CR>";
    }
    {
      key = "<leader>sM";
      mode = "n";
      silent = true;
      desc = "Man Pages";
      action = "<cmd>lua Snacks.picker.man()<CR>";
    }
    {
      key = "<leader>sp";
      mode = "n";
      silent = true;
      desc = "Pickers";
      action = "<cmd>lua Snacks.picker()<CR>";
    }
    {
      key = "<leader>sq";
      mode = "n";
      silent = true;
      desc = "Quickfix List";
      action = "<cmd>lua Snacks.picker.qflist()<CR>";
    }
    {
      key = "<leader>sR";
      mode = "n";
      silent = true;
      desc = "Resume";
      action = "<cmd>lua Snacks.picker.resume()<CR>";
    }
    {
      key = "<leader>su";
      mode = "n";
      silent = true;
      desc = "Undo History";
      action = "<cmd>lua Snacks.picker.undo()<CR>";
    }
    {
      key = "<leader>uC";
      mode = "n";
      silent = true;
      desc = "Colorschemes";
      action = "<cmd>lua Snacks.picker.colorschemes()<CR>";
    }
    {
      key = "<leader>ss";
      mode = "n";
      silent = true;
      desc = "LSP Symbols";
      action = "<cmd>lua Snacks.picker.lsp_symbols()<CR>";
    }
    {
      key = "<leader>sS";
      mode = "n";
      silent = true;
      desc = "LSP Workspace Symbols";
      action = "<cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>";
    }
    {
      key = "<leader>ww";
      mode = "n";
      silent = true;
      desc = "[W]iki files";
      action = "<cmd>lua NvfWikiFiles()<CR>";
    }
    {
      key = "<leader>wg";
      mode = "n";
      silent = true;
      desc = "[W]iki grep";
      action = "<cmd>lua NvfWikiGrep()<CR>";
    }
    {
      key = "<leader>wr";
      mode = "n";
      silent = true;
      desc = "[W]iki grep word";
      action = "<cmd>lua NvfWikiGrepWord()<CR>";
    }
    {
      key = "<leader>wi";
      mode = "n";
      silent = true;
      desc = "[W]iki index";
      action = "<cmd>lua NvfOpenWikiIndex()<CR>";
    }
  ];
}
