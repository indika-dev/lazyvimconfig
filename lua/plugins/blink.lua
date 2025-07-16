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
        -- Recommended to avoid unnecessary request
        completion = { trigger = { prefetch_on_insert = false } },
      },
      sources = {
        default = { "lsp", "path", "buffer", "snippets", "minuet" },
        providers = {
          minuet = {
            name = "minuet",
            module = "minuet.blink",
            async = true,
            -- Should match minuet.config.request_timeout * 1000,
            -- since minuet.config.request_timeout is in seconds
            timeout_ms = 3000,
            score_offset = 50, -- Gives minuet higher priority among suggestions
          },
        },
      },
      -- experimental signature help support
      signature = { enabled = true },
    },
  },
}
