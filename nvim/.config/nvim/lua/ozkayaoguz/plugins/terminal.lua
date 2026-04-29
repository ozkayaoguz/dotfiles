return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {
		open_mapping = [[<C-t>]],
		insert_mappings = true,
		terminal_mappings = true,
		start_in_insert = true,
		persist_size = true,
		direction = "horizontal",
		size = function(term)
			if term.direction == "vertical" then
				return vim.o.columns * 0.4
			else
				return 15
			end
		end,
	},
	config = function(_, opts)
		require("toggleterm").setup(opts)

		local Terminal = require("toggleterm.terminal").Terminal
		local git_terminal = Terminal:new({ cmd = "gitui", hidden = true, direction = "float" })

		function _git_terminal_toggle()
			git_terminal:toggle()
		end

		vim.api.nvim_set_keymap(
			"n",
			"<leader>gt",
			"<cmd>lua _git_terminal_toggle()<CR>",
			{ noremap = true, silent = true }
		)
		vim.keymap.set("n", "<leader>ts", "<cmd>TermSelect<cr>", { desc = "Terminal select" })
		vim.keymap.set("t", "<leader><Esc>", [[<C-\><C-n>]], { desc = "Terminal normal mod" })
	end,
}
