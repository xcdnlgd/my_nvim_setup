return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local languages = {
      "bash", "c", "lua", "markdown", "markdown_inline", "python", "query", "vim", "vimdoc", "rust", "toml", "cpp",
      "html", "css", "json", "yaml", "go", "javascript", "typescript"
    }
    require('nvim-treesitter').install(languages)
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { '<filetype>' },
      callback = function() vim.treesitter.start() end,
    })

    vim.api.nvim_create_autocmd('FileType', {
      pattern = languages,
      callback = function()
        -- syntax highlighting, provided by Neovim
        vim.treesitter.start()
        -- folds, provided by Neovim
        -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        -- vim.wo.foldmethod = 'expr'
        -- indentation, provided by nvim-treesitter
        -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
