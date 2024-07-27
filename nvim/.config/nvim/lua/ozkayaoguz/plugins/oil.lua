return {
    "stevearc/oil.nvim",
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("oil").setup({
            -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
            -- Set to false if you still want to use netrw.
            default_file_explorer = true,
            columns = {
                "icon",
                "size",
                -- "permissions",
                -- "mtime",
            },
            keymaps = {
                ["<C-h>"] = false,
                ["-"] = false,
                ["<BS>"] = "actions.parent",
            },
            view_options = {
                show_hidden = false,
                is_hidden_file = function(name)
                    return (name ~= "..") and vim.startswith(name, ".")
                end,
            },
        })

        vim.keymap.set("n", "<leader><BS>", ":Oil<CR>", {})
    end,
}
