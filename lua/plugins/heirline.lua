vim.api.nvim_create_autocmd('DiagnosticChanged', {
  callback = function(args)
    vim.schedule(vim.cmd.redrawstatus)
  end,
})

return {
  "rebelot/heirline.nvim",
  event = "BufEnter",
  dependencies = { { "lewis6991/gitsigns.nvim" } },
  opts = function(_, opts)
    vim.api.nvim_set_hl(0, "TabLineSel", { link = "NormalFloat" })
    vim.api.nvim_set_hl(0, "TabLine", { link = "Ignore" })

    local conditions = require("heirline.conditions")
    local utils = require("heirline.utils")

    local colors = {
      bright_bg = utils.get_highlight("Folded").bg,
      bright_fg = utils.get_highlight("Folded").fg,
      red = utils.get_highlight("Red").fg,
      dark_red = utils.get_highlight("DiffDelete").bg,
      green = utils.get_highlight("Green").fg,
      blue = utils.get_highlight("Blue").fg,
      grey = utils.get_highlight("Grey").fg,
      orange = utils.get_highlight("Orange").fg,
      purple = utils.get_highlight("Purple").fg,
      cyan = utils.get_highlight("Special").fg, -- TODO: not right
      diag_warn = utils.get_highlight("DiagnosticWarn").fg,
      diag_error = utils.get_highlight("DiagnosticError").fg,
      diag_hint = utils.get_highlight("DiagnosticHint").fg,
      diag_info = utils.get_highlight("DiagnosticInfo").fg,
      git_del = utils.get_highlight("GitSignsDelete").fg,
      git_add = utils.get_highlight("GitSignsAdd").fg,
      git_change = utils.get_highlight("GitSignsChange").fg,
    }
    require("heirline").load_colors(colors)

    local Align = { provider = "%=" }
    local Space = { provider = " " }

    ---------------------- TabLine started --------------------------

    local FileIcon = {
      init = function(self)
        local filename = self.filename
        local extension = vim.fn.fnamemodify(filename, ":e")
        self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
      end,
      provider = function(self)
        return self.icon and (self.icon .. " ")
      end,
      hl = function(self)
        return { fg = self.icon_color }
      end
    }

    -- we redefine the filename component, as we probably only want the tail and not the relative path
    local TablineFileName = {
      provider = function(self)
        -- self.filename will be defined later, just keep looking at the example!
        local filename = self.filename
        filename = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")
        if (self._show_picker) then
          filename = filename:sub(2)
        end
        return filename
      end,
      hl = function(self)
        return { bold = self.is_active or self.is_visible, italic = true }
      end,
    }

    -- this looks exactly like the FileFlags component that we saw in
    -- #crash-course-part-ii-filename-and-friends, but we are indexing the bufnr explicitly
    -- also, we are adding a nice icon for terminal buffers.
    local TablineFileFlags = {
      {
        condition = function(self)
          return vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
        end,
        provider = " " .. require("icons")["FileModified"] .. " ",
        hl = { fg = "green" },
      },
      {
        condition = function(self)
          return not vim.api.nvim_get_option_value("modifiable", { buf = self.bufnr })
              or vim.api.nvim_get_option_value("readonly", { buf = self.bufnr })
        end,
        provider = function(self)
          if vim.api.nvim_get_option_value("buftype", { buf = self.bufnr }) == "terminal" then
            return " " .. require("icons").Terminal .. " "
          else
            return require("icons").FileReadOnly
          end
        end,
        hl = { fg = "orange" },
      },
    }

    local TablinePicker = {
      condition = function(self)
        return self._show_picker
      end,
      init = function(self)
        local bufname = vim.api.nvim_buf_get_name(self.bufnr)
        bufname = vim.fn.fnamemodify(bufname, ":t")
        local label = bufname:sub(1, 1)
        local i = 2
        while self._picker_labels[label] do
          if i > #bufname then
            break
          end
          label = bufname:sub(i, i)
          i = i + 1
        end
        self._picker_labels[label] = self.bufnr
        self.label = label
      end,
      provider = function(self)
        return self.label
      end,
      hl = { fg = "red", bold = true, italic = true },
    }

    -- TODO: buffer close left/rifht
    -- TODO: buffer swap
    vim.keymap.set("n", "<leader>bb", function()
      local tabline = require("heirline").tabline
      local buflist = tabline._buflist[1]
      buflist._picker_labels = {}
      buflist._show_picker = true
      vim.cmd.redrawtabline()
      local char = vim.fn.getcharstr()
      local bufnr = buflist._picker_labels[char]
      if bufnr then
        vim.api.nvim_win_set_buf(0, bufnr)
      end
      buflist._show_picker = false
      vim.cmd.redrawtabline()
    end, { desc = "Jump to buffer" })

    vim.keymap.set("n", "<leader>bd", function()
      local tabline = require("heirline").tabline
      local buflist = tabline._buflist[1]
      buflist._picker_labels = {}
      buflist._show_picker = true
      vim.cmd.redrawtabline()
      local char = vim.fn.getcharstr()
      local bufnr = buflist._picker_labels[char]
      if bufnr then
        vim.cmd(string.format("bd %d", bufnr))
      end
      buflist._show_picker = false
      vim.cmd.redrawtabline()
    end, { desc = "Delete a buffer" })

    -- Here the filename block finally comes together
    local TablineFileNameBlock = {
      init = function(self)
        self.filename = vim.api.nvim_buf_get_name(self.bufnr)
      end,
      on_click = {
        callback = function(_, minwid, _, button)
          if (button == "m") then -- close on mouse middle click
            vim.schedule(function()
              vim.api.nvim_buf_delete(minwid, { force = false })
            end)
          else
            vim.api.nvim_win_set_buf(0, minwid)
          end
        end,
        minwid = function(self)
          return self.bufnr
        end,
        name = "heirline_tabline_buffer_callback",
      },
      FileIcon, -- turns out the version defined in #crash-course-part-ii-filename-and-friends can be reutilized as is here!
      TablinePicker,
      TablineFileName,
      TablineFileFlags,
    }

    -- a nice "x" button to close the buffer
    local TablineCloseButton = {
      condition = function(self)
        return not vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
      end,
      {
        provider = " " .. require("icons").BufferClose .. " ",
        on_click = {
          callback = function(_, minwid)
            vim.schedule(function()
              vim.api.nvim_buf_delete(minwid, { force = false })
              vim.cmd.redrawtabline()
            end)
          end,
          minwid = function(self)
            return self.bufnr
          end,
          name = "heirline_tabline_close_buffer_callback",
        },
      },
    }

    local Seperator = {
      provider = "|",
    }

    -- The final touch!
    local TablineBufferBlock = {
      condition = function(self)
        -- filter list
        return not conditions.buffer_matches({
          filetype = { "qf", "checkhealth" } -- qf is vim.lsp.buf.reference()
        }, self.bufnr)
      end,
      hl = function(self)
        if self.is_active then
          return "TabLineSel"
        else
          return "TabLine"
        end
      end,
      Seperator,
      TablineFileNameBlock,
      TablineCloseButton,
    }

    -- and here we go
    local BufferLine = utils.make_buflist(
      TablineBufferBlock,
      { provider = require("icons").ArrowLeft, hl = { fg = "grey" } }, -- left truncation, optional (defaults to "<")
      { provider = require("icons").ArrowRight, hl = { fg = "grey" } } -- right trunctation, also optional (defaults to ...... yep, ">")
    -- by the way, open a lot of buffers and try clicking them ;)
    )

    local TabLineOffset = {
      condition = function(self)
        local win = vim.api.nvim_tabpage_list_wins(0)[1]
        local bufnr = vim.api.nvim_win_get_buf(win)
        self.winid = win

        if vim.bo[bufnr].filetype == "neo-tree" then
          self.title = "NeoTree"
          return true
          -- elseif vim.bo[bufnr].filetype == "TagBar" then
          --     ...
        end
      end,

      provider = function(self)
        local title = self.title
        local width = vim.api.nvim_win_get_width(self.winid)
        local leftpad = math.floor((width - #title) / 2)
        local rightpad = width - #title - leftpad
        return string.rep(" ", leftpad) .. title .. string.rep(" ", rightpad)
      end,

      hl = function(self)
        if vim.api.nvim_get_current_win() == self.winid then
          return "TablineSel"
        else
          return "Tabline"
        end
      end,
    }

    local Tabpage = {
      provider = function(self)
        return "%" .. self.tabnr .. "T " .. self.tabpage .. " %T"
      end,
      hl = function(self)
        if not self.is_active then
          return "TabLine"
        else
          return "TabLineSel"
        end
      end,
    }

    local TabpageClose = {
      provider = " " .. require("icons")["TabClose"] .. " ",
      hl = "TabLine",
      on_click = {
        callback = function()
          vim.schedule(function()
            vim.cmd.tabclose()
          end)
        end,
        name = "heirline_tabline_close_tab_callback",
      },
    }

    local TabPages = {
      -- only show this component if there's 2 or more tabpages
      condition = function()
        return #vim.api.nvim_list_tabpages() >= 2
      end,
      { provider = "%=" },
      utils.make_tablist(Tabpage),
      TabpageClose,
    }

    local TabLine = { TabLineOffset, BufferLine, TabPages }

    ---------------------- TabLine ended --------------------------

    ---------------------- statusline started --------------------------

    local ViMode = {
      -- get vim current mode, this information will be required by the provider
      -- and the highlight functions, so we compute it only once per component
      -- evaluation and store it as a component attribute
      init = function(self)
        self.mode = vim.fn.mode(1) -- :h mode()
      end,
      -- Now we define some dictionaries to map the output of mode() to the
      -- corresponding string and color. We can put these into `static` to compute
      -- them at initialisation time.
      static = {
        mode_colors = {
          n = "red",
          i = "green",
          v = "cyan",
          V = "cyan",
          ["\22"] = "cyan",
          c = "orange",
          s = "purple",
          S = "purple",
          ["\19"] = "purple",
          R = "orange",
          r = "orange",
          ["!"] = "red",
          t = "red",
        }
      },
      -- We can now access the value of mode() that, by now, would have been
      -- computed by `init()` and use it to index our strings dictionary.
      -- note how `static` fields become just regular attributes once the
      -- component is instantiated.
      -- To be extra meticulous, we can also add some vim statusline syntax to
      -- control the padding and make sure our string is always at least 2
      -- characters long. Plus a nice Icon.
      provider = function(self)
        return "█"
      end,
      -- Same goes for the highlight. Now the foreground will change according to the current mode.
      hl = function(self)
        local mode = self.mode:sub(1, 1) -- get only the first mode character
        return { fg = self.mode_colors[mode], bold = true, }
      end,
      -- Re-evaluate the component only on ModeChanged event!
      -- Also allows the statusline to be re-evaluated when entering operator-pending mode
      update = {
        "ModeChanged",
        pattern = "*:*",
        callback = vim.schedule_wrap(function()
          vim.cmd("redrawstatus")
        end),
      },
    }

    -- uses lewis6991/gitsigns.nvim
    local Git = {
      condition = conditions.is_git_repo,

      init = function(self)
        self.status_dict = vim.b.gitsigns_status_dict
        self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
      end,

      hl = { fg = "orange" },

      { -- git branch name
        provider = function(self)
          return require("icons").GitBranch .. " " .. self.status_dict.head
        end,
        hl = { bold = true }
      },
      -- You could handle delimiters, icons and counts similar to Diagnostics
      {
        provider = function(self)
          local count = self.status_dict.added or 0
          return count > 0 and (" " .. require("icons").GitAdd .. " " .. count)
        end,
        hl = { fg = "git_add" },
      },
      {
        provider = function(self)
          local count = self.status_dict.removed or 0
          return count > 0 and (" " .. require("icons").GitDelete .. " " .. count)
        end,
        hl = { fg = "git_del" },
      },
      {
        provider = function(self)
          local count = self.status_dict.changed or 0
          return count > 0 and (" " .. require("icons").GitChange .. " " .. count)
        end,
        hl = { fg = "git_change" },
      },
    }

    -- We're getting minimalist here!
    local Ruler = {
      -- %l = current line number
      -- %L = number of lines in the buffer
      -- %c = column number
      -- %P = percentage through file of displayed window
      provider = "%7(%l:%c%) %P",
    }

    -- I take no credits for this! 🦁
    local ScrollBar = {
      static = {
        sbar = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' }
      },
      provider = function(self)
        local curr_line = vim.api.nvim_win_get_cursor(0)[1]
        local lines = vim.api.nvim_buf_line_count(0)
        local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
        return string.rep(self.sbar[i], 2)
      end,
      hl = { fg = "blue", bg = "bright_bg" },
    }

    local Diagnostics = {
      condition = conditions.has_diagnostics,

      static = {
        error_icon = vim.diagnostic.config().signs.text[vim.diagnostic.severity.ERROR],
        warn_icon = vim.diagnostic.config().signs.text[vim.diagnostic.severity.WARN],
        info_icon = vim.diagnostic.config().signs.text[vim.diagnostic.severity.INFO],
        hint_icon = vim.diagnostic.config().signs.text[vim.diagnostic.severity.HINT],
      },

      init = function(self)
        self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
        self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
      end,

      -- FIXME: dosn't seem to work
      update = { "DiagnosticChanged", "BufEnter" },

      {
        provider = function(self)
          -- 0 is just another output, we can decide to print it or not!
          return self.errors > 0 and (self.error_icon .. " " .. self.errors .. " ")
        end,
        hl = { fg = "diag_error" },
      },
      {
        provider = function(self)
          return self.warnings > 0 and (self.warn_icon .. " " .. self.warnings .. " ")
        end,
        hl = { fg = "diag_warn" },
      },
      {
        provider = function(self)
          return self.info > 0 and (self.info_icon .. " " .. self.info .. " ")
        end,
        hl = { fg = "diag_info" },
      },
      {
        provider = function(self)
          return self.hints > 0 and (self.hint_icon .. " " .. self.hints)
        end,
        hl = { fg = "diag_hint" },
      },
    }

    local SearchCount = {
      condition = function()
        return vim.v.hlsearch ~= 0 and vim.o.cmdheight == 0
      end,
      init = function(self)
        local ok, search = pcall(vim.fn.searchcount)
        if ok and search.total then
          self.search = search
        end
      end,
      provider = function(self)
        local search = self.search
        return require("icons").Search ..
            " " .. string.format("[%d/%d]", search.current, math.min(search.total, search.maxcount))
      end,
    }

    local MacroRec = {
      condition = function()
        return vim.fn.reg_recording() ~= "" and vim.o.cmdheight == 0
      end,
      provider = require("icons").MacroRecording .. " ",
      utils.surround({ "[", "]" }, nil, {
        provider = function()
          return vim.fn.reg_recording()
        end,
      }),
      update = {
        "RecordingEnter",
        "RecordingLeave",
      }
    }

    local LSPActive = {
      condition = conditions.lsp_attached,
      update = { 'LspAttach', 'LspDetach' },

      -- You can keep it simple,
      -- provider = " [LSP]",

      -- Or complicate things a bit and get the servers names
      provider = function()
        local names = {}
        for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
          if server.name == "null-ls" then
            for _, source in ipairs(require("null-ls").get_sources()) do
              local filetype = vim.bo.filetype
              if source.filetypes[filetype] or source.filetypes["_all"] and source.filetypes[filetype] == nil then
                table.insert(names, source.name)
              end
            end
          else
            table.insert(names, server.name)
          end
        end

        for _, formater, is_lsp in ipairs(require("conform").list_formatters_to_run()) do
          if not is_lsp then
            table.insert(names, formater.name)
          end
        end

        return require("icons").ActiveLSP .. "  " .. table.concat(names, ", ") .. ""
      end,
      hl = { fg = "green", bold = true },
    }

    local FileNameBlock = {
      -- let's first set up some attributes needed by this component and its children
      init = function(self)
        self.filename = vim.api.nvim_buf_get_name(0)
      end,
    }

    local FileType = {
      provider = function()
        return vim.bo.filetype
      end,
      hl = { bold = true },
    }

    FileNameBlock = utils.insert(FileNameBlock, FileIcon, FileType)

    local DefaultStatusline = { ViMode, Space, FileNameBlock, Space, Git, Space, Diagnostics, Align,
      SearchCount, MacroRec,
      Align, LSPActive, Space, Ruler, Space, ScrollBar, Space, ViMode }

    local InactiveStatusline = {
      condition = conditions.is_not_active,
      FileType,
      Align,
    }

    local HelpFileName = {
      condition = function()
        return vim.bo.filetype == "help"
      end,
      provider = function()
        local filename = vim.api.nvim_buf_get_name(0)
        return vim.fn.fnamemodify(filename, ":t")
      end,
      hl = { fg = colors.blue },
    }

    local SpecialStatusline = {
      condition = function()
        return conditions.buffer_matches({
          buftype = { "nofile", "prompt", "help", "quickfix" },
          filetype = { "^git.*", "fugitive" },
        })
      end,

      ViMode,
      Space,
      FileType,
      Space,
      HelpFileName,
      Align,
      Ruler,
      Space,
      ScrollBar,
      Space,
      ViMode,
    }

    local TerminalName = {
      -- we could add a condition to check that buftype == 'terminal'
      -- or we could do that later (see #conditional-statuslines below)
      provider = function()
        local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
        return require("icons").Terminal .. " " .. tname
      end,
      hl = { fg = "blue", bold = true },
    }

    local TerminalStatusline = {

      condition = function()
        return conditions.buffer_matches({ buftype = { "terminal" } })
      end,

      -- Quickly add a condition to the ViMode to only show it when buffer is active!
      { condition = conditions.is_active, ViMode, Space },
      FileType,
      Space,
      TerminalName,
      Align,
      { condition = conditions.is_active, Space,  ViMode },
    }

    local StatusLines = {

      -- the first statusline with no condition, or which condition returns true is used.
      -- think of it as a switch case with breaks to stop fallthrough.
      fallthrough = false,

      SpecialStatusline,
      TerminalStatusline,
      InactiveStatusline,
      DefaultStatusline,
    }

    ---------------------- statusline ended --------------------------

    return vim.tbl_deep_extend("force", opts, {
      statusline = StatusLines,
      -- winbar = {},
      -- tabline = {},
      -- statuscolumn = {},
      tabline = TabLine,
    })
  end
}
