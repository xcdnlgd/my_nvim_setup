return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = {}, -- TODO: set up
    indent = {
      indent = { char = "▏" },
      scope = { char = "▏" },
      animate = { enabled = false },
    },
    input = {
      icon = "",
      win = {
        style = {
          width = 15,
          title_pos = "left",
          relative = "cursor",
          row = -1,
          col = function() -- relative to word
            local line = vim.fn.line(".")
            local col = vim.fn.col(".")
            local start_pos = vim.fn.searchpos("\\<", "cbWn", line)
            local offset = -2
            if start_pos[1] == line then
              offset = offset - (col - start_pos[2])
            end
            return offset
          end,
        }
      }
    },
    picker = {
      ui_select = true
    },
    notifier = {},
  },
  keys = {
    { "<leader>ff", function() require("snacks").picker.files() end,                 desc = "Find Files" },
    {
      "<Leader>fF",
      function() require("snacks").picker.files { hidden = true, ignored = true } end,
      desc = "Find all files",
    },
    { "<leader>fb", function() require("snacks").picker.buffers() end,               desc = "Buffers" },
    { "<leader>f/", function() require("snacks").picker.grep() end,                  desc = "Grep" },
    { "<leader>ft", function() require("snacks").picker.todo_comments() end,         desc = "Todo" },
    { "<leader>n",  function() require("snacks").picker.notifications() end,         desc = "Notification History" },
    -- git
    { "<leader>gb", function() require("snacks").picker.git_branches() end,          desc = "Git Branches" },
    { "<leader>gl", function() require("snacks").picker.git_log() end,               desc = "Git Log" },
    { "<leader>gL", function() require("snacks").picker.git_log_line() end,          desc = "Git Log Line" },
    { "<leader>gs", function() require("snacks").picker.git_status() end,            desc = "Git Status" },
    { "<leader>gS", function() require("snacks").picker.git_stash() end,             desc = "Git Stash" },
    { "<leader>gd", function() require("snacks").picker.git_diff() end,              desc = "Git Diff (Hunks)" },
    { "<leader>gf", function() require("snacks").picker.git_log_file() end,          desc = "Git Log File" },
    -- LSP
    { "gd",         function() require("snacks").picker.lsp_definitions() end,       desc = "Goto Definition" },
    { "gD",         function() require("snacks").picker.lsp_declarations() end,      desc = "Goto Declaration" },
    { "gr",         function() require("snacks").picker.lsp_references() end,        nowait = true,                  desc = "References" },
    { "gI",         function() require("snacks").picker.lsp_implementations() end,   desc = "Goto Implementation" },
    { "gy",         function() require("snacks").picker.lsp_type_definitions() end,  desc = "Goto T[y]pe Definition" },
    { "<leader>ls", function() require("snacks").picker.lsp_symbols() end,           desc = "LSP Symbols" },
    { "<leader>lS", function() require("snacks").picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
  }
}
