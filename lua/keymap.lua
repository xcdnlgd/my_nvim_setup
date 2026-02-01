-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opts = { silent = true }

vim.keymap.set({ 'n', 'x' }, 'gh', '0', { desc = 'Start of Line' })
vim.keymap.set({ 'n', 'x' }, 'gs', '^', { desc = 'Start of Line (non ws)' })
vim.keymap.set({ 'n', 'x' }, 'gl', '$', { desc = 'End of Line' })

local function diagnostic_jump(forward, severity)
  local jump_opts = {}
  if type(severity) == "string" then jump_opts.severity = vim.diagnostic.severity[severity] end
  return function()
    jump_opts.count = forward and vim.v.count1 or -vim.v.count1
    vim.diagnostic.jump(jump_opts)
  end
end
vim.keymap.set("n", "[e", diagnostic_jump(false, "ERROR"), { desc = "Previous error" })
vim.keymap.set("n", "]e", diagnostic_jump(true, "ERROR"), { desc = "Next error" })
vim.keymap.set("n", "[w", diagnostic_jump(false, "WARN"), { desc = "Previous warning" })
vim.keymap.set("n", "]w", diagnostic_jump(true, "WARN"), { desc = "Next warning" })

vim.keymap.set('n', '<leader>ul', function()
  local new_config = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = new_config })
end, { desc = 'Toggle diagnostic virtual_lines' })
vim.keymap.set('n', '<leader>uv', function()
  local new_config = not vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = new_config })
end, { desc = 'Toggle diagnostic virtual_text' })
vim.keymap.set('n', '<leader>ui', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = 'Toggle lsp inlay_hint' })


vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Move cursor down" })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Move cursor up" })

vim.keymap.set("n", "<leader>w", ":up<cr>", { desc = "Save" })
vim.keymap.set("n", "<leader>q", function()
  -- quitting the only window for listed_buffers, quit all
  if vim.bo.buflisted then
    local listed_buffers = vim.fn.getbufinfo({ buflisted = 1 })
    local winnum = 0
    for _, listed_buffer in ipairs(listed_buffers) do
      winnum = winnum + #listed_buffer.windows
      if winnum > 1 then
        vim.cmd("conf q")
        return
      end
    end
    vim.cmd("conf qall")
  else
    vim.cmd("conf q")
  end
end, { desc = "Quit window" })
vim.keymap.set("n", "<leader>d", function()
  local bufnum = #vim.fn.getbufinfo({ buflisted = 1 })
  if bufnum > 1 then
    vim.cmd("bp|bd #")
  else
    vim.cmd("bd")
  end
end, { desc = "Close buffer" })
vim.keymap.set("n", "<leader>Q", ":confirm qall<cr>", { desc = "Exit nvim" })
vim.keymap.set("n", "<leader>ld", function() vim.diagnostic.open_float() end, { desc = "Hover diagnostics" })

vim.keymap.set("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment line" })
vim.keymap.set("x", "<leader>/", "gc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("n", "|", "<Cmd>vsplit<CR>", { desc = "Vertical Split" })
vim.keymap.set("n", "\\", "<Cmd>split<CR>", { desc = "Horizontal Split" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to above split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

vim.keymap.set("n", "Y", 'y$', { desc = "Yank" })
vim.keymap.set("n", "c", '"_c', { desc = "Change" })
vim.keymap.set("n", "C", '"_C', { desc = "Change" })
vim.keymap.set("n", "d", '"_d', { desc = "Delete" })
vim.keymap.set("n", "D", '"_D', { desc = "Delete" })
vim.keymap.set("v", "p", 'P', { desc = "Put" })
vim.keymap.set("v", "P", 'p', { desc = "Put" })

-- preserve cursor position
-- TODO: see if I really want this
vim.keymap.set("v", "y", 'ygv<esc>', { desc = "Yank" })

-- move line up and down, can move past fisrt line and last line
vim.keymap.set("n", "<M-k>", function()
  if vim.fn.line(".") == 1 then
    -- line already the first line
    vim.api.nvim_buf_set_lines(0, 1, 1, false, { "" })
    return
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(
    ":m -2<cr>",
    true, false, true
  ), "n", false)
end, opts)
vim.keymap.set("n", "<M-j>", function()
  if vim.fn.line(".") >= vim.fn.line("$") then
    -- line already the last line
    vim.api.nvim_buf_set_lines(0, -2, -2, false, { "" })
    return
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(
    ":m +1<cr>",
    true, false, true
  ), "n", false)
end, opts)
vim.keymap.set("i", "<M-k>", function()
  if vim.fn.line(".") == 1 then
    vim.api.nvim_buf_set_lines(0, 1, 1, false, { "" })
    return
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(
    "<esc>:m -2<cr>gi",
    true, false, true
  ), "i", false)
end, opts)
vim.keymap.set("i", "<M-j>", function()
  if vim.fn.line(".") >= vim.fn.line("$") then
    vim.api.nvim_buf_set_lines(0, -2, -2, false, { "" })
    return
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(
    "<esc>:m +1<cr>gi",
    true, false, true
  ), "i", false)
end, opts)
local function get_visual_start_end()
  -- vim.fn.line("'<"|"'>") fail on startup
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    local temp = start_line
    start_line = end_line
    end_line = temp
  end
  return start_line, end_line
end
vim.keymap.set("v", "<M-k>", function()
  local start_line, end_line = get_visual_start_end()
  if start_line == 1 then
    vim.api.nvim_buf_set_lines(0, end_line, end_line, false, { "" })
    return
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(
    ":m '<-2<cr><esc>gv", -- <esc> to get rid of n lines moved hint
    true, false, true
  ), "v", false)
end, opts)
vim.keymap.set("v", "<M-j>", function()
  local _, end_line = get_visual_start_end()
  if end_line == vim.fn.line("$") then
    vim.api.nvim_buf_set_lines(0, -1, -1, false, { "" })
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(
    ":m '>+1<cr><esc>gv",
    true, false, true
  ), "v", false)
end, opts)

-- duplicate line up and down
vim.keymap.set("n", "<M-K>", "<cmd>t.<cr>k", opts)
vim.keymap.set("n", "<M-J>", "<cmd>t.<cr>", opts)
vim.keymap.set("i", "<M-K>", "<esc>:t .<cr>gi", opts)
vim.keymap.set("i", "<M-J>", "<esc>:t -1<cr>gi", opts)
vim.keymap.set("v", "<M-K>", ":t '><cr>gv", opts)
vim.keymap.set("v", "<M-J>", ":t -1<cr>gv", opts)

vim.keymap.set("v", ">", ">gv", { desc = "Indent line" })
vim.keymap.set("v", "<", "<gv", { desc = "Unindent line" })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Unindent line" })
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent line" })

vim.keymap.set('i', '<C-Del>', "<C-o>dw", opts)
vim.keymap.set('i', '<C-BS>', '<C-w>', { silent = true }) -- only work in gui app
vim.keymap.set('i', '<C-h>', '<C-w>', { silent = true })  -- to map <C-BS> <C-w> in windows terminal

vim.cmd("cnoremap <C-h> <C-w>")

-- emacs
vim.keymap.set('i', '<C-a>', '<HOME>', { desc = 'Start of line' })
vim.keymap.set('i', '<C-e>', '<END>', { desc = 'End of line' })
