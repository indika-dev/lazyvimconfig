return {
  {
    "folke/lazydev.nvim",
    enabled = true,
    dependencies = {
      "DrKJeff16/wezterm-types",
    },
    opts = {
      library = {
        "~/Projekte/kotlin.nvim/",
        -- Lädt die Typen für vim.api, vim.fn, vim.loop etc.
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        -- { path = "luvit-meta/library", words = { "vim%.uv" } },
        { path = "wezterm-types", mods = { "wezterm" } },
      },
    },
  },
}
