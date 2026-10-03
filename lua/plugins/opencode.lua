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
  -- OpenCode v2 support lives on `main` (no stable release yet).
  branch = "main",
  config = function()
    -- 是否在 nvim 内显示 edit diff；false 则 edit 请求交给 TUI
    local enable_diff = true

    -- 当前 tmux window 里是否有面板在跑 opencode。
    -- tmux 把 `fish -c opencode` 的 pane_current_command 报成 fish，
    -- 所以看进程树里有没有 opencode 子进程更可靠。
    local function pane_runs_opencode(pane_pid)
      return vim.trim(vim.fn.system("pgrep -P " .. pane_pid .. " -x opencode 2>/dev/null")) ~= ""
    end

    local function find_opencode_pane()
      local fmt = "#{pane_id}\t#{pane_current_command}\t#{pane_pid}"
      local out = vim.fn.system("tmux list-panes -F '" .. fmt .. "' 2>/dev/null")
      for _, line in ipairs(vim.split(out, "\n", { trimempty = true })) do
        local id, cmd, pid = line:match("^(%%%d+)\t([^\t]*)\t(%d+)$")
        if id and (cmd == "opencode" or pane_runs_opencode(pid)) then
          return id
        end
      end
    end

    -- 确保右侧有 opencode 面板；focus=true 则聚焦它，false 则不抢 nvim 焦点
    local function ensure_opencode_pane(focus)
      if vim.env.TMUX == nil then
        return
      end

      local existing = find_opencode_pane()
      if existing then
        if focus then
          vim.fn.system("tmux select-pane -t " .. existing)
        end
        return existing
      end

      -- 加 -d 表示不聚焦；不加则新面板自动获得焦点
      local detach = focus and "" or "-d "
      local pane = vim.trim(vim.fn.system(
        "tmux split-window " .. detach .. "-h -l 80 -P -F '#{pane_id}' 'opencode'"
      ))
      if pane ~= "" then
        vim.g.opencode_pane = pane
        vim.fn.system("tmux set-option -t " .. pane .. " -p allow-passthrough off")
      end
      return pane
    end

    -- 修复：opencode v2 的 SSE 心跳是 15s，而插件超时只有 11s，
    -- 导致订阅每 11s 就断开，permission.replied 收不到、编辑 diff 不自动关闭。
    -- 这里把插件的超时常量调大到 30s（只改运行时，不动插件文件）。
    do
      local function patch_upvalue(fn, name, value)
        local i = 1
        while true do
          local n, v = debug.getupvalue(fn, i)
          if not n then
            break
          end
          if n == name then
            debug.setupvalue(fn, i, value)
            return true
          end
          if type(v) == "function" and patch_upvalue(v, name, value) then
            return true
          end
          i = i + 1
        end
        return false
      end
      patch_upvalue(require("opencode.server").connect, "OPENCODE_HEARTBEAT_INTERVAL_MS", 30000)
    end

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
        -- 插件发现不到服务时确保右侧面板存在（不抢 nvim 焦点）
        start = function()
          ensure_opencode_pane(false)
        end,
      },
    }

    -- 通用 permission 弹窗（bash 等）不在 nvim 显示，交给 TUI；edit diff 由 OpencodeEdits 单独处理
    vim.api.nvim_clear_autocmds({ group = "OpencodePermissions" })

    if enable_diff then
      -- opencode 的 diff 会被 trimDiff 去掉公共缩进，导致 :diffpatch 应用失败（空 diff）。
      -- 打开 diff 前同步 buffer 到磁盘，并把 patch 的缩进补回来。
      -- v2 事件结构：{ id, type = "permission.asked", data = { action = "edit", metadata.files[1] = { file, patch } } }
      -- hook `preview`：它同时被通用 permission 判断和 edit diff 处理调用。
      local edits = require("opencode.events.permissions.edits")
      local orig_preview = edits.preview
      edits.preview = function(event)
        local edit = orig_preview(event)
        if edit then
          vim.cmd("silent! checktime")
          edit.diff = reindent_patch(edit.diff, edit.filepath)
        end
        return edit
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

    -- <leader>a：确保右侧有 opencode 面板（不聚焦），在 nvim 输入框提问（预填 @this）
    vim.keymap.set({ "n", "x" }, "<leader>a", function()
      ensure_opencode_pane(false)
      require("opencode").ask("@this: ")
    end, { desc = "Ask opencode…" })
  end
}
