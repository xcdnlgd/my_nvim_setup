return {
  "brenton-leighton/multiple-cursors.nvim",
  version = "*",
  opts = {
    pre_hook = function()
      require("nvim-autopairs").disable()
    end,
    post_hook = function()
      require("nvim-autopairs").enable()
    end,
  },
  keys = {
    {
      "<C-n>",
      "<Cmd>MultipleCursorsAddJumpNextMatch<CR>",
      mode = { "n", "x" },
      desc = "Add cursor and jump to next cword",
    },
    { "<C-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>", mode = { "n", "i" }, desc = "Add or remove cursor" },
    { "<M-C-k>", "<Cmd>MultipleCursorsAddUp<CR>", mode = { "n", "x" }, desc = "Add cursor and move up" },
    { "<M-C-j>", "<Cmd>MultipleCursorsAddDown<CR>", mode = { "n", "x" }, desc = "Add cursor and move down" },
  },
}
