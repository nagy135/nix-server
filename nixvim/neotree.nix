{
  plugins.neo-tree = {
    enable = true;
    addBlankLineAtTop = true;
    window.mappings = {
      v = "open_vsplit";
      s = "open_split";
    };
  };
  keymaps = [
    {
      action = "<cmd>Neotree reveal toggle<CR>";
      key = "<leader>e";
    }
  ];
}
