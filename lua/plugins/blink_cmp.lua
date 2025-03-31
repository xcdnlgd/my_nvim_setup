return {
  'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets' },
  version = '1.*',
  opts = {
    keymap = {
      preset = 'super-tab',
      ["<C-k>"] = { 'select_prev', 'fallback' },
      ["<C-j>"] = { 'select_next', 'fallback' },
    },
    signature = {
      enabled = true,
      window = {
        show_documentation  = false,
      },
    },
    appearance = {
      nerd_font_variant = 'mono'
    },
    completion = { documentation = { auto_show = false } },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    cmdline = {
      enabled = false,
    },
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
}
