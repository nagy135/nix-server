{
  plugins = {
    cmp = {
      enable = true;
    };
    cmp-nvim-lsp.enable = true;
    cmp-buffer.enable = true;
    cmp-path.enable = true;
    cmp-cmdline.enable = true;
  };

  # TODO: verify that this works
  keymaps = [
    {
      key = "<C-n>";
      action = ''
              function(fallback)
              if cmp.visible() then
        	cmp.select_next_item()
        	  elseif require("luasnip").expand_or_jumpable() then
        	  require("luasnip").expand_or_jump()
              else
        	fallback()
        	  end
        	  end
        	  '';
      mode = [ "i" "s" ];
    }
    {
      key = "<C-p>";
      action = ''
              function(fallback)
              if cmp.visible() then
        	cmp.select_prev_item()
        	  elseif require("luasnip").expand_or_jumpable() then
        	  require("luasnip").expand_or_jump()
              else
        	fallback()
        	  end
        	  end
        	  '';
      mode = [ "i" "s" ];
    }
  ];
}
