{...}: {
  config.vim.keymaps = [
    {
      key = "]h";
      mode = "n";
      silent = true;
      desc = "Next Git hunk";
      action = "<cmd>Gitsigns next_hunk<CR>";
    }
    {
      key = "[h";
      mode = "n";
      silent = true;
      desc = "Previous Git hunk";
      action = "<cmd>Gitsigns prev_hunk<CR>";
    }
    {
      key = "ghs";
      mode = "n";
      silent = true;
      desc = "Stage Git hunk";
      action = "<cmd>lua require('gitsigns').stage_hunk()<CR>";
    }
    {
      key = "ghr";
      mode = "n";
      silent = true;
      desc = "Reset Git hunk";
      action = "<cmd>lua require('gitsigns').reset_hunk()<CR>";
    }
    {
      key = "ghl";
      mode = "n";
      silent = true;
      desc = "Toggle Git line blame";
      action = "<cmd>lua require('gitsigns').toggle_current_line_blame()<CR>";
    }
    {
      key = "<leader>ghb";
      mode = "n";
      silent = true;
      desc = "Git blame line";
      action = "<cmd>lua require('gitsigns').blame_line({ full = true })<CR>";
    }
    {
      key = "ghS";
      mode = "n";
      silent = true;
      desc = "Stage Git buffer";
      action = "<cmd>lua require('gitsigns').stage_buffer()<CR>";
    }
    {
      key = "ghR";
      mode = "n";
      silent = true;
      desc = "Reset Git buffer";
      action = "<cmd>lua require('gitsigns').reset_buffer()<CR>";
    }
  ];
}
