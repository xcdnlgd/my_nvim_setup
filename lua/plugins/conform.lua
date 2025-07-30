vim.keymap.set({ "n" }, "<leader>lf", function() require("conform").format() end, { desc = "Format buffer" })
vim.keymap.set({ "v" }, "<leader>lf", function()
  require("conform").format()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, true, true), "n", true)
end, { desc = "Format buffer" })
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      python = { "ruff_organize_imports", "ruff_format" },
      rust = { "rustfmt" },
      html = { "prettierd" },
      css = { "prettierd" },
      yaml = { "prettierd" },
      go = { "goimports", lsp_format = "last" },
      javascript = { "prettierd" },
      typescript = { "prettierd" },
    },
    default_format_opts = {
      lsp_format = "fallback",
    },
  },
}
