-- TODO: start the shell that starts nvim

local state = {
  current = "bottom",
  floating = {
    buf = -1,
    win = -1,
  },
  bottom = {
    buf = -1,
    win = -1,
  }
}

local exec = vim.fn.has("win32") == 1 and "\r" or "\n"

local open_float_terminal = function(opts)
  opts = opts or {}
  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end

  local get_config = function()
    local width = vim.o.columns
    local height = vim.o.lines

    local horizontal_padding = math.floor(width * 0.1)
    local vertical_padding = math.floor(height * 0.1)

    local win_width = width - 2 * horizontal_padding - 2 -- 2 for border
    local win_height = height - 2 * vertical_padding - 2

    local config = {
      style = "minimal",
      relative = "editor",
      width = win_width,
      height = win_height,
      row = vertical_padding,
      col = horizontal_padding,
      border = "rounded", -- 'none', 'single', 'double', 'rounded', 'solid'
    }
    return config
  end

  local win = vim.api.nvim_open_win(buf, true, get_config())
  vim.wo[win].winhighlight = "Normal:Normal,FloatBorder:Normal"
  if vim.bo[buf].buftype ~= "terminal" then
    vim.cmd.terminal()
    vim.bo[buf].buflisted = false
  end
  vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
      if not win or not vim.api.nvim_win_is_valid(win) then return end
      vim.api.nvim_win_set_config(win, get_config())
    end
  })
  return { buf = buf, win = win }
end

local open_bottom_terminal = function(opts)
  opts = vim.tbl_deep_extend("keep", opts or {}, {
    enter = true
  })
  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end
  local config = {
    style = "minimal",
    height = 10,
    split = "below"
  }
  local win = vim.api.nvim_open_win(buf, opts.enter, config)
  vim.wo[win].winhighlight = "Normal:Normal"
  if vim.bo[buf].buftype ~= "terminal" then
    vim.api.nvim_win_call(win, function()
      vim.cmd.terminal()
      vim.bo[buf].buflisted = false
      vim.keymap.set("t", "<C-k>", function() require("smart-splits").move_cursor_up() end,
        { desc = "Move to above split", buffer = buf })
      vim.keymap.set("t", "<C-j>", function() require("smart-splits").move_cursor_down() end,
        { desc = "Move to above split", buffer = buf })
      vim.keymap.set("n", "[b", "", { buffer = buf })
      vim.keymap.set("n", "]b", "", { buffer = buf })
      vim.api.nvim_create_autocmd("WinEnter", {
        buffer = buf,
        callback = function()
          vim.cmd.startinsert()
        end,
      })
    end)
  end
  return { buf = buf, win = win }
end

vim.api.nvim_create_user_command("ToggleTerm", function()
  if state.current == "floating" then
    if not vim.api.nvim_win_is_valid(state.floating.win) then
      state.floating = open_float_terminal({ buf = state.floating.buf })
      vim.cmd.startinsert()
    else
      vim.api.nvim_win_hide(state.floating.win)
    end
  elseif state.current == "bottom" then
    if not vim.api.nvim_win_is_valid(state.bottom.win) then
      state.bottom = open_bottom_terminal({ buf = state.bottom.buf })
      vim.cmd.startinsert()
    else
      vim.api.nvim_win_hide(state.bottom.win)
    end
  end
end, {})

vim.api.nvim_create_user_command("TermExec", function(v)
  if not vim.api.nvim_win_is_valid(state.bottom.win) then
    state.bottom = open_bottom_terminal({ buf = state.bottom.buf, enter = false })
    vim.api.nvim_win_call(state.bottom.win, function()
      vim.cmd.normal("G") -- auto scroll to bottom
    end)
  end
  vim.fn.chansend(vim.bo[state.bottom.buf].channel, v.args .. exec)
end, { nargs = "+" })

vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Back to normal" })
vim.keymap.set({ "n", "t" }, "<c-\\>", "<cmd>ToggleTerm<cr>", { desc = "Toggle Terminal" })
vim.keymap.set("n", "<Leader>tf", function()
  state.current = "floating"
  vim.cmd("ToggleTerm")
end, { desc = "ToggleTerm float" })
vim.keymap.set("n", "<Leader>th", function()
  state.current = "bottom"
  vim.cmd("ToggleTerm")
end, { desc = "ToggleTerm horizontal split" })
