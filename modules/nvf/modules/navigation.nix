{...}: {
  config.vim.keymaps = [
    {
      key = "<C-h>";
      mode = "n";
      silent = true;
      desc = "Move focus to the left window";
      action = "<C-w><C-h>";
    }
    {
      key = "<C-l>";
      mode = "n";
      silent = true;
      desc = "Move focus to the right window";
      action = "<C-w><C-l>";
    }
    {
      key = "<C-j>";
      mode = "n";
      silent = true;
      desc = "Move focus to the lower window";
      action = "<C-w><C-j>";
    }
    {
      key = "<C-k>";
      mode = "n";
      silent = true;
      desc = "Move focus to the upper window";
      action = "<C-w><C-k>";
    }
    {
      key = "<leader>k";
      mode = "n";
      silent = true;
      desc = "Quickfix previous";
      action = "<cmd>cp<CR>";
    }
    {
      key = "<leader>j";
      mode = "n";
      silent = true;
      desc = "Quickfix next";
      action = "<cmd>cn<CR>";
    }
    {
      key = "<C-c>";
      mode = "n";
      silent = true;
      desc = "Quickfix close";
      action = "<cmd>cclose<CR>";
    }
    {
      key = "<leader><C-h>";
      mode = "n";
      silent = true;
      desc = "No highlight";
      action = "<cmd>nohl<CR>";
    }
    {
      key = "<leader>bb";
      mode = "n";
      silent = true;
      desc = "Buffer previous";
      action = "<cmd>e #<CR>";
    }
    {
      key = "<leader>bo";
      mode = "n";
      silent = true;
      desc = "Buffer only";
      action = ''<cmd>%bdelete|edit #|normal`"<CR>'';
    }
    {
      key = "H";
      mode = "n";
      silent = true;
      desc = "[B]uffer [P]revious";
      action = "<cmd>bprev<CR>";
    }
    {
      key = "L";
      mode = "n";
      silent = true;
      desc = "[B]uffer [N]ext";
      action = "<cmd>bnext<CR>";
    }
    {
      key = "<leader>to";
      mode = "n";
      silent = true;
      desc = "Tab only";
      action = "<cmd>tabonly<CR>";
    }
    {
      key = "<leader><tab>o";
      mode = "n";
      silent = true;
      desc = "Tab only";
      action = "<cmd>tabonly<CR>";
    }
    {
      key = "<leader><tab>c";
      mode = "n";
      silent = true;
      desc = "Tab close";
      action = "<cmd>tabc<CR>";
    }
    {
      key = "<leader><tab>d";
      mode = "n";
      silent = true;
      desc = "Tab delete";
      action = "<cmd>tabc<CR>";
    }
    {
      key = "<leader><tab><tab>";
      mode = "n";
      silent = true;
      desc = "Tab open current file";
      action = "<cmd>tabe<CR>";
    }
  ];
}
