{...}: {
  config.vim.keymaps = [
    {
      key = "<Esc>";
      mode = "n";
      silent = true;
      action = "<cmd>nohlsearch<CR>";
    }
    {
      key = "<Esc><Esc>";
      mode = "t";
      silent = true;
      desc = "Exit terminal mode";
      action = "<C-\\><C-n>";
    }
    {
      key = "<M-BS>";
      mode = "i";
      silent = true;
      desc = "Delete word to the left";
      action = "<C-w>";
    }
    {
      key = "]d";
      mode = "n";
      silent = true;
      desc = "Go to next diagnostic";
      action = "<cmd>lua vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, wrap = true, float = true })<CR>";
    }
    {
      key = "[d";
      mode = "n";
      silent = true;
      desc = "Go to previous diagnostic";
      action = "<cmd>lua vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, wrap = true, float = true })<CR>";
    }
    {
      key = "]D";
      mode = "n";
      silent = true;
      desc = "Go to next diagnostic";
      action = "<cmd>lua vim.diagnostic.jump({ count = 1, float = true })<CR>";
    }
    {
      key = "[D";
      mode = "n";
      silent = true;
      desc = "Go to previous diagnostic";
      action = "<cmd>lua vim.diagnostic.jump({ count = -1, float = true })<CR>";
    }
    {
      key = "<leader>q";
      mode = "n";
      silent = true;
      desc = "Open diagnostic [Q]uickfix list";
      action = "<cmd>lua vim.diagnostic.setloclist()<CR>";
    }
    {
      key = "<leader>clf";
      mode = "n";
      silent = true;
      desc = "Open diagnostic float";
      action = "<cmd>lua vim.diagnostic.open_float()<CR>";
    }
    {
      key = ";";
      mode = "n";
      action = ":";
    }
    {
      key = "<leader>y";
      mode = "n";
      silent = true;
      action = "<cmd>silent !bash -n % | pbcopy<CR>";
    }
    {
      key = "<leader>A";
      mode = "n";
      silent = true;
      desc = "Copy file:line reference";
      action = "<cmd>lua vim.fn.setreg('+', string.format('%s:%d %s', vim.fn.expand('%'), vim.fn.line('.'), vim.fn.getline('.')))<CR>";
    }
    {
      key = ",j";
      mode = "n";
      silent = true;
      desc = "Move line down";
      action = "<cmd>move .+1<CR>==";
    }
    {
      key = ",k";
      mode = "n";
      silent = true;
      desc = "Move line up";
      action = "<cmd>move .-2<CR>==";
    }
  ];
}
