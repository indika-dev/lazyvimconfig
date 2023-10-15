return {
  {
    "tamago324/nlsp-settings.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      config_home = vim.fn.stdpath("config") .. "/nlsp-settings",
      local_settings_dir = ".nlsp-settings",
      local_settings_root_markers_fallback = { ".git" },
      append_default_schemas = true,
      loader = "json",
    },
    config = function(_, opts)
      require("nlspsettings").setup(opts)
    end,
  },
}
