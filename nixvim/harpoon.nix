{
  plugins.harpoon = {
    enable = true;
    enableTelescope = true;
  };
  plugins.which-key.registrations = {
      "<leader>h"= "Harpoon";
  };
  keymaps = [
    {
      action = ''<cmd>lua require('harpoon.mark').add_file()<CR>'';
      key = "<leader>ha";
      options = {
        desc = "Add file";
      };
    }
    {
      action = ''<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>'';
      key = "<leader>hh";
      options = {
        desc = "Toggle quick menu";
      };
    }
    {
      action = ''<cmd>lua local index = vim.fn.input("Harpoon: ")
    if index == nil or index == "" then
        return
    end
    require('harpoon.ui').nav_file(tonumber(index))<CR>
      '';
      key = "<leader>hi";
      options = {
        desc = "Select with input";
      };
    }
  ];
}
