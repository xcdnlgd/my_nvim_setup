local mid_mapping = false
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "folke/neoconf.nvim", lazy = true, opts = {} },
    {
      "williamboman/mason-lspconfig.nvim",
      dependencies = { "williamboman/mason.nvim" },
      opts = function(_, opts)
        opts.ensure_installed = { "lua_ls" }

        local capabilities = {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true
            }
          }
        }
        capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)

        require("mason-lspconfig").setup_handlers {
          -- The first entry (without a key) will be the default handler
          -- and will be called for each installed server that doesn't have
          -- a dedicated handler.
          function(server_name) -- default handler (optional)
            require("lspconfig")[server_name].setup {
              capabilities = capabilities
            }
          end,
          -- Next, you can provide a dedicated handler for specific servers.
          -- For example, a handler override for the `rust_analyzer`:
          -- ["rust_analyzer"] = function ()
          --   require("rust-tools").setup {}
          -- end
        }
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

    -- auto clear hlsearch
    local ns = vim.api.nvim_create_namespace("auto_hlsearch")
    vim.on_key(function(char)
      if vim.fn.mode() == "n" and not mid_mapping then
        local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
        if vim.o.hlsearch ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
        mid_mapping = true
        vim.schedule(function() mid_mapping = false end)
      end
    end, ns)

    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local buf = event.buf

        local mappings = {
          { { "n", "x" }, "<leader>la", function() vim.lsp.buf.code_action() end,            desc = "LSP code action",       cond = "textDocument/codeAction" },
          {
            "n",
            "<leader>lA",
            function() vim.lsp.buf.code_action { context = { only = { "source" }, diagnostics = {} } } end,
            desc = "LSP source action",
            cond = "textDocument/codeAction"
          },
          { "n",          "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, desc = "Format buffer",         cond = "textDocument/formatting" },
          { "v",          "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, desc = "Format buffer",         cond = "textDocument/rangeFormatting" },
          { "n",          "<Leader>lr", function() vim.lsp.buf.rename() end,                 desc = "Rename current symbol", cond = "textDocument/rename" },
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
