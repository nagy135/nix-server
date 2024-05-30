let 
  keymaps_bind = {
    action = "keymaps";
    desc = "keymaps";
  };
in {
  plugins.telescope = {
    enable = true;
    keymaps = {
      "<leader>gf" = {
        action = "git_files";
        desc = "git files";
      };
      "<leader>ff" = {
        action = "find_files";
        desc = "files";
      };
      "<leader>fb" = {
        action = "buffers";
        desc = "buffers";
      };
      "<leader>/" = {
        action = "live_grep";
        desc = "live grep";
      };
      "<leader>gs" = {
        action = "git_status";
        desc = "git status";
      };
      "<leader>fk" = keymaps_bind;
      "<leader>fm" = keymaps_bind;
      "<leader>fp" = {
        action = "pickers";
        desc = "pickers (history)";
      };
      "<leader>fo" = {
        action = "oldfiles";
        desc = "old files";
      };
    };
  };
  plugins.which-key.registrations = {
      "<leader>f"= "Find";
  };
}
