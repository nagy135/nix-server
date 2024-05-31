{
  plugins.flash = {
    enable = true;
  };
  keymaps = [
    {
      key = "s";
      action = "<cmd>lua require('flash').jump()<CR>";
      options = {
        desc = "Flash jump";
      };
    }
    {
      key = "S";
      action = "<cmd>lua require('flash').treesitter()<CR>";
      options = {
        desc = "Flash treesitter";
      };
    }
  ];
}
