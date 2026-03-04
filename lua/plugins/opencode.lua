return {
  "nickjvandyke/opencode.nvim",
  version = "0.4",
  config = function()
    vim.g.opencode_opts = {
      provider = {
        tmux = {
          options = "-h -l 80", -- Open in a horizontal split
          focus = false, -- Keep focus in Neovim
          -- Disables allow-passthrough in the tmux split
          -- preventing OSC escape sequences from leaking into the nvim buffer
          allow_passthrough = false,
        },
      }
    }
    vim.o.autoread = true

    vim.keymap.set({ "n", "x" }, "<leader>a", function() require("opencode").ask("@this: ", { submit = true }) end,
      { desc = "Ask opencode…" })
  end
}
