{
  plugins.lspsaga = {
    enable = true;
    lightbulb.enable = false;
  };
  keymaps = [
    {
      action = ''<cmd>Lspsaga finder<CR>'';
      key = "<leader>lf";
    }
    {
      action = ''<cmd>Lspsaga outline<CR>'';
      key = "<leader>lo";
    }
  ];
}
