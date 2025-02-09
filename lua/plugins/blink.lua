return {
  {
    "saghen/blink.cmp",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      completion = {
        list = {
          selection = {
            auto_insert = false,
          },
        },
      },

      -- experimental signature help support
      -- signature = { enabled = true },
    },
  },
}
