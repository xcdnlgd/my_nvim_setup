return {
  "akinsho/toggleterm.nvim",
  cmd = { "ToggleTerm", "TermExec" },
  init = function()
    vim.keymap.set("n", "<Leader>tf", "<Cmd>ToggleTerm direction=float<CR>", { desc = "ToggleTerm float" })
    vim.keymap.set("n", "<Leader>th", "<Cmd>ToggleTerm size=10 direction=horizontal<CR>",
      { desc = "ToggleTerm horizontal split" })
    vim.keymap.set("n", "<Leader>tv", "<Cmd>ToggleTerm size=80 direction=vertical<CR>",
      { desc = "ToggleTerm vertical split" })
    vim.keymap.set("n", "<C-\\>", '<Cmd>execute v:count . "ToggleTerm"<CR>', { desc = "Toggle terminal" }) -- requires terminal that supports binding <C-\\>
    vim.keymap.set("t", "<C-\\>", "<Cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })                     -- requires terminal that supports binding <C-\\>
    vim.keymap.set("i", "<C-\\>", "<Esc><Cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })                -- requires terminal that supports binding <C-\\>
  end,
  opts = {
    highlights = {
      Normal = { link = "Normal" },
      NormalNC = { link = "NormalNC" },
      NormalFloat = { link = "Normal" },
      FloatBorder = { link = "Normal" },
      StatusLine = { link = "StatusLine" },
      StatusLineNC = { link = "StatusLineNC" },
      WinBar = { link = "WinBar" },
      WinBarNC = { link = "WinBarNC" },
    },
    size = 10,
    on_create = function(t)
      vim.opt_local.foldcolumn = "0"
      vim.opt_local.signcolumn = "no"
      if t.hidden then
        local function toggle() t:toggle() end
        vim.keymap.set({ "n", "t", "i" }, "<C-\\>", toggle, { desc = "Toggle terminal", buffer = t.bufnr })
      end
    end,
    auto_scroll = true,
    on_open = function()
      vim.schedule(function()
        if vim.bo.filetype == "toggleterm" then
          -- FIXME: not robust in TermExec
          -- seems something else do startinsert as well
          vim.cmd.startinsert()
        end
      end)
      vim.wo.spell = false
    end,
    on_close = function()
      vim.wo.spell = true
    end,
    shading_factor = 2,
    float_opts = { border = "rounded" },
    start_in_insert = false -- set in on_open callback
  },
}
