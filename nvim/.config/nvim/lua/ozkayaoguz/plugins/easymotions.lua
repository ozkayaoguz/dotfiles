return {
	"smoka7/hop.nvim",
	version = "*",
	config = function()
		local hop = require("hop")
		local directions = require("hop.hint").HintDirection

		hop.setup()

		vim.keymap.set({ "n", "v" }, "<leader><leader>w", hop.hint_words, {})
		vim.keymap.set({ "n", "v" }, "<leader><leader>f", hop.hint_char1, {})
		vim.keymap.set({ "n", "v" }, "<leader><leader>/", hop.hint_patterns, {})
		vim.keymap.set({ "n", "v" }, "<leader><leader>j", function()
			hop.hint_lines_skip_whitespace({ direction = directions.AFTER_CURSOR })
		end, {})
		vim.keymap.set({ "n", "v" }, "<leader><leader>k", function()
			hop.hint_lines_skip_whitespace({ direction = directions.BEFORE_CURSOR })
		end, {})
	end,
}
