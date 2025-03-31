return {
  "stevearc/oil.nvim",
  opts = function(_, opts)
    -- TODO: show .. and .
    opts.columns = {
      "icon",
      {
        "size",
        highlight = "Red",
      },
      {
        "mtime",
        highlight = "green",
      },
      {
        "permissions",
        highlight = "blue",
      },
    }
    opts.win_options = {
      wrap = false,
      spell = false,
      list = false,
      conceallevel = 1,
    }
  end,
  -- Optional dependencies
  dependencies = { "echasnovski/mini.icons" },
}
