return {
  "ggandor/leap.nvim",
  config = function()
    vim.api.nvim_set_hl(0, "LeapLabel", { link = "Search" })
  end,
  keys = {
    { "s",  '<Plug>(leap-forward)',   mode = { 'n', 'x', 'o' } },
    { 'S',  '<Plug>(leap-backward)',  mode = { 'n', 'x', 'o' } },
  }
}
