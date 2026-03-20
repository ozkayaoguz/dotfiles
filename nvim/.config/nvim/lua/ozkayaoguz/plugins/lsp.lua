return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        {
            "saghen/blink.cmp",
            version = "1.*",
            opts = {
                keymap = {
                    preset = "default",
                    ["<CR>"] = { "accept", "fallback" },
                },
                appearance = { use_nvim_cmp_as_default = false },
                sources = {
                    default = { "lsp", "path", "snippets", "buffer" },
                },
                completion = {
                    documentation = { auto_show = true },
                },
            },
        },
        "j-hui/fidget.nvim",
    },
    config = function()
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
            callback = function(event)
                local opts = { buffer = event.buf }
                local builtin = require("telescope.builtin")

                vim.keymap.set("n", "gd", function() builtin.lsp_definitions() end, opts)
                vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts)
                vim.keymap.set("n", "gr", function() builtin.lsp_references() end, opts)
                vim.keymap.set("n", "gI", function() builtin.lsp_implementations() end, opts)
                vim.keymap.set("n", "<leader>D", function() builtin.lsp_type_definitions() end, opts)
                vim.keymap.set("n", "<leader>ds", function() builtin.lsp_document_symbols() end, opts)
                vim.keymap.set("n", "<leader>dd", function() builtin.diagnostics({ bufnr = 0 }) end, opts)
                vim.keymap.set("n", "<leader>ws", function() builtin.lsp_dynamic_workspace_symbols() end, opts)
                vim.keymap.set("n", "<leader>wd", function() builtin.diagnostics() end, opts)
                vim.keymap.set("n", "<leader>r", function() vim.lsp.buf.rename() end, opts)
                vim.keymap.set({ "n", "v" }, "<leader>a", function() vim.lsp.buf.code_action() end, opts)
                vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
                vim.keymap.set("n", "<leader>q", function() vim.diagnostic.open_float() end, opts)

                vim.keymap.set("n", "<leader>i", function()
                    vim.lsp.inlay_hint.enable(
                        not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }),
                        { bufnr = event.buf }
                    )
                end, opts)

                -- Built-in LSP document highlighting (replaces vim-illuminate)
                vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                    buffer = event.buf,
                    callback = vim.lsp.buf.document_highlight,
                })
                vim.api.nvim_create_autocmd("CursorMoved", {
                    buffer = event.buf,
                    callback = vim.lsp.buf.clear_references,
                })
            end,
        })

        require("mason").setup({})
        require("mason-lspconfig").setup({
            ensure_installed = { "lua_ls" },
        })

        local lsp_capabilities = require("blink.cmp").get_lsp_capabilities()

        if vim.fn.has("nvim-0.11") == 0 then
            -- 0.10 fallback: use lspconfig
            local lspconfig = require("lspconfig")
            for _, server_name in ipairs(require("mason-lspconfig").get_installed_servers()) do
                if server_name ~= "lua_ls" then
                    lspconfig[server_name].setup({ capabilities = lsp_capabilities })
                end
            end
            lspconfig.lua_ls.setup({
                capabilities = lsp_capabilities,
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = { globals = { "vim" } },
                        workspace = {
                            library = { vim.env.VIMRUNTIME },
                            checkThirdParty = false,
                        },
                        telemetry = { enable = false },
                    },
                },
            })
        else
            -- 0.11+: native API, forward compatible
            vim.lsp.config("*", { capabilities = lsp_capabilities })
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = { globals = { "vim" } },
                        workspace = {
                            library = { vim.env.VIMRUNTIME },
                            checkThirdParty = false,
                        },
                        telemetry = { enable = false },
                    },
                },
            })
            for _, server_name in ipairs(require("mason-lspconfig").get_installed_servers()) do
                vim.lsp.enable(server_name)
            end
        end

        vim.diagnostic.config({
            virtual_text = true,
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = { border = "rounded" },
        })

        require("fidget").setup({})
    end,
}
