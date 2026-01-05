vim.api.nvim_create_user_command("Align",
  -- TODO: finish this
  -- find first match string for each line, find max column, add space till that column
  function(opts)
    vim.notify(vim.inspect(opts.line1))
    vim.notify(vim.inspect(opts.line2))
    local str = opts.args
    vim.notify(str)
  end,
  {
    range = true,
    preview = function(opts)
      local current_input = opts.args
      if current_input == "" then return 0 end
      return 2
    end
  }
)
