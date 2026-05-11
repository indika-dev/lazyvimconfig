return {
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({})
    end,
    -- opts = {
    --   manual_mode = true,
    --   sync_root_with_cwd = true,
    --   respect_buf_cwd = true,
    --   update_focused_file = {
    --     enable = true,
    --     update_root = true,
    --   },
    -- },
  },
  -- {
  --   "nvim-tree",
  --   opts = {
  --     sync_root_with_cwd = true,
  --     respect_buf_cwd = true,
  --     update_focused_file = {
  --       enable = true,
  --       update_root = true,
  --     },
  --   },
  -- },
}
