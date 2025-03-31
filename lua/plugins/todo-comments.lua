return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  init = function()
    vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next TODO comment" })
    vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous TODO comment" })
  end,
  opts = {}
}
