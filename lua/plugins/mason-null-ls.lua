return {
  "jay-babu/mason-null-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "nvimtools/none-ls.nvim",
  },
  opts = {
    ensure_installed = { "black", "isort", "prettierd" },
    methods = {
      diagnostics = true,
      formatting = false, -- use conform.nvim
      code_actions = true,
      completion = true,
      hover = true,
    },
    handlers = {}
  }
}
