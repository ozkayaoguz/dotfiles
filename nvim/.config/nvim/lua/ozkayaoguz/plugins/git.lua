return {
    {
        "tpope/vim-fugitive",
        config = function()
            vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                current_line_blame = true,
            })

            vim.keymap.set("n", "<leader>gh", ":Gitsigns preview_hunk<CR>")
            vim.keymap.set("n", "<leader>gn", ":Gitsigns next_hunk<CR>")
            vim.keymap.set("n", "<leader>gp", ":Gitsigns prev_hunk<CR>")
        end,
    },
}
