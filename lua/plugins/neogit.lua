local icons = require "icons"
return {
  "NeogitOrg/neogit",
  cmd = {
    "Neogit",
    "NeogitCommit",
    "NeogitLogCurrent",
    "NeogitResetState",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",         -- required
    "sindrets/diffview.nvim",        -- optional - Diff integration
  },
  opts = {
    signs = {
      item = {icons.FoldClosed, icons.FoldOpened},
      section = {icons.FoldClosed, icons.FoldOpened},
    }
  },
}
