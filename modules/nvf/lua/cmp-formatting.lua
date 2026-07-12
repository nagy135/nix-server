require("conform").setup({
	notify_on_error = false,
	format_on_save = function(bufnr)
		local disable_filetypes = { c = true, cpp = true }
		local lsp_format_opt = disable_filetypes[vim.bo[bufnr].filetype] and "never" or "fallback"
		return {
			timeout_ms = 500,
			lsp_format = lsp_format_opt,
		}
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "isort", "black" },
		typescript = { "prettierd", stop_after_first = true },
		typescriptreact = { "prettierd", stop_after_first = true },
		javascript = { "prettierd", stop_after_first = true },
		javascriptreact = { "prettierd", stop_after_first = true },
	},
})

local lint = require("lint")

local function ignore_node_warning_preamble(linter_name)
	local linter = lint.linters[linter_name]
	if not linter or type(linter.parser) ~= "function" then
		return
	end

	local parser = linter.parser
	linter.parser = function(output, bufnr, ...)
		local json_start = output and output:find("%[")
		if json_start and output:sub(1, json_start - 1):match("^%s*%(node:%d+%) Warning:") then
			output = output:sub(json_start)
		end

		return parser(output, bufnr, ...)
	end
end

ignore_node_warning_preamble("eslint")
ignore_node_warning_preamble("eslint_d")

lint.linters_by_ft.markdown = nil
lint.linters_by_ft.rst = nil
-- lint.linters_by_ft.typescript = nil
-- lint.linters_by_ft.typescriptreact = nil
lint.linters_by_ft.text = nil
