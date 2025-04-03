local not_following_char_except_for = function(except)
  return function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    local col = cursor[2]
    local char = line:sub(col, col)
    return vim.tbl_contains(except, char)
  end
end

local not_followed_by_char_except_for = function(except)
  return function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    local col = cursor[2]
    local char = line:sub(col + 1, col + 1)
    return vim.tbl_contains(except, char)
  end
end

return {
  'xcdnlgd/blink.pairs',
  -- version = '*', -- (recommended) only required with prebuilt binaries

  -- download prebuilt binaries from github releases
  -- dependencies = 'saghen/blink.download',
  -- OR build from source
  build = 'cargo build --release',
  opts = function()
    local except_for = { '', ' ', '\t', ")", "]", "}", [[']], [["]], "`", ";", ",", "." }
    return {
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
            when = not_followed_by_char_except_for(except_for)
          },
          ['['] = {
            ']',
            enter = false,
            when = not_followed_by_char_except_for(except_for)
          },
          ['{'] = {
            '}',
            enter = false,
            when = not_followed_by_char_except_for(except_for)
          },
          ["'"] = {
            {
              "'''",
              "'''",
              when = function()
                local cursor = vim.api.nvim_win_get_cursor(0)
                local line = vim.api.nvim_get_current_line()
                return line:sub(cursor[2] - 1, cursor[2]) == "''" and not_followed_by_char_except_for(except_for)()
              end,
              filetypes = { 'python' },
            },
            {
              "'",
              enter = false,
              when = function()
                local cursor = vim.api.nvim_win_get_cursor(0)
                local char = vim.api.nvim_get_current_line():sub(cursor[2], cursor[2])
                return not char:match('%w') and not_followed_by_char_except_for(except_for)() and
                    not_following_char_except_for({ "", " ", "\t", [[']], "(", "[", "{", "," })()
              end,
            },
          },
          ['"'] = {
            {
              'r#"',
              '"#',
              filetypes = { 'rust' },
              priority = 100,
              when = not_followed_by_char_except_for(except_for)
            },
            {
              '"""',
              '"""',
              when = function()
                local cursor = vim.api.nvim_win_get_cursor(0)
                local line = vim.api.nvim_get_current_line()
                return line:sub(cursor[2] - 1, cursor[2]) == '""' and not_followed_by_char_except_for(except_for)()
              end,
              filetypes = { 'python', 'elixir', 'julia', 'kotlin', 'scala', 'sbt' },
            },
            {
              '"',
              enter = false,
              when = function()
                return not_followed_by_char_except_for(except_for)() and
                    not_following_char_except_for({ "", " ", "\t", [["]], "(", "[", "{", "," })()
              end
            },
          },
          ['`'] = {
            {
              '```',
              '```',
              when = function()
                local cursor = vim.api.nvim_win_get_cursor(0)
                local line = vim.api.nvim_get_current_line()
                return line:sub(cursor[2] - 1, cursor[2]) == '``' and not_followed_by_char_except_for(except_for)()
              end,
              filetypes = { 'markdown', 'vimwiki', 'rmarkdown', 'rmd', 'pandoc', 'quarto', 'typst' },
            },
            {
              '`',
              enter = false,
              when = function()
                return not_followed_by_char_except_for(except_for)() and
                    not_following_char_except_for({ "", " ", "\t", [[`]], "(", "[", "{", "," })()
              end
            },
          },
        }
      }
    }
  end,
}
