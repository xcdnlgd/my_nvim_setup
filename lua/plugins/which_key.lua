return {
  "folke/which-key.nvim",
  opts = function(_, opts)
    local wk = require("which-key")
    wk.add({
      { "<leader>b", group = "Buffer" },
      { "<leader>c", group = "Compile",        mode = "n" },
      { "<leader>f", group = "Find",           mode = "n" },
      { "<leader>t", group = "Terminal",       mode = "n" },
      { "<leader>g", group = "Git",            mode = "n" },
      { "<leader>u", group = "UI/UX",          mode = "n" },
      { "<leader>l", group = "Language Tools", mode = { "n", "v" } },
    })
    if not opts.icons then opts.icons = {} end
    opts.icons.group = ""
    opts.icons.rules = false
    opts.icons.separator = "-"
    opts.delay = 400
  end
}
