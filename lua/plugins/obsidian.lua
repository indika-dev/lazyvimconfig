local workspaces = function()
  if "stefan" == vim.env.USER then
    return {
      {
        name = "default workspace",
        path = vim.env.HOME .. "/Dokumente/obsidian/my-vault",
        overrides = {
          templates = {
            folder = "my-templates-folder",
            date_format = "%Y-%m-%d",
            time_format = "%H:%M",
            -- A map for custom variables, the key should be the variable and the value a function
            substitutions = {},
          },
        },
      },
    }
  else
    return {
      {
        name = "Makroarchitektur",
        path = vim.env.HOME .. "/Dokumente/obsidian-vault/Makroarchitektur",
        overrides = {
          templates = {
            folder = "Templates",
            date_format = "%Y-%m-%d",
            time_format = "%H:%M",
            -- A map for custom variables, the key should be the variable and the value a function
            substitutions = {},
          },
        },
      },
    }
  end
end

return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",
    },
    cmd = { "ObsidianOpen", "ObsidianNew", "ObsidianSearch", "ObsidianQuickSwitch", "ObsidianToday" },
    keys = {
      { "<leader>oO", "<cmd>ObsidianOpen<CR>", desc = "Open Obsidian" },
      { "<leader>on", "<cmd>ObsidianNew<CR>", desc = "New note" },
      { "<leader>os", "<cmd>ObsidianSearch<CR>", desc = "Search" },
      { "<leader>oo", "<cmd>ObsidianQuickSwitch<CR>", desc = "Find note" },
      { "<leader>ot", "<cmd>ObsidianToday<CR>", desc = "Open Today" },
      { "<leader>oT", "<cmd>ObsidianTemplate<CR>", desc = "Insert from template" },
    },
    opts = {
      workspaces = workspaces(),
    },
  },
}
