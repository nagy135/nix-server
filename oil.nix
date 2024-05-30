{
  plugins.oil = {
    enable = true;
    settings = {
      view_options = {
        show_hidden = true;
      };
      skip_confirm_for_simple_edits = true;
      columns = [
        "icon"
        # "permissions"
        # "size"
        # "mtime"
      ];
    };
  };
  keymaps = [
    {
      key = "-";
      action = "<cmd>Oil<cr>";
    }
  ];
}
