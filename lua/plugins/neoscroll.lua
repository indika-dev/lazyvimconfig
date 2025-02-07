return {
  {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    enabled = function()
      return not vim.g.neovide and not vim.g.nvui
    end,
  },
}
