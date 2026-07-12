{...}: {
  config.vim.keymaps = [
    {
      key = "<leader>gb";
      mode = "n";
      silent = true;
      desc = "Git Branches";
      action = "<cmd>lua Snacks.picker.git_branches()<CR>";
    }
    {
      key = "<leader>gl";
      mode = "n";
      silent = true;
      desc = "Git Log";
      action = "<cmd>lua Snacks.picker.git_log()<CR>";
    }
    {
      key = "<leader>gL";
      mode = "n";
      silent = true;
      desc = "Git Log Line";
      action = "<cmd>lua Snacks.picker.git_log_line()<CR>";
    }
    {
      key = "<leader>gs";
      mode = "n";
      silent = true;
      desc = "Git Status";
      action = "<cmd>lua Snacks.picker.git_status()<CR>";
    }
    {
      key = "<leader>gS";
      mode = "n";
      silent = true;
      desc = "Git Stash";
      action = "<cmd>lua Snacks.picker.git_stash()<CR>";
    }
    {
      key = "<leader>gx";
      mode = "n";
      silent = true;
      desc = "Git Diff (Hunks)";
      action = "<cmd>lua Snacks.picker.git_diff()<CR>";
    }
    {
      key = "<leader>gf";
      mode = "n";
      silent = true;
      desc = "Git Log File";
      action = "<cmd>lua Snacks.picker.git_log_file()<CR>";
    }
    {
      key = "<leader>gB";
      mode = ["n" "v"];
      silent = true;
      desc = "Git Browse";
      action = "<cmd>lua Snacks.gitbrowse()<CR>";
    }
    {
      key = "<leader>gg";
      mode = "n";
      silent = true;
      desc = "Lazygit";
      action = "<cmd>lua Snacks.lazygit()<CR>";
    }
    {
      key = "<leader>ghr";
      mode = "n";
      silent = true;
      desc = "git [g]it [h]unk [r]eset";
      action = "<cmd>lua require('gitsigns').reset_hunk()<CR>";
    }
    {
      key = "<leader>ghR";
      mode = "n";
      silent = true;
      desc = "git [g]it [h]unk [R]eset buffer";
      action = "<cmd>lua require('gitsigns').reset_buffer()<CR>";
    }
    {
      key = "<leader>gdf";
      mode = "n";
      silent = true;
      desc = "File History";
      action = "<cmd>lua NvfDiffviewFileHistory()<CR>";
    }
    {
      key = "<leader>gdi";
      mode = "n";
      silent = true;
      desc = "Git Diff Inline";
      action = "<cmd>lua MiniDiff.toggle_overlay()<CR>";
    }
    {
      key = "<leader>gdt";
      mode = "n";
      silent = true;
      desc = "Toggle Diff View";
      action = "<cmd>lua NvfDiffviewToggle()<CR>";
    }
    {
      key = "<leader>gD";
      mode = "n";
      silent = true;
      desc = "Toggle Diff View";
      action = "<cmd>lua NvfDiffviewToggle()<CR>";
    }
  ];
}
