return {
  "lewis6991/gitsigns.nvim",
  enabled = vim.fn.executable "git" == 1,
  opts = function(_, opts)
    return vim.tbl_extend("force", opts, {
      signs = {
        add = { text = require("icons").GitSign },
        change = { text = require("icons").GitSign },
        delete = { text = require("icons").GitSign },
        topdelete = { text = require("icons").GitSign },
        changedelete = { text = require("icons").GitSign },
        untracked = { text = require("icons").GitSign },
      },
      signs_staged = {
        add = { text = require("icons").GitSign },
        change = { text = require("icons").GitSign },
        delete = { text = require("icons").GitSign },
        topdelete = { text = require("icons").GitSign },
        changedelete = { text = require("icons").GitSign },
        untracked = { text = require("icons").GitSign },
      },
      on_attach = function(bufnr)
        vim.keymap.set("n", "<leader>gl", function() require("gitsigns").blame_line() end,
          { buffer = bufnr, desc = "View Git blame" })
        vim.keymap.set("n", "<leader>gL", function() require("gitsigns").blame_line { full = true } end,
          { buffer = bufnr, desc = "View full Git blame" })
        vim.keymap.set("n", "<leader>gp", function() require("gitsigns").preview_hunk_inline() end,
          { buffer = bufnr, desc = "Preview Git hunk" })
        vim.keymap.set("n", "<leader>gr", function() require("gitsigns").reset_hunk() end,
          { buffer = bufnr, desc = "Reset Git hunk" })
        vim.keymap.set("v", "<leader>gr",
          function() require("gitsigns").reset_hunk { vim.fn.line ".", vim.fn.line "v" } end,
          { buffer = bufnr, desc = "Reset Git hunk", })
        vim.keymap.set("n", "<leader>gR", function() require("gitsigns").reset_buffer() end,
          { buffer = bufnr, desc = "Reset Git buffer" })
        vim.keymap.set("n", "<leader>gs", function() require("gitsigns").stage_hunk() end,
          { buffer = bufnr, desc = "Stage/Unstage Git hunk" })
        vim.keymap.set("v", "<leader>gs",
          function() require("gitsigns").stage_hunk { vim.fn.line ".", vim.fn.line "v" } end,
          { buffer = bufnr, desc = "Stage Git hunk", })
        vim.keymap.set("n", "<leader>gS", function() require("gitsigns").stage_buffer() end,
          { buffer = bufnr, desc = "Stage Git buffer" })
        vim.keymap.set("n", "<leader>gd", function() require("gitsigns").diffthis() end,
          { buffer = bufnr, desc = "View Git diff" })

        vim.keymap.set("n", "[G", function() require("gitsigns").nav_hunk "first" end,
          { buffer = bufnr, desc = "First Git hunk" })
        vim.keymap.set("n", "]G", function() require("gitsigns").nav_hunk "last" end,
          { buffer = bufnr, desc = "Last Git hunk" })
        vim.keymap.set("n", "]g", function() require("gitsigns").nav_hunk "next" end,
          { buffer = bufnr, desc = "Next Git hunk" })
        vim.keymap.set("n", "[g", function() require("gitsigns").nav_hunk "prev" end,
          { buffer = bufnr, desc = "Previous Git hunk" })
        vim.keymap.set({ "o", "x" }, "ig", ":<C-U>Gitsigns select_hunk<CR>", { desc = "inside Git hunk" })
      end,
    })
  end,
}
