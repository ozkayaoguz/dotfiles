vim.g.mapleader = " "

-- move selected lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- append the next line to the current line without moving the cursor
vim.keymap.set("n", "J", "mzJ`z")

-- keep the cursor in the middle while moving up and down
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- keep the cursor in the middle while searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- replace selection with the copied value without losing the copied value
vim.keymap.set("x", "<leader>p", [["_dP]])

-- copy to the system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])

vim.keymap.set("n", "<C-h>", "<C-w>h") -- go to the left window
vim.keymap.set("n", "<C-l>", "<C-w>l") -- go to the right window
vim.keymap.set("n", "<C-j>", "<C-w>j") -- go to the down window
vim.keymap.set("n", "<C-k>", "<C-w>k") -- go to the up window

vim.keymap.set("n", "<M-l>", [[<cmd>vertical resize +5<cr>]]) -- make the window biger vertically
vim.keymap.set("n", "<M-h>", [[<cmd>vertical resize -5<cr>]]) -- make the window smaller vertically
vim.keymap.set("n", "<M-k>", [[<cmd>horizontal resize +2<cr>]]) -- make the window bigger horizontally
vim.keymap.set("n", "<M-j>", [[<cmd>horizontal resize -2<cr>]]) -- make the window smaller horizontally
