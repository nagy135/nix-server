require("mini.ai").setup({ n_lines = 500 })

require("mini.surround").setup({
	mappings = {
		add = "gsa",
		delete = "ds",
		find = "gsf",
		find_left = "gsF",
		highlight = "gsh",
		replace = "cs",
		update_n_lines = "gsn",
		suffix_last = "l",
		suffix_next = "n",
	},
})

local statusline = require("mini.statusline")
statusline.setup({ use_icons = vim.g.have_nerd_font })
statusline.section_location = function()
	return "%2l:%-2v"
end

require("mini.files").setup({
	options = {
		use_as_default_explorer = false,
	},
	windows = {
		preview = true,
		width_preview = 60,
	},
})

require("mini.diff").setup()
require("mini.pick").setup()
