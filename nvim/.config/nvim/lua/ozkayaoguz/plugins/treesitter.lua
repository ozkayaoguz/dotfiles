return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter",
    opts = {
        ensure_installed = { "vimdoc", "lua", "vim" },
        sync_install = false,
        auto_install = true,
        indent = { enable = true },
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = { "markdown" },
        },
    },
}
