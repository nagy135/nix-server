{...}: {
  config.vim.languages.go = {
    enable = true;

    lsp.enable = true;
    treesitter.enable = true;

    format = {
      enable = true;
      type = ["goimports"];
    };

    extraDiagnostics.enable = true;
    dap.enable = true;
  };
}
