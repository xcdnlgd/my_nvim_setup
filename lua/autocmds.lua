local autocmds = {
  highlightyank = {
    {
      event = "TextYankPost",
      desc = "Highlight yanked text",
      pattern = "*",
      callback = function() (vim.hl or vim.highlight).on_yank() end,
    },
  },
  restore_cursor = {
    {
      event = "BufReadPost",
      desc = "Restore last cursor position when opening a file",
      callback = function(args)
        local buf = args.buf
        if vim.b[buf].last_loc_restored or vim.tbl_contains({ "gitcommit" }, vim.bo[buf].filetype) then return end
        vim.b[buf].last_loc_restored = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(buf) then
          pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
      end,
    },
  },
}

local function set_jsonc_filetype()
  local path = vim.fn.expand('%:p:h')
  local file_extension = vim.fn.expand('%:e')
  if path:match('/%.vscode$') and file_extension == 'json' then
    vim.bo.filetype = 'jsonc'
  end
end

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.json" },
  callback = set_jsonc_filetype,
})

local M = {}
M.create_autocmds = function(autocmds)
  for group_name, cmds in pairs(autocmds) do
    local augroup = vim.api.nvim_create_augroup(group_name, { clear = true })
    for _, cmd in ipairs(cmds) do
      cmd.group = augroup
      local event = cmd.event
      cmd.event = nil
      vim.api.nvim_create_autocmd(event, cmd)
    end
  end
end
M.create_autocmds(autocmds)
return M
