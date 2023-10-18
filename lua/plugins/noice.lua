if false then
  return {}
end
return {
  {
    "folke/noice.nvim",
    require("noice").setup({
      routes = {
        {
          filter = {
            event = "lsp",
            kind = "progress",
            find = "jdtls",
          },
          opts = { skip = true },
        },
      },
    }),
  },
}
