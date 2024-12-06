return {
  {
    "L3MON4D3/LuaSnip",
    config = function()
      local ls = require("luasnip")
      ls.add_snippets(nil, require("util/luaSnippets"))
      require("luasnip.loaders.from_vscode").load({ paths = { vim.fn.stdpath("config") .. "/snippets/" } })
    end,
  },
}
