-- based on
-- https://github.com/nexcov/compile-mode.nvim

if true then
  return
end

vim.api.nvim_set_hl(0, 'CompilationGreen', { link = "Green" })
vim.api.nvim_set_hl(0, 'CompilationRed', { link = "Red" })
vim.api.nvim_set_hl(0, 'CompilationYellow', { link = "Yellow" })
vim.api.nvim_set_hl(0, 'CompilationBrown', { fg = '#cc8c3c', bg = nil })
vim.api.nvim_set_hl(0, 'CompilationBlue', { link = "Blue" })
vim.api.nvim_set_hl(0, 'Underline', { underline = true, fg = nil })

vim.api.nvim_create_augroup("Compile", { clear = true })
vim.g.compile_mode_ins = nil

local Compile = {}
Compile.__index = Compile

local groups = {
  { msvc = '([^ %[]*%.%w+)[(](%d+)[)]' },
  { file_row_col = '([^ %[]*):(%d+):(%d+):?' },
  { file_row = '([^ %[]*):(%d+):?' },
}

Compile.CM_WIN_OPTS = { split = 'right' }
--TODO: Get errors list in a quickfix and get that list in the compilation buffer

local function handle_previous_running_instance(cm)
  local choice = vim.fn.confirm("CMD is running, kill it?", "&Yes\n&No\n")
  if choice == 1 then
    cm:kill_cmd(9) --SIGKILL
    vim.api.nvim_buf_delete(cm.buf, { force = true })
    vim.cmd('Compile')
  elseif choice == 2 then
    print("Not killed")
  end
end

-- TODO: reuse win to avoid blink
function Compile:new()
  local cm = setmetatable({}, self)
  if vim.g.compile_mode_ins ~= nil then
    if vim.g.compile_mode_ins.cmd_running then
      handle_previous_running_instance(vim.g.compile_mode_ins)
      return nil
    else
      vim.api.nvim_buf_delete(vim.g.compile_mode_ins.buf, { force = true })
    end
  end
  -- 1 index :(
  cm.cur_error = 0
  cm.errors = {}
  cm.cmd_running = false
  cm.cur_line = 0

  -- WIN from cm was called
  cm.mw = vim.api.nvim_get_current_win()
  cm.ns = vim.api.nvim_create_namespace("CompileNS")

  -- [[ BUFFER ]]
  cm.buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_set_option_value("swapfile", false, { buf = cm.buf })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = cm.buf })
  vim.api.nvim_set_option_value("buflisted", false, { buf = cm.buf })
  cm:set_keymaps()
  cm:set_autocmds()
  vim.g.compile_mode_ins = cm
  cm.win = vim.api.nvim_open_win(cm.buf, false, Compile.CM_WIN_OPTS)
  vim.wo[cm.win].spell = false
  return cm
end

vim.keymap.set("n", "<leader>c", ":Compile<cr>", { desc = "Compile" })

function Compile:set_keymaps()
  vim.keymap.set('n', '<leader>q', function() vim.api.nvim_command('bd!') end,
    { buffer = self.buf, silent = true, desc = "Quit window" })
  vim.keymap.set('n', 'q', function() vim.api.nvim_command('bd!') end,
    { buffer = self.buf, silent = true, desc = "Quit window" })
  vim.keymap.set('n', '<esc>', function() vim.api.nvim_command('bd!') end,
    { buffer = self.buf, silent = true, desc = "Quit window" })

  -- -- disable bnext and bprev
  vim.keymap.set("n", "[b", "", { buffer = self.buf })
  vim.keymap.set("n", "]b", "", { buffer = self.buf })

  vim.keymap.set('n', '<CR>', function()
    local l = vim.api.nvim_win_get_cursor(self.win)[1];
    self:open_file(l)
  end, { buffer = self.buf, silent = true })

  -- vim.keymap.set('n', '<C-v>', function()
  --   local l = vim.api.nvim_win_get_cursor(self.win)[1];
  --   self:open_file(l, 'vsplit')
  -- end, { buffer = self.buf, silent = true })

  vim.keymap.set('n', ']c', function()
    self:next_error()
  end, { silent = true, desc = "Next compile error" })

  -- vim.keymap.set('n', '[c', function()
  --   self:prev_error()
  -- end, { silent = true, desc = "Previous compile error" })

  vim.keymap.set({ 'n', 'i' }, '<C-c>', function()
    self:kill_cmd("SIG")
  end, { buffer = self.buf, silent = true, noremap = false })
end

function Compile:set_autocmds()
  vim.api.nvim_create_autocmd({ "BufDelete" }, {
    group = "Compile",
    buffer = self.buf,
    callback = function()
      if self.cmd_running then
        local choice = vim.fn.confirm("CMD is running, kill it?", "&Yes\n&No\n")
        if choice == 1 then
          self:kill_cmd(9) --SIGKILL
        elseif choice == 2 then
          print("Not killed")
        end
      end
    end
  })
end

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

function Compile:handle_line(data)
  -- Cant use '\n' symbol in buf_set_lines
  local lines = vim.split(data, '\n')
  for _, str in ipairs(lines) do
    if str ~= '' then
      vim.api.nvim_buf_set_lines(self.buf, -1, -1, false, { str })
      self.cur_line = self.cur_line + 1
      if vim.api.nvim_get_current_win() == self.win then
        vim.api.nvim_win_set_cursor(self.win, { self.cur_line + 1, 0 })
      end

      -- Search for file:row:col format
      local file, row, col = get_file_row_col(str)
      if file then
        if col == nil then
          col = ""
        end
        table.insert(self.errors, self.cur_line + 1)
        local hl = "CompilationRed"
        local low = str:lower()

        if low:match("warning") then
          hl = "CompilationBrown"
        elseif low:match("note") then
          hl = "CopilationGreen"
        end

        local line = self.cur_line
        local front, _ = str:find(file, 1, true)
        front = front - 1
        vim.api.nvim_buf_set_extmark(self.buf, self.ns, line, front, {
          end_col = front + #file,
          hl_group = hl,
        })
        -- file   :
        vim.api.nvim_buf_set_extmark(self.buf, self.ns, line, front + #file + 1, {
          end_col = front + #file + 1 + #row,
          hl_group = "CompilationYellow",
        })
        -- file   :   row    :
        vim.api.nvim_buf_set_extmark(self.buf, self.ns, line, front + #file + 1 + #row + 1, {
          end_col = front + #file + 1 + #row + 1 + #col,
          hl_group = "CompilationGreen",
        })

        vim.api.nvim_buf_set_extmark(self.buf, self.ns, line, front, {
          end_col = front + #file + 1 + #row + 1 + #col,
          hl_group = "Underline"
        })
      end
    end
  end
end

function Compile:open_file(line, mode)
  local str_l = vim.api.nvim_buf_get_lines(self.buf, line - 1, line, false)
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
    if (vim.api.nvim_win_is_valid(self.mw)) then
      vim.api.nvim_set_current_win(self.mw)
      local bufnr = vim.fn.bufnr(file)
      if bufnr > 0 then
        vim.api.nvim_win_set_buf(self.mw, bufnr)
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

function Compile:next_error()
  if #self.errors == 0 then
    vim.notify("No Error")
    return
  end
  if self.cur_error + 1 < #self.errors + 1 then
    self.cur_error = self.cur_error + 1
  else
    self.cur_error = 1
  end
  local row = self.errors[self.cur_error]
  vim.api.nvim_win_call(self.win, function()
    vim.fn.cursor(row, 0)
    vim.cmd("norm! zt")
  end)
  self:open_file(row)
end

function Compile:prev_error()
  if #self.errors == 0 then
    vim.notify("No Error")
    return
  end
  if self.cur_error - 1 < 1 then
    self.cur_error = #self.errors
  else
    self.cur_error = self.cur_error - 1
  end
  local row = self.errors[self.cur_error]
  vim.api.nvim_win_call(self.win, function()
    vim.fn.cursor(row, 0)
    vim.cmd("norm! zt")
  end)
  self:open_file(row)
end

function Compile:handle_exit_code(code)
  if not code or not vim.api.nvim_buf_is_valid(self.buf) then return end
  local comp = "Compilation"
  local fin = " finished"
  local l = vim.api.nvim_buf_line_count(self.buf) + 1
  if code ~= 0 then
    local ab = " abnormaly "
    vim.api.nvim_buf_set_lines(self.buf, -1, -1, false, {
      "",
      comp .. fin .. ab .. 'with code ' .. code .. ' at ' .. os.date()
    })
    vim.api.nvim_buf_set_extmark(self.buf, self.ns, l, #comp + #fin, {
      end_col = #comp + #fin + #ab,
      hl_group = "CompilationRed",
    })
    vim.api.nvim_buf_set_extmark(self.buf, self.ns, l, #comp + #fin + #ab + 10, {
      end_col = #comp + #fin + #ab + 10 + #tostring(code),
      hl_group = "CompilationRed",
    })

    -- vim.notify("Compilation exit with code: " .. code, vim.log.levels.ERROR)
  else
    vim.api.nvim_buf_set_lines(self.buf, -1, -1, false, {
      "",
      comp .. fin .. ' at ' .. os.date()
    })
    vim.api.nvim_buf_set_extmark(self.buf, self.ns, l, #comp, {
      end_col = #comp + #fin,
      hl_group = "CompilationGreen",
    })

    -- vim.notify("Compilation exit with code: " .. code, vim.log.levels.INFO)
  end
  vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf })
  vim.api.nvim_set_option_value("readonly", true, { buf = self.buf })
end

local shell = nil
local exec = nil
if vim.fn.has("win32") == 1 then
  shell = "cmd.exe"
  exec = "/c"
else
  shell = "bash"
  exec = "-c"
end

function Compile:call_cmd(cmd)
  self.cmd_running = true
  vim.api.nvim_buf_set_name(self.buf, "*compilation* '" .. cmd .. "'")
  self.stdout = vim.uv.new_pipe()
  self.stderr = vim.uv.new_pipe()
  self.handle, self.pid = vim.uv.spawn(shell, {
      args = { exec, cmd },
      cwd = vim.uv.cwd(),
      stdio = { nil, self.stdout, self.stderr },
    },
    function(code, signal)
      -- ON cmd exit
      vim.schedule(function()
        self.stdout:close()
        self.stderr:close()
        self:handle_exit_code(code)
        self.cmd_running = false
        vim.api.nvim_win_call(self.win, function()
          vim.cmd('normal G')
        end)
      end)
    end)

  self.stdout:read_start(function(err, data)
    assert(not err, err)
    if data then
      vim.schedule(function() self:handle_line(data) end)
    end
  end)

  self.stderr:read_start(function(err, data)
    assert(not err, err)
    if data then
      vim.schedule(function() self:handle_line(data) end)
    end
  end)
end

function Compile:kill_cmd(signal)
  if not self.handle or not self.pid then return end
  if self.cmd_running then
    self.handle:kill(signal)
  else
    vim.notify("Process is not running", vim.log.levels.ERROR)
  end
end

local compile = function(input)
  if not input then return end
  local cm = Compile:new()
  if cm ~= nil then
    vim.cmd("silent wa")
    cm:call_cmd(input)
    vim.g.compile_mode_last_cmd = input
  end
end

vim.api.nvim_create_user_command('Compile',
  function(opt)
    if opt.args == "" then
      local input = vim.fn.input({
        prompt = 'Compile cmd: ',
        default = vim.g.compile_mode_last_cmd,
        completion = "shellcmd",
      })
      if input ~= "" then
        compile(input)
      end
    else
      compile(opt.args)
    end
  end, { nargs = "*" }
)

vim.api.nvim_create_user_command("Recompile",
  function()
    local input = vim.g.compile_mode_last_cmd
    compile(input)
  end, {}
)
