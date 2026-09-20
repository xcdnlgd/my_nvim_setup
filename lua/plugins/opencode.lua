local function reindent_patch(patch, filepath)
  local candidates = { filepath, vim.fn.fnamemodify(filepath, ":p") }
  if vim.env.HOME and vim.env.HOME ~= "" then
    table.insert(candidates, vim.fs.joinpath(vim.env.HOME, filepath))
  end
  local old
  for _, f in ipairs(candidates) do
    if vim.fn.filereadable(f) == 1 then
      local r = vim.fn.readfile(f)
      if #r > 0 then
        old = r
        break
      end
    end
  end
  if not old then
    return patch
  end

  local function lstrip(s) return (s:gsub("^%s+", "")) end
  local function lead(s) return #(s:match("^[ \t]*") or "") end

  local lines = vim.split(patch, "\n", { plain = true })
  local out = {}
  local i = 1
  while i <= #lines do
    local line = lines[i]
    if line:sub(1, 2) == "@@" then
      local body = {}
      local j = i + 1
      while j <= #lines do
        local c = lines[j]:sub(1, 1)
        if c == " " or c == "+" or c == "-" or c == "\\" then
          table.insert(body, lines[j])
          j = j + 1
        else
          break
        end
      end

      local old_texts = {}
      for _, b in ipairs(body) do
        local c = b:sub(1, 1)
        if c == " " or c == "-" then
          table.insert(old_texts, b:sub(2))
        end
      end

      local pos
      for start = 1, #old do
        local match = true
        for k = 1, #old_texts do
          local o = old[start + k - 1]
          if not o or lstrip(o) ~= lstrip(old_texts[k]) then
            match = false
            break
          end
        end
        if match then
          pos = start
          break
        end
      end

      local shift = 0
      if pos then
        local counts = {}
        for k = 1, #old_texts do
          if old_texts[k]:match("%S") then
            local d = lead(old[pos + k - 1]) - lead(old_texts[k])
            counts[d] = (counts[d] or 0) + 1
          end
        end
        local best, best_count = 0, -1
        for d, count in pairs(counts) do
          if count > best_count then
            best, best_count = d, count
          end
        end
        shift = best
      end

      if shift > 0 then
        for idx, b in ipairs(body) do
          local content = b:sub(2)
          if content:match("%S") then
            body[idx] = b:sub(1, 1) .. string.rep(" ", shift) .. content
          end
        end
      end

      table.insert(out, line)
      vim.list_extend(out, body)
      i = j
    else
      table.insert(out, line)
      i = i + 1
    end
  end

  return table.concat(out, "\n")
end

return {
  "nickjvandyke/opencode.nvim",
  version = "v1.0.2",
  config = function()
    -- 是否在 nvim 内显示 edit diff；false 则 edit 请求交给 TUI
    local enable_diff = true

    vim.g.opencode_opts = {
      events = {
        permissions = {
          enabled = true,
          edits = {
            enabled = enable_diff,
          },
        },
      },
      server = {
        start = function()
          local pane = vim.trim(vim.fn.system(
            "tmux split-window -d -P -F '#{pane_id}' -h -l 80 'opencode --port'"
          ))
          if pane ~= "" then
            vim.g.opencode_pane = pane
            vim.fn.system("tmux set-option -t " .. pane .. " -p allow-passthrough off")
          end
        end,
      },
    }

    -- 通用 permission 弹窗（bash 等）不在 nvim 显示，交给 TUI；edit diff 由 OpencodeEdits 单独处理
    vim.api.nvim_clear_autocmds({ group = "OpencodePermissions" })

    if enable_diff then
      -- opencode 的 diff 会被 trimDiff 去掉公共缩进，导致 :diffpatch 应用失败（空 diff）。
      -- 打开 diff 前同步 buffer 到磁盘，并把 patch 的缩进补回来。
      local edits = require("opencode.events.permissions.edits")
      local orig_diff = edits.diff
      edits.diff = function(event)
        if event.type == "permission.asked" and event.properties.permission == "edit" then
          vim.cmd("silent! checktime")
          local md = event.properties.metadata
          if md and md.diff and md.filepath then
            md.diff = reindent_patch(md.diff, md.filepath)
          end
        end
        return orig_diff(event)
      end
    end

    -- 退出 nvim 时一并关闭 opencode 所在的 tmux pane
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        if vim.g.opencode_pane and vim.g.opencode_pane ~= "" then
          vim.fn.system("tmux kill-pane -t " .. vim.g.opencode_pane)
          vim.g.opencode_pane = nil
        end
      end,
    })

    vim.keymap.set({ "n", "x" }, "<leader>a", function() require("opencode").ask("@this: ") end,
      { desc = "Ask opencode…" })
  end
}
