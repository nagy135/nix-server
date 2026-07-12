{pkgs, ...}: {
  config.vim = {
    lazy.plugins."claudecode.nvim" = {
      package = pkgs.vimPlugins.claudecode-nvim;
      lazy = false;
      setupModule = "claudecode";
      setupOpts = {};
    };

    keymaps = [
      {
        key = "<leader>ac";
        mode = "n";
        silent = true;
        desc = "Toggle Claude";
        action = "<cmd>ClaudeCode<CR>";
      }
      {
        key = "<leader>af";
        mode = "n";
        silent = true;
        desc = "Focus Claude";
        action = "<cmd>ClaudeCodeFocus<CR>";
      }
      {
        key = "<leader>ar";
        mode = "n";
        silent = true;
        desc = "Resume Claude";
        action = "<cmd>ClaudeCode --resume<CR>";
      }
      {
        key = "<leader>aC";
        mode = "n";
        silent = true;
        desc = "Continue Claude";
        action = "<cmd>ClaudeCode --continue<CR>";
      }
      {
        key = "<leader>am";
        mode = "n";
        silent = true;
        desc = "Select Claude model";
        action = "<cmd>ClaudeCodeSelectModel<CR>";
      }
      {
        key = "<leader>ab";
        mode = "n";
        silent = true;
        desc = "Add current buffer";
        action = "<cmd>ClaudeCodeAdd %<CR>";
      }
      {
        key = "<leader>as";
        mode = "v";
        silent = true;
        desc = "Send to Claude";
        action = "<cmd>ClaudeCodeSend<CR>";
      }
      {
        key = "<leader>as";
        mode = "n";
        silent = true;
        desc = "Add file";
        action = "<cmd>ClaudeCodeTreeAdd<CR>";
      }
      {
        key = "<leader>aa";
        mode = "n";
        silent = true;
        desc = "Accept diff";
        action = "<cmd>ClaudeCodeDiffAccept<CR>";
      }
      {
        key = "<leader>ad";
        mode = "n";
        silent = true;
        desc = "Deny diff";
        action = "<cmd>ClaudeCodeDiffDeny<CR>";
      }
    ];

    luaConfigRC.claudecodeWhichKey = ''
      local wk = require("which-key")

      wk.add({
        { "<leader>a", group = "AI/Claude Code" },
      })
    '';
  };
}
