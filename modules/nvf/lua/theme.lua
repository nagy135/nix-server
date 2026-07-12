vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.cmd.colorscheme("gruvbox-material")

local function apply_gruvbox_diff_highlights()
  if vim.g.colors_name ~= "gruvbox-material" then
    return
  end

  local highlights = {
    DiffAdd = { bg = "#32361a" },
    DiffChange = { bg = "#1f3437" },
    DiffDelete = { bg = "#3c1f1e" },
    DiffText = { bg = "#16404a" },
  }

  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

apply_gruvbox_diff_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "gruvbox-material",
  callback = apply_gruvbox_diff_highlights,
})
