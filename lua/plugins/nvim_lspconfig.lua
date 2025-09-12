return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "folke/neoconf.nvim", lazy = true, opts = {} },
    {
      "williamboman/mason-lspconfig.nvim",
      dependencies = { "williamboman/mason.nvim" },
      opts = function(_, opts)
        vim.lsp.enable("gdscript")
        opts.ensure_installed = { "lua_ls", "rust_analyzer", "taplo", "clangd", "basedpyright", "ruff", "html", "cssls",
          "emmet_ls", "jsonls", "yamlls", "gopls", "eslint", "vtsls" }
        opts.automatic_enable = {
          exclude = {
            "rust_analyzer",
          }
        }

        vim.lsp.config('clangd', {
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        })
        vim.lsp.config("ruff", {
          init_options = {
            settings = {
              lint = {
                ignore = { "F403", "F405" }
              }
            }
          }
        })
        vim.lsp.config("basedpyright", {
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
        })

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

        -- folding https://github.com/patricorgi/dotfiles/blob/main/.config/nvim/lua/custom/config/folding.lua
        if client and client:supports_method 'textDocument/foldingRange' then
          local win = vim.api.nvim_get_current_win()
          vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
        end
      end,
    })
  end
}
