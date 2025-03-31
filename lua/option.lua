vim.opt.spell = true
vim.opt.spelllang = "en_us"
vim.opt.spelloptions = "camel"

if not vim.env.SSH_TTY then -- only set `clipboard` if in SSH session and in neovim 0.10+
    vim.opt.clipboard = "unnamedplus" -- connection to the system clipboard
end

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
vim.opt.tabstop = 2 -- number of space in a tab
vim.opt.termguicolors = true -- enable 24-bit RGB color in the TUI
vim.opt.timeoutlen = 500 -- shorten key timeout length a little bit for which-key
vim.opt.title = true -- set terminal title to the filename and path
vim.opt.undofile = true -- enable persistent undo
vim.opt.updatetime = 300 -- length of time to wait before triggering the plugin
vim.opt.virtualedit = "block" -- allow going past end of line in visual block mode
vim.opt.wrap = false -- disable wrapping of lines longer than the width of window
vim.opt.writebackup = false -- disable making a backup before overwriting a file
