return {
  {
    "crnvl96/lazydocker.nvim",
    event = "VeryLazy",
    opts = {
      popup_window = {
        enter = true,
        focusable = true,
        zindex = 40,
        position = "50%",
        relative = "editor",
        size = {
          width = "90%",
          height = "90%",
        },
        buf_options = {
          modifiable = true,
          readonly = false,
        },
        win_options = {
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
          winblend = 0,
        },
        border = {
          highlight = "FloatBorder",
          style = "rounded",
          text = {
            top = " Lazydocker ",
          },
        },
      },
    }, -- automatically calls `require("lazydocker").setup()`
    config = function(_, opts)
      require("lazydocker").setup(opts)
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },
}
