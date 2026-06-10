return {
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.icons = {
        rules = {
          { pattern = "acp", icon = "󱙺", color = "orange" },
        },
      }
    end,
  },
}
