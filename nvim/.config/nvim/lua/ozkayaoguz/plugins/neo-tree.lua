return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
        require("neo-tree").setup({
            close_if_last_window = true,
            resize_timer_interval = 1000,
            sources = { "filesystem", "buffers", "git_status", "document_symbols" },
            source_selector = {
                winbar = true,
                sources = {
                    { source = "filesystem" },
                    { source = "buffers" },
                    { source = "remote" },
                },
            },
            open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
            filesystem = {
                bind_to_cwd = true,
                follow_current_file = { enabled = true },
                use_libuv_file_watcher = true,
                hijack_netrw_behavior = "disabled",
            },
            window = {
                position = "left",
                width = 30,
                mappings = {
                    ["<s-Tab>"] = "prev_source",
                    ["<Tab>"] = "next_source",
                },
            },
            default_component_configs = {
                indent = {
                    with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
                    expander_collapsed = "",
                    expander_expanded = "",
                    expander_highlight = "NeoTreeExpander",
                },
            },
        })

        vim.keymap.set("n", "<leader>n", ":Neotree focus<CR>", {})
        vim.keymap.set("n", "<leader>b", ":Neotree focus buffers<CR>", {})
    end,
}
