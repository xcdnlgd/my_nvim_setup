require("option")
require("keymap")
require("autocmds")
require("lazy_setup")

-- create .nvimrc.lua in your project root folder
local startup_project_config = vim.fn.getcwd() .. "/.nvimrc.lua"
if vim.fn.filereadable(startup_project_config) == 1 then
    dofile(startup_project_config)
    vim.notify(".nvimrc.lua loaded")
end
