{...}: {
  config.vim.notes = {
    todo-comments.enable = true;
    neorg = {
      enable = true;
      treesitter.enable = true;
      setupOpts = {
        load = {
          "core.defaults".enable = true;
          "core.concealer" = {};
          "core.dirman" = {
            config = {
              workspaces = {
                wiki = "~/wiki";
              };
              default_workspace = "wiki";
            };
          };
        };
      };
    };
  };
}
