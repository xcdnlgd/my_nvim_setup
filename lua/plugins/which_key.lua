return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    if not opts.icons then opts.icons = {} end
    opts.icons.group = ""
    opts.icons.rules = false
    opts.icons.separator = "-"
  end
}
