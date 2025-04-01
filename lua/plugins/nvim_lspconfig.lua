return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "folke/neoconf.nvim", lazy = true, opts = {} },
    {
      "williamboman/mason-lspconfig.nvim",
      dependencies = { "williamboman/mason.nvim" },
      opts = function(_, opts)
        opts.ensure_installed = { "lua_ls", "rust_analyzer", "taplo", "clangd", "basedpyright", "html", "cssls",
          "emmet_ls" }

        local capabilities = require('blink.cmp').get_lsp_capabilities()

        local skipped = {}
        for _, lsp in ipairs(require("bridge").no_auto_lsp_setup) do
          -- vim.notify(lsp .. "skipped")
          skipped[lsp] = function() end
        end

        require("mason-lspconfig").setup_handlers(vim.tbl_deep_extend("error", {
          -- The first entry (without a key) will be the default handler
          -- and will be called for each installed server that doesn't have
          -- a dedicated handler.
          function(server_name) -- default handler (optional)
            require("lspconfig")[server_name].setup {
              capabilities = capabilities,
              settings = {
                basedpyright = {
                  analysis = {
                    typeCheckingMode = "off",
                    autoImportCompletions = true,
                    diagnosticSeverityOverrides = {
                      reportUndefinedVariable = "error",
                      reportUnusedImport = "information",
                      reportUnusedFunction = "information",
                      reportUnusedVariable = "information",
                      reportGeneralTypeIssues = "none",
                      reportOptionalMemberAccess = "none",
                      reportOptionalSubscript = "none",
                      reportPrivateImportUsage = "none",
                    },
                  },
                },
              }
            }
          end,
          -- Next, you can provide a dedicated handler for specific servers.
          -- For example, a handler override for the `rust_analyzer`:
          -- ["rust_analyzer"] = function ()
          --   require("rust-tools").setup {}
          -- end
        }, skipped))
      end,
    },
  },
  init = function()
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = require("icons").DiagnosticError,
          [vim.diagnostic.severity.HINT] = require("icons").DiagnosticHint,
          [vim.diagnostic.severity.INFO] = require("icons").DiagnosticInfo,
          [vim.diagnostic.severity.WARN] = require("icons").DiagnosticWarn,
        },
      },
      virtual_text = true,
      virtual_lines = false,
      severity_sort = true,
    })

    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local buf = event.buf

        if client and client:supports_method("textDocument/codeLens", buf) then
          vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave", "BufEnter" }, {
            desc = "Refresh codelens (buffer)",
            callback = function(args)
              vim.lsp.codelens.refresh({ bufnr = args.buf })
            end,
          })
        end

        local mappings = {
          { { "n", "x" }, "<leader>la", function() vim.lsp.buf.code_action() end, desc = "LSP code action",       cond = "textDocument/codeAction" },
          {
            "n",
            "<leader>lA",
            function() vim.lsp.buf.code_action { context = { only = { "source" }, diagnostics = {} } } end,
            desc = "LSP source action",
            cond = "textDocument/codeAction"
          },
          -- use conform.nvim to format, which will fallback to lsp
          -- { "n",          "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, desc = "Format buffer",         cond = "textDocument/formatting" },
          -- { "v",          "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, desc = "Format buffer",         cond = "textDocument/rangeFormatting" },
          { "n",          "<Leader>lr", function() vim.lsp.buf.rename() end,      desc = "Rename current symbol", cond = "textDocument/rename" },
        }

        for _, mapping in ipairs(mappings) do
          if mapping.cond and client and client:supports_method(mapping.cond, buf) then
            local opts = { buffer = buf, desc = mapping.desc }
            vim.keymap.set(mapping[1], mapping[2], mapping[3], opts)
          end
        end
      end,
    })
  end
}
