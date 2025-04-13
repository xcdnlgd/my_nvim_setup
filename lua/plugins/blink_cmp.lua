return {
  "Saghen/blink.cmp",
  dependencies = { 'rafamadriz/friendly-snippets' },
  -- use a release tag to download pre-built binaries
  -- version = '1.*',
  -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  build = 'cargo build --release',
  opts = {
    keymap = {
      preset = 'super-tab',
      ["<C-k>"] = { 'select_prev', 'fallback' },
      ["<C-j>"] = { 'select_next', 'fallback' },
      ["<C-n>"] = { 'snippet_forward', 'fallback' },
      ["<C-p>"] = { 'snippet_backward', 'fallback' },
      ["<Tab>"] = { 'select_and_accept', 'fallback' }
    },
    signature = {
      enabled = true,
      window = {
        show_documentation = false,
      },
    },
    appearance = {
      nerd_font_variant = 'mono'
    },
    completion = {
      documentation = { auto_show = false },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    cmdline = {
      enabled = false,
    },
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
}
