vim.diagnostic.config({
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  } or {},
  virtual_text = {
    source = "if_many",
    spacing = 2,
    format = function(diagnostic)
      return diagnostic.message
    end,
  },
})

local lsp_keymaps = {
  { "gd", "n" },
  { "gr", "n" },
  { "gI", "n" },
  { "<leader>D", "n" },
  { "<leader>ds", "n" },
  { "<leader>ws", "n" },
  { "<leader>rn", "n" },
  { "<leader>cr", "n" },
  { "<leader>ca", "n" },
  { "<leader>ca", "x" },
  { "gD", "n" },
  { "<leader>th", "n" },
}

local function is_diffview_active()
  local ok, lib = pcall(require, "diffview.lib")
  return ok and lib.get_current_view and lib.get_current_view() ~= nil
end

local function remove_lsp_keymaps(bufnr)
  for _, keymap in ipairs(lsp_keymaps) do
    for _, existing in ipairs(vim.api.nvim_buf_get_keymap(bufnr, keymap[2])) do
      if existing.lhs == keymap[1] and existing.desc and vim.startswith(existing.desc, "LSP: ") then
        pcall(vim.keymap.del, keymap[2], keymap[1], { buffer = bufnr })
        break
      end
    end
  end
end

vim.api.nvim_create_autocmd("User", {
  pattern = "DiffviewViewOpened",
  callback = function()
    vim.schedule(function()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        remove_lsp_keymaps(vim.api.nvim_win_get_buf(win))
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(event)
    if is_diffview_active() then
      remove_lsp_keymaps(event.buf)
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
  callback = function(event)
    if is_diffview_active() then
      remove_lsp_keymaps(event.buf)
      return
    end

    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    map("gd", function() Snacks.picker.lsp_definitions() end, "[G]oto [D]efinition")
    map("gr", function() Snacks.picker.lsp_references() end, "[G]oto [R]eferences")
    map("gI", function() Snacks.picker.lsp_implementations() end, "[G]oto [I]mplementation")
    map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
    map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
    map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    map("<leader>cr", vim.lsp.buf.rename, "[C]ode [R]ename")
    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
    map("gD", function() Snacks.picker.lsp_declarations() end, "[G]oto [D]eclaration")

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })

      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })
    end

    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
      map("<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, "[T]oggle Inlay [H]ints")
    end

    local navic = require("nvim-navic")
    if client and client.server_capabilities.documentSymbolProvider then
      navic.attach(client, event.buf)
    end
  end,
})

vim.api.nvim_create_user_command("NavicNotify", function()
  local navic = require("nvim-navic")
  if navic.is_available() then
    local location = navic.get_location()
    if location ~= "" then
      vim.notify(location, vim.log.levels.INFO, { title = "Navic Location" })
    else
      vim.notify("No location available", vim.log.levels.WARN, { title = "Navic Location" })
    end
  else
    vim.notify("Navic is not available", vim.log.levels.WARN, { title = "Navic Location" })
  end
end, {})
