local M = {}

M.open_buf = function(bufnr)
  local cur_win = vim.api.nvim_get_current_win()
  local cur_winfixbuf = vim.wo[cur_win].winfixbuf

  -- 如果当前窗口可以替换 buffer，直接使用
  if not cur_winfixbuf then
    vim.api.nvim_win_set_buf(cur_win, bufnr)
    return
  end

  -- 否则，尝试找一个 winfixbuf == false 的窗口
  local found_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if not vim.wo[win].winfixbuf then
      found_win = win
      break
    end
  end

  if found_win then
    vim.api.nvim_set_current_win(found_win)
    vim.api.nvim_win_set_buf(found_win, bufnr)
  else
    -- 如果所有窗口都设置了 winfixbuf，就新建一个窗口来显示 buffer
    vim.cmd("split")
    vim.api.nvim_win_set_buf(0, bufnr)
  end
end

return M
