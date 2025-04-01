table.insert(require("bridge").no_auto_lsp_setup, "rust_analyzer")
vim.g.rustaceanvim = {
  -- Plugin configuration
  tools = {
    reload_workspace_from_cargo_toml = true,
    on_initialized = function()
      vim.cmd("RustLsp flyCheck") -- NOTE: fixes (when nvim launches, i have to type for diagnostics to show)
      vim.lsp.codelens.refresh()
      vim.cmd("redrawstatus")
    end
  },
  -- LSP configuration
  server = {
    on_attach = function(client, bufnr)
      -- you can also put keymaps in here
    end,
    default_settings = {
      -- rust-analyzer language server configuration
      ['rust-analyzer'] = {
        files = {
          excludeDirs = {
            ".direnv",
            ".git",
            "target",
          },
        },
        check = {
          command = "clippy",
          extraArgs = {
            "--no-deps",
          },
        },
      },
    },
  },
  -- DAP configuration
  dap = {
  },
}
return {
  {
    'saecki/crates.nvim',
    tag = 'stable',
    event = { "BufRead Cargo.toml" },
    config = function()
      -- TODO: buf local keymap
      require('crates').setup({
        neoconf = {
          enabled = true,
        },
        lsp = {
          enabled = true,
          on_attach = function(client, bufnr)
            -- the same on_attach function as for your other lsp's
          end,
          actions = true,
          completion = true,
          hover = true,
        },
      })
    end,
  },
  {
    'mrcjkb/rustaceanvim',
    version = '^5', -- Recommended
    lazy = false,   -- This plugin is already lazy
  },
}
