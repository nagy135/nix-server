{...}: {
  config.vim = {
    languages.typescript = {
      enable = true;
      lsp.servers = ["typescript-language-server"];
    };

    lsp.servers.typescript-language-server.filetypes = [
      "typescript"
      "javascript"
      "typescriptreact"
      "javascriptreact"
    ];
  };
}
