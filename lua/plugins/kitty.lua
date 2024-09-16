return {
  {
    "fladson/vim-kitty",
  },
  {
    "knubie/vim-kitty-navigator",
  },
  {
    "mikesmithgh/kitty-scrollback.nvim",
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
