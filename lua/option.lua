vim.opt.spell = true
vim.opt.spelllang = "en_us"
vim.opt.spelloptions = "camel"

vim.opt.cinoptions = {"l1","g0","(0","W4","m1", "j1", "J1"} -- see :help cinoptions-values
vim.opt.cmdheight = 0 -- hide command line unless needed
vim.opt.completeopt = "menu,menuone,noselect" -- Options for insert mode completion
vim.opt.confirm = true -- raise a dialog asking if you wish to save the current file(s)
vim.opt.copyindent = true -- copy the previous indentation on autoindenting
vim.opt.cursorline = true -- highlight the text line of the cursor
vim.opt.diffopt:append({
  "algorithm:histogram",
  "linematch:60",
}) -- enable linematch diff algorithm
vim.opt.expandtab = true -- enable the use of space in tab
vim.opt.fillchars = { eob = " " } -- disable `~` on nonexistent lines
vim.opt.ignorecase = true -- case insensitive searching
vim.opt.infercase = true -- infer cases in keyword completion
vim.opt.jumpoptions = {} -- apply no jumpoptions on startup
vim.opt.laststatus = 3 -- global statusline
vim.opt.linebreak = true -- wrap lines at 'breakat'
vim.opt.mouse = "a" -- enable mouse support
vim.opt.number = true -- show numberline
vim.opt.preserveindent = true -- preserve indent structure as much as possible
vim.opt.pumheight = 10 -- height of the pop up menu
vim.opt.shiftround = true -- round indentation with `>`/`<` to shiftwidth
vim.opt.shiftwidth = 0 -- number of space inserted for indentation; when zero the 'tabstop' value will be used
vim.opt.shortmess = vim.tbl_deep_extend("force", vim.opt.shortmess:get(), { s = true, I = true, c = true, C = true }) -- disable search count wrap, startup messages, and completion messages
vim.opt.showmode = false -- disable showing modes in command line
vim.opt.showtabline = 2 -- always display tabline
vim.opt.signcolumn = "yes" -- always show the sign column
vim.opt.smartcase = true -- case sensitive searching
vim.opt.splitbelow = true -- splitting a new window below the current one
vim.opt.splitright = true -- splitting a new window at the right of the current one
vim.opt.tabstop = 4 -- number of space in a tab
vim.opt.termguicolors = true -- enable 24-bit RGB color in the TUI
vim.opt.timeoutlen = 500 -- shorten key timeout length a little bit for which-key
vim.opt.title = true -- set terminal title to the filename and path
vim.opt.undofile = true -- enable persistent undo
vim.opt.updatetime = 300 -- length of time to wait before triggering the plugin
vim.opt.virtualedit = "block" -- allow going past end of line in visual block mode
vim.opt.wrap = false -- disable wrapping of lines longer than the width of window
vim.opt.writebackup = false -- disable making a backup before overwriting a file

-- folding https://github.com/patricorgi/dotfiles/blob/main/.config/nvim/lua/custom/config/folding.lua
vim.o.foldcolumn = '0' -- '0' is not bad
vim.o.foldlevelstart = 99 -- unfold all
vim.o.foldenable = true
vim.o.foldmethod = 'expr'
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- Source: https://www.reddit.com/r/neovim/comments/1fzn1zt/custom_fold_text_function_with_treesitter_syntax/
local function fold_virt_text(result, start_text, lnum)
  local text = ''
  local hl
  for i = 1, #start_text do
    local char = start_text:sub(i, i)
    local new_hl

    -- if semantic tokens unavailable, use treesitter hl
    local sem_tokens = vim.lsp.semantic_tokens.get_at_pos(0, lnum, i - 1)
    if sem_tokens and #sem_tokens > 0 then
      new_hl = '@' .. sem_tokens[#sem_tokens].type
    else
      local captured_highlights = vim.treesitter.get_captures_at_pos(0, lnum, i - 1)
      if captured_highlights[#captured_highlights] then
        new_hl = '@' .. captured_highlights[#captured_highlights].capture
      end
    end

    if new_hl then
      if new_hl ~= hl then
        -- as soon as new hl appears, push substring with current hl to table
        table.insert(result, { text, hl })
        text = ''
        hl = nil
      end
      text = text .. char
      hl = new_hl
    else
      text = text .. char
    end
  end
  table.insert(result, { text, hl })
end
function _G.custom_foldtext()
  local start_text = vim.fn.getline(vim.v.foldstart):gsub('\t', string.rep(' ', vim.o.tabstop))
  local nline = vim.v.foldend - vim.v.foldstart
  local result = {}
  fold_virt_text(result, start_text, vim.v.foldstart - 1)
  table.insert(result, { '  ', nil })
  table.insert(result, { '󰛁  ' .. nline .. ' lines folded', '@comment' })
  return result
end
vim.opt.foldtext = 'v:lua.custom_foldtext()'
