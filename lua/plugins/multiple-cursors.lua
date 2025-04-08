return {
  "brenton-leighton/multiple-cursors.nvim",
  version = "*",
  opts = {
    pre_hook = function()
      require("blink.pairs.mappings").disable()
    end,
    post_hook = function()
      require("blink.pairs.mappings").enable()
    end,
  },
  keys = {
    {
      "<C-n>",
      function()
        local line = vim.fn.line(".")
        local col = vim.fn.col(".")
        local start_pos = vim.fn.searchpos("\\<", "cbWn", line)
        if start_pos[1] == line then
          if start_pos[2] ~= col then
            vim.cmd("normal b") -- first move cursor to the beginning of the word, more robust
          end
        end
        vim.cmd("MultipleCursorsAddJumpNextMatch")
        if start_pos[1] == line then
          if start_pos[2] ~= col then
            local offset = col - start_pos[2]
            vim.cmd("normal" .. tostring(offset) .. "l") -- move cursor back
          end
        end
      end,
      mode = "n",
      desc = "Add cursor and jump to next cword",
    },
    { "<C-n>",         "<Cmd>MultipleCursorsAddJumpNextMatch<CR>", mode = "x",          desc = "Add cursor and jump to next cword" },
    { "<C-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>",   mode = { "n", "i" }, desc = "Add or remove cursor" },
    { "<M-C-k>",       "<Cmd>MultipleCursorsAddUp<CR>",            mode = { "n", "x" }, desc = "Add cursor and move up" },
    { "<M-C-j>",       "<Cmd>MultipleCursorsAddDown<CR>",          mode = { "n", "x" }, desc = "Add cursor and move down" },
  },
}
