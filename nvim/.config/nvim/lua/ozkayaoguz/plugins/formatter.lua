return {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
        },
        format_on_save = false,
    },
    keys = {
        {
            "<leader>df",
            function()
                require("conform").format({ async = true, lsp_format = "fallback" })
            end,
            desc = "Format buffer",
        },
    },
}
