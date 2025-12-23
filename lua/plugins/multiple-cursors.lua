local keep_cursor_pos = function(cmd_str)
  local line = vim.fn.line(".")
  local col = vim.fn.col(".")
  local start_pos = vim.fn.searchpos("\\<", "cbWn", line)
  local need_to_keep = start_pos[1] == line and start_pos[2] ~= col; -- word_start at the same line and not the current column
  if need_to_keep then
    vim.cmd("normal b")                                              -- first move cursor to the beginning of the word, more robust
    vim.cmd(cmd_str)
    local offset = col - start_pos[2]
    vim.cmd("normal" .. tostring(offset) .. "l") -- move cursor back
  else
    vim.cmd(cmd_str)
  end
end

return {
  "brenton-leighton/multiple-cursors.nvim",
  version = "*",
  opts = {
    pre_hook = function()
      vim.g.minipairs_disable = true
      -- require("blink.pairs.mappings").disable()
    end,
    post_hook = function()
      vim.g.minipairs_disable = false
      -- require("blink.pairs.mappings").enable()
    end,
    custom_key_maps = {
      { "n", "|", function() require("multiple-cursors").align() end },
    },
  },
  cmd = {
    "MultipleCursorsAddDown",
    "MultipleCursorsAddUp",
    "MultipleCursorsMouseAddDelete",
    "MultipleCursorsAddVisualArea",
    "MultipleCursorsAddMatches",
    "MultipleCursorsAddMatchesV",
    "MultipleCursorsAddJumpNextMatch",
    "MultipleCursorsJumpNextMatch",
    "MultipleCursorsAddJumpPrevMatch",
    "MultipleCursorsJumpPrevMatch",
  },
  keys = {
    {
      "<C-p>",
      function()
        keep_cursor_pos("MultipleCursorsAddJumpPrevMatch")
      end,
      mode = "n",
      desc = "Add cursor and jump to previous word",
    },
    {
      "<M-C-p>",
      function()
        keep_cursor_pos("MultipleCursorsJumpPrevMatch")
      end,
      mode = "n",
      desc = "Jump to previous word",
    },
    {
      "<C-n>",
      function()
        keep_cursor_pos("MultipleCursorsAddJumpNextMatch")
      end,
      mode = "n",
      desc = "Add cursor and jump to next word",
    },
    {
      "<M-C-n>",
      function()
        keep_cursor_pos("MultipleCursorsJumpNextMatch")
      end,
      mode = "n",
      desc = "Jump to next word",
    },
    { "<C-n>",         "<Cmd>MultipleCursorsAddJumpNextMatch<CR>", mode = "x",          desc = "Add cursor and jump to next word" },
    { "<M-C-n>",       "<Cmd>MultipleCursorsJumpNextMatch<CR>",    mode = "x",          desc = "Jump to next word" },
    { "<C-p>",         "<Cmd>MultipleCursorsAddJumpPrevMatch<CR>", mode = "x",          desc = "Add cursor and jump to previous word" },
    { "<M-C-p>",       "<Cmd>MultipleCursorsJumpPrevMatch<CR>",    mode = "x",          desc = "Jump to previous word" },
    { "<C-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>",   mode = { "n", "i" }, desc = "Add or remove cursor" },
    { "<M-C-k>",       "<Cmd>MultipleCursorsAddUp<CR>",            mode = { "n", "x" }, desc = "Add cursor and move up" },
    { "<M-C-j>",       "<Cmd>MultipleCursorsAddDown<CR>",          mode = { "n", "x" }, desc = "Add cursor and move down" },
  },
}
