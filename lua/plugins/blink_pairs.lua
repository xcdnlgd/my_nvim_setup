local not_followed_by_char = function(pair)
  return function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    local col = cursor[2]
    local char = line:sub(col + 1, col + 1)
    return char == '' or char == ' ' or char == '\t' or char == pair
  end
end

return {
  'xcdnlgd/blink.pairs',
  -- version = '*', -- (recommended) only required with prebuilt binaries

  -- download prebuilt binaries from github releases
  -- dependencies = 'saghen/blink.download',
  -- OR build from source
  build = 'cargo build --release',
  opts = {
    highlights = {
      enabled = true,
      groups = {
        'Orange',
        'Purple',
        'Blue',
      },
    },
    mappings = {
      enabled = true,
      pairs = {
        ['('] = {
          ')',
          enter = false,
          when = not_followed_by_char(')')
        },
        ['['] = {
          ']',
          enter = false,
          when = not_followed_by_char(']')
        },
        ['{'] = {
          '}',
          enter = false,
          when = not_followed_by_char('}')
        },
      }
    }
  }
}
