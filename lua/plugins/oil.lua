return {
  "stevearc/oil.nvim",
  enabled = false,
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
    vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "WinEnter" }, {
      callback = function(args)
        vim.opt.showtabline = vim.bo.filetype == "oil" and 0 or 2
        if vim.bo.filetype == "oil" then
          vim.keymap.set("n", "<leader>e", "<Nop>", { buffer = args.buf, desc = "Disabled in oil" })
        end
      end,
    })
  end,
  -- Optional dependencies
  dependencies = { "echasnovski/mini.icons" },
}
