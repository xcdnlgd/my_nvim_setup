local align_lines = function(lines, target)
  local max_col = 0
  local positions = {}
  for i, line in ipairs(lines) do
    local start_idx, _ = string.find(line, target, 1, true)
    positions[i] = start_idx
    if start_idx and start_idx > max_col then
      max_col = start_idx
    end
  end

  if max_col == 0 then
    return lines, positions, max_col
  end

  local new_lines = {}
  for i, line in ipairs(lines) do
    local col = positions[i]
    if col and col ~= max_col then
      local left_part = string.sub(line, 1, col - 1)
      local right_part = string.sub(line, col)
      local padding = string.rep(" ", max_col - col)
      new_lines[i] = left_part .. padding .. right_part
    else
      new_lines[i] = line
    end
  end
  return new_lines, positions, max_col
end

vim.api.nvim_create_user_command("Align",
  -- TODO: visual-block support
  function(opts)
    local line1 = opts.line1
    local line2 = opts.line2
    local target = opts.args
    local buffer = 0
    local lines = vim.api.nvim_buf_get_lines(buffer, line1 - 1, line2, true);
    local new_lines = align_lines(lines, target)
    if new_lines ~= lines then
      vim.api.nvim_buf_set_lines(buffer, line1 - 1, line2, true, new_lines)
    end
  end,
  {
    range = true,
    nargs = 1,
    preview = function(opts, preview_ns, preview_buf)
      local line1 = opts.line1
      local line2 = opts.line2
      local target = opts.args
      if target == "" then return 0 end

      local buffer = 0
      local lines = vim.api.nvim_buf_get_lines(buffer, line1 - 1, line2, true);
      local new_lines, positions, max_col = align_lines(lines, target)
      if new_lines == lines then return 0 end

      if preview_buf then
        vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, new_lines)
      else
        vim.api.nvim_buf_set_lines(buffer, line1 - 1, line2, true, new_lines)
      end

      local target_buf = preview_buf or 0
      for i, _ in ipairs(lines) do
        local col = positions[i]
        if col then
          local new_start = max_col - 1
          local new_end = max_col - 1 + #target
          vim.hl.range(
            target_buf,
            preview_ns,
            "Substitute",
            { preview_buf and (i - 1) or (line1 + i - 2), new_start },
            { preview_buf and (i - 1) or (line1 + i - 2), new_end }
          )
        end
      end

      return 2
    end
  }
)
