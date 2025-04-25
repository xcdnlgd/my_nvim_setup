local followed_by = '[%s)%]}\'\"`;,.]'
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
    opts = {}
  },
  {
    'echasnovski/mini.cursorword',
    version = false,
    opts = {}
  },
  {
    "echasnovski/mini.pairs",
    version = false,
    opts = {
      mappings = {
        ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\]' .. followed_by },
        ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\]' .. followed_by },
        ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\]' .. followed_by },

        [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
        [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
        ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },

        ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[%s"([{,]' .. followed_by, register = { cr = false } },
        ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[%s\'([{,]' .. followed_by, register = { cr = false } },
        ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[%s`([{,]' .. followed_by, register = { cr = false } },
      },
    }
  }
}
