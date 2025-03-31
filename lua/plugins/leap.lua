return {
  "ggandor/leap.nvim",
  config = function()
    vim.api.nvim_set_hl(0, "LeapLabel", { link = "Search" })
  end,
  keys = {
    { "s",  '<Plug>(leap-forward-to)',   mode = { 'n', 'x', 'o' } },
    { 'gs', '<Plug>(leap-cross-window)', mode = { "n" } },
    { 'S',  '<Plug>(leap-backward-to)',  mode = { 'n', 'x', 'o' } },
  }
}
