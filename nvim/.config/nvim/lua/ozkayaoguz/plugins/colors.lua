return {
    {
        "sainnhe/gruvbox-material",
        lazy = false,
        priority = 1000,
        config = function()
            vim.g.gruvbox_material_background = "hard"
            vim.g.gruvbox_material_foreground = "mix"
            vim.g.gruvbox_material_ui_contrast = "high"
            vim.g.gruvbox_material_better_performance = 1
            vim.g.gruvbox_material_transparent_background = 2

            vim.cmd("colorscheme gruvbox-material")
        end,
    },
    {
        "navarasu/onedark.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("onedark").setup({
                style = "warmer",
                transparent = true,
            })

            -- vim.cmd("colorscheme onedark")
        end,
    },
}
