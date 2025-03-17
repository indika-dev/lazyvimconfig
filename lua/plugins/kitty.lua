local runs_in_kitty = true -- os.getenv("$TERM") == "xterm-kitty"

return {
  {
    "fladson/vim-kitty",
    enabled = runs_in_kitty,
  },
  {
    "knubie/vim-kitty-navigator",
    build = "cp ./*.py ~/.config/kitty/",
    enabled = runs_in_kitty,
  },
  {
    "mikesmithgh/kitty-scrollback.nvim",
    enabled = runs_in_kitty,
    lazy = true,
    cmd = {
      "KittyScrollbackGenerateKittens",
      "KittyScrollbackCheckHealth",
      "KittyScrollbackGenerateCommandLineEditing",
    },
    event = { "User KittyScrollbackLaunch" },
    opts = function()
      search = {
        callbacks = {
          after_ready = function()
            vim.api.nvim_feedkeys("?", "n", false)
          end,
        },
      }
      return search
    end,
  },
}
