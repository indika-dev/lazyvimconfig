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
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
        },
        menu = {
          auto_show = true,
        },
        ghost_text = {
          enabled = false,
        },
      },

      -- experimental signature help support
      signature = { enabled = true },
    },
  },
}
