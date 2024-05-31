{
  plugins.gitsigns = {
    enable = true;

    settings.on_attach = ''
      function(bufnr)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', ']h', '<cmd>Gitsigns next_hunk<CR>', {})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '[h', '<cmd>Gitsigns prev_hunk<CR>', {})

        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ghs', '<cmd>lua require"gitsigns".stage_hunk()<CR>', {})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ghr', '<cmd>lua require"gitsigns".reset_hunk()<CR>', {})

        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ghS', '<cmd>lua require"gitsigns".stage_buffer()<CR>', {})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ghR', '<cmd>lua require"gitsigns".reset_buffer()<CR>', {})
      end
  '';
  };
}
