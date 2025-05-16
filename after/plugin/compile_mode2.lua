vim.api.nvim_set_hl(0, 'CompilationGreen', { link = "Green" })
vim.api.nvim_set_hl(0, 'CompilationRed', { link = "Red" })
vim.api.nvim_set_hl(0, 'CompilationYellow', { link = "Yellow" })
vim.api.nvim_set_hl(0, 'CompilationBrown', { fg = '#cc8c3c', bg = nil })
vim.api.nvim_set_hl(0, 'CompilationBlue', { link = "Blue" })
vim.api.nvim_set_hl(0, 'Underline', { underline = true, fg = nil })

vim.api.nvim_create_augroup("Compile", { clear = true })

-- TODO: terminal buffer has more lines than it needed
-- TODO: custom "[Process exited 1]", which is added by nvim after TermClose autocmd
-- TODO: handle lines on the fly rather than in TermClose autocmd, maybe?

local groups = {
  { msvc = '([^ %[]*%.%w+)[(](%d+)[)]' },
  { file_row_col = '([^ %[]*):(%d+):(%d+):?' },
  { file_row = '([^ %[]*):(%d+):?' },
}

local state = {
  last_cmd = "",
  process_exited = false,
  exit_code = 0, -- not used
  cur_error = 0,
  errors = {},
  mw = -1,
  win = -1,
  buf = -1,
  ns = vim.api.nvim_create_namespace("CompileNS"),
}

local get_file_row_col = function(str)
  local file, row, col
  for _, v in ipairs(groups) do
    for _, pattern in pairs(v) do
      file, row, col = str:match(pattern)
      if file ~= nil then
        return file, row, col
      end
    end
  end
  return file, row, col
end

local function open_file(line, mode)
  local str_l = vim.api.nvim_buf_get_lines(state.buf, line - 1, line, false)
  local file, row, col = get_file_row_col(str_l[1])
  if file == nil then
    return
  end
  if col == nil then
    col = 0
  end
  if mode then
    vim.api.nvim_command(mode .. '| e ' .. file)
  else
    if (vim.api.nvim_win_is_valid(state.mw)) then
      vim.api.nvim_set_current_win(state.mw)
      local bufnr = vim.fn.bufnr(file)
      if bufnr > 0 then
        vim.api.nvim_win_set_buf(state.mw, bufnr)
      else
        vim.api.nvim_command('e ' .. file)
      end
    else
      vim.api.nvim_command('vsplit | e' .. file)
    end
  end
  vim.fn.cursor(row, col)
  vim.cmd("norm! zz")
end

local function next_error()
  if #state.errors == 0 then
    vim.notify("No Error")
    return
  end
  if state.cur_error + 1 < #state.errors + 1 then
    state.cur_error = state.cur_error + 1
  else
    state.cur_error = 1
  end
  local row = state.errors[state.cur_error]
  vim.api.nvim_win_call(state.win, function()
    vim.fn.cursor(row, 0)
    vim.cmd("norm! zt")
  end)
  open_file(row)
end

vim.keymap.set('n', ']c', function()
  next_error()
end, { silent = true, desc = "Next compile error" })

local function compile(cmd)
  if cmd == "" then
    return
  end
  state.process_exited = false
  state.cur_error = 0
  state.exit_code = 0
  state.errors = {}

  -- WIN from cm was called
  state.mw = vim.api.nvim_get_current_win()

  if not (vim.api.nvim_win_is_valid(state.win)) then
    state.win = vim.api.nvim_open_win(0, false, {
      style = "minimal",
      split = "right"
    })
  end
  vim.api.nvim_win_call(state.win, function()
    vim.cmd("edit term://" .. cmd)
    if vim.api.nvim_buf_is_valid(state.buf) then
      vim.cmd("bd " .. tostring(state.buf))
    end
    local buf = vim.api.nvim_win_get_buf(0)
    state.buf = buf
    vim.bo[buf].buflisted = false
  end)

  vim.keymap.set('n', '<CR>', function()
    local l = vim.api.nvim_win_get_cursor(state.win)[1];
    open_file(l)
  end, { buffer = state.buf, silent = true })
  vim.keymap.set('n', '<leader>q', function() vim.api.nvim_command('bd!') end,
    { buffer = state.buf, silent = true, desc = "Quit window" })
  vim.keymap.set('n', 'q', function() vim.api.nvim_command('bd!') end,
    { buffer = state.buf, silent = true, desc = "Quit window" })
  vim.keymap.set('n', '<esc>', function() vim.api.nvim_command('bd!') end,
    { buffer = state.buf, silent = true, desc = "Quit window" })
  -- disable bnext and bprev
  vim.keymap.set("n", "[b", "", { buffer = state.buf })
  vim.keymap.set("n", "]b", "", { buffer = state.buf })

  vim.api.nvim_create_autocmd("TermClose", {
    group = "Compile",
    buffer = state.buf,
    callback = function(args)
      local buf = args.buf
      state.exit_code = vim.v.event.status
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      for i, str in ipairs(lines) do
        if str == "" then
          goto continue
        end
        if str == "[Process exited 1]" then
          vim.notify("detected")
        end
        -- Search for file:row:col format
        local file, row, col = get_file_row_col(str)
        if file then
          if col == nil then
            col = ""
          end
          table.insert(state.errors, i)
          local hl = "CompilationRed"
          local low = str:lower()

          if low:match("warning") then
            hl = "CompilationBrown"
          elseif low:match("note") then
            hl = "CopilationGreen"
          end

          local line = i - 1
          local front, _ = str:find(file, 1, true)
          front = front - 1
          vim.api.nvim_buf_set_extmark(buf, state.ns, line, front, {
            end_col = front + #file,
            hl_group = hl,
          })
          -- file   :
          vim.api.nvim_buf_set_extmark(buf, state.ns, line, front + #file + 1, {
            end_col = front + #file + 1 + #row,
            hl_group = "CompilationYellow",
          })
          -- file   :   row    :
          vim.api.nvim_buf_set_extmark(buf, state.ns, line, front + #file + 1 + #row + 1, {
            end_col = front + #file + 1 + #row + 1 + #col,
            hl_group = "CompilationGreen",
          })

          vim.api.nvim_buf_set_extmark(buf, state.ns, line, front, {
            end_col = front + #file + 1 + #row + 1 + #col,
            hl_group = "Underline"
          })
        end
        ::continue::
      end
    end
  })
end

vim.api.nvim_create_user_command('Compile',
  function(opt)
    if opt.args == "" then
      local input = vim.fn.input({
        prompt = 'Compile cmd: ',
        default = state.last_cmd,
        completion = "shellcmd",
      })
      if input ~= "" then
        state.last_cmd = input
        compile(state.last_cmd)
      end
    else
      state.last_cmd = opt.args
      compile(state.last_cmd)
    end
  end, { nargs = "*" }
)

vim.api.nvim_create_user_command("Recompile",
  function()
    local input = state.last_cmd
    compile(input)
  end, {}
)

vim.keymap.set("n", "<leader>c", ":Compile<cr>", { desc = "Compile" })
