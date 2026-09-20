require('vim._core.ui2').enable()

require("option")
require("keymap")
require("autocmds")
require("custcmds")
require("lazy_setup")

-- NOTE: replaced by vim.opt.exrc = true
-- create .nvim.lua in your project root folder
-- local startup_project_config = vim.fn.getcwd() .. "/.nvim.lua"
-- if vim.fn.filereadable(startup_project_config) == 1 then
--     dofile(startup_project_config)
--     vim.notify(".nvim.lua loaded")
-- end
