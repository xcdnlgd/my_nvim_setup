local followed_by = '[%s)%]}\'\"`;,.]'
local bracket_followed_by = '[%s)%]};,.]'
_G.cursorword_blocklist = function()
  local filetype = vim.bo.filetype
  local blocklist = { "neo-tree" }
  vim.b.minicursorword_disable = vim.tbl_contains(blocklist, filetype)
end
-- Make sure to add this autocommand *before* calling module's `setup()`.
vim.cmd('au CursorMoved * lua _G.cursorword_blocklist()')
return {
  {
    "echasnovski/mini.icons",
    lazy = true,
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
    opts = function(_, opts)
      if vim.g.icons_enabled == false then opts.style = "ascii" end
    end,
  },
  {
    'echasnovski/mini.trailspace',
    version = false,
    opts = function(_, _)
      vim.api.nvim_create_user_command("TrimSpace",
        function(_)
          vim.cmd("lua MiniTrailspace.trim()")
        end,
        {
          range = false,
        }
      )
    end
  },
  {
    'echasnovski/mini.cursorword',
    version = false,
    opts = {}
  },
  {
    "echasnovski/mini.pairs",
    enabled = true,
    version = false,
    opts = {
      mappings = {
        ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\]' .. bracket_followed_by },
        ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\]' .. bracket_followed_by },
        ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\]' .. bracket_followed_by },

        [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\]' .. bracket_followed_by },
        [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\]' .. bracket_followed_by },
        ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\]' .. bracket_followed_by },

        ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[%s\'`([{,]' .. followed_by, register = { cr = false } },
        ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[%s\"`([{,]' .. followed_by, register = { cr = false } },
        ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[%s\'\"([{,]' .. followed_by, register = { cr = false } },
      },
    }
  },
  {
    'nvim-mini/mini.files',
    version = false,
    opts = function(_, _)
      local MiniFiles = require("mini.files")
      vim.keymap.set("n", "<leader>e", function()
        if MiniFiles.get_explorer_state() == nil then
          MiniFiles.open()
        else
          MiniFiles.close()
        end
      end, { desc = "Toggle Explorer" })
      vim.api.nvim_set_hl(0, "MiniFilesNormal", { link = "Normal" })
      vim.api.nvim_set_hl(0, "MiniFilesBorder", { link = "Normal" })
      vim.api.nvim_set_hl(0, "MiniFilesTitle", { link = "Normal" })
      vim.api.nvim_set_hl(0, "MiniFilesTitleFocused", { link = "Green" })
      --       vim.api.nvim_set_hl(0, "MiniFilesCursorLine", { bg = "NONE" })
      return {
        mappings = {
          go_in = "L",
          go_out = "H",
          go_in_plus = "",
          go_out_plus = "",
        },
        windows = {
          preview = true,
        },
      }
    end
  },
}
