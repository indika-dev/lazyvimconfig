return {
  {
    "fladson/vim-kitty",
  },
  {
    "knubie/vim-kitty-navigator",
    build = "cp ./*.py ~/.config/kitty/",
  },
  -- {
  --   "MunsMan/kitty-navigator.nvim",
  --   build = {
  --     "cp navigate_kitty.py ~/.config/kitty",
  --     "cp pass_keys.py ~/.config/kitty",
  --   },
  --   keys = {
  --     {
  --       "<C-h>",
  --       function()
  --         require("kitty-navigator").navigateLeft()
  --       end,
  --       desc = "Move left a Split",
  --       mode = { "n" },
  --     },
  --     {
  --       "<C-j>",
  --       function()
  --         require("kitty-navigator").navigateDown()
  --       end,
  --       desc = "Move down a Split",
  --       mode = { "n" },
  --     },
  --     {
  --       "<C-k>",
  --       function()
  --         require("kitty-navigator").navigateUp()
  --       end,
  --       desc = "Move up a Split",
  --       mode = { "n" },
  --     },
  --     {
  --       "<C-l>",
  --       function()
  --         require("kitty-navigator").navigateRight()
  --       end,
  --       desc = "Move right a Split",
  --       mode = { "n" },
  --     },
  --   },
  -- },
  {
    "mikesmithgh/kitty-scrollback.nvim",
    enabled = true,
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
