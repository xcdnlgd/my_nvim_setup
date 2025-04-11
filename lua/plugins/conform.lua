vim.keymap.set({ "n", "v" }, "<leader>lf", function() require("conform").format() end, { desc = "Format buffer" })
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      python = { "ruff_organize_imports", "ruff_format" },
      rust = { "rustfmt" },
      html = { "prettierd" },
      css = { "prettierd" },
      yaml = { "prettierd" },
    },
    default_format_opts = {
      lsp_format = "fallback",
    },
  },
}
