return {
  'saghen/blink.pairs',
  version = '*', -- (recommended) only required with prebuilt binaries

  -- download prebuilt binaries from github releases
  dependencies = 'saghen/blink.download',
  -- OR build from source
  -- build = 'cargo build --release',
  opts = {
    highlights = {
      enabled = true,
      groups = {
        'Orange',
        'Purple',
        'Blue',
      },
    },
  }
}
