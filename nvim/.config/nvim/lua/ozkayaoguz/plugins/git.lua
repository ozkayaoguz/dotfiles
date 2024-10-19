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
                signs_staged_enable = false,
                current_line_blame = true,
                attach_to_untracked = true,
            })

            vim.keymap.set("n", "<leader>gh", ":Gitsigns preview_hunk<CR>")
            vim.keymap.set("n", "<leader>gr", ":Gitsigns reset_hunk<CR>")
            vim.keymap.set("n", "<leader>gn", ":Gitsigns next_hunk<CR>")
            vim.keymap.set("n", "<leader>gp", ":Gitsigns prev_hunk<CR>")
        end,
    },
}
