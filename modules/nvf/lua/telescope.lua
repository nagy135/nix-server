local telescope = require("telescope")
local telescope_actions = require("telescope.actions")
local builtin = require("telescope.builtin")

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = telescope_actions.move_selection_next,
        ["<C-k>"] = telescope_actions.move_selection_previous,
        ["<C-s>"] = telescope_actions.select_horizontal,
        ["<C-v>"] = telescope_actions.select_vertical,
        ["<C-t>"] = telescope_actions.select_tab,
        ["<C-q>"] = telescope_actions.send_selected_to_qflist + telescope_actions.open_qflist,
        ["<C-a>"] = telescope_actions.send_to_qflist + telescope_actions.open_qflist,
        ["<C-x>"] = "delete_buffer",
      },
      n = {
        ["<C-s>"] = telescope_actions.select_horizontal,
        ["<C-t>"] = telescope_actions.select_tab,
        ["<C-x>"] = "delete_buffer",
      },
    },
  },
  extensions = {
    ["ui-select"] = require("telescope.themes").get_dropdown(),
  },
})

pcall(telescope.load_extension, "fzf")
pcall(telescope.load_extension, "ui-select")
pcall(telescope.load_extension, "file_browser")

vim.keymap.set("n", "<leader>fn", function()
  telescope.extensions.file_browser.file_browser({ cwd = "%:h" })
end, { desc = "[F]ind [N]eighbor" })

vim.keymap.set("n", "<leader>s/", builtin.current_buffer_fuzzy_find, { desc = "[/] Fuzzily search in current buffer" })
vim.keymap.set("n", "<leader>sg", function()
  builtin.live_grep({
    grep_open_files = true,
    prompt_title = "Live Grep in Open Files",
  })
end, { desc = "Search [/] in Open Files" })

vim.keymap.set("n", "<leader>sn", function()
  builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })
