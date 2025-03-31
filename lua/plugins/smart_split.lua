local term = vim.trim((vim.env.TERM_PROGRAM or ""):lower())
local mux = term == "tmux" or term == "wezterm" or vim.env.KITTY_LISTEN_ON

return {
  "mrjones2014/smart-splits.nvim",
  lazy = true,
  event = mux and "VeryLazy" or nil, -- load early if mux detected
  init = function()
    vim.keymap.set("n", "<C-H>", function() require("smart-splits").move_cursor_left() end, { desc = "Move to left split" })
    vim.keymap.set("n", "<C-J>", function() require("smart-splits").move_cursor_down() end, { desc = "Move to below split" })
    vim.keymap.set("n", "<C-K>", function() require("smart-splits").move_cursor_up() end, { desc = "Move to above split" })
    vim.keymap.set("n", "<C-L>", function() require("smart-splits").move_cursor_right() end, { desc = "Move to right split" })
    vim.keymap.set("n", "<C-Up>", function() require("smart-splits").resize_up() end, { desc = "Resize split up" })
    vim.keymap.set("n", "<C-Down>", function() require("smart-splits").resize_down() end, { desc = "Resize split down" })
    vim.keymap.set("n", "<C-Left>", function() require("smart-splits").resize_left() end, { desc = "Resize split left" })
    vim.keymap.set("n", "<C-Right>", function() require("smart-splits").resize_right() end, { desc = "Resize split right" })
  end,
  opts = { ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" }, ignored_buftypes = { "nofile" } },
}
