{
  plugins.undotree = {
    enable = true;
  };
  plugins.which-key.registrations = {
      "<leader>u"= "Undotree";
  };
  keymaps = [
    {
      action = ''<cmd>UndotreeToggle<CR>'';
      key = "<leader>uu";
      options = {
        desc = "toggle";
      };
    }
    {
      action = ''<cmd>UndotreeFocus<CR>'';
      key = "<leader>uf";
      options = {
        desc = "focus";
      };
    }
  ];
}
