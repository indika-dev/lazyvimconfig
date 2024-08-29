return {
  {
    "L3MON4D3/LuaSnip",
    config = function()
      -- Beside defining your own snippets you can also load snippets from "vscode-like" packages
      -- that expose snippets in json files, for example <https://github.com/rafamadriz/friendly-snippets>.

      -- require("luasnip.loaders.from_vscode").load({ include = { "python" } }) -- Load only python snippets

      -- The directories will have to be structured like eg. <https://github.com/rafamadriz/friendly-snippets> (include
      -- a similar `package.json`)
      -- require("luasnip.loaders.from_vscode").load({ paths = { "./snippets" } }) -- Load snippets from my-snippets folder

      -- You can also use lazy loading so snippets are loaded on-demand, not all at once (may interfere with lazy-loading luasnip itself).
      -- require("luasnip.loaders.from_vscode").lazy_load() -- You can pass { paths = "./my-snippets/"} as well

      -- You can also use snippets in snipmate format, for example <https://github.com/honza/vim-snippets>.
      -- The usage is similar to vscode.

      -- One peculiarity of honza/vim-snippets is that the file containing global
      -- snippets is _.snippets, so we need to tell luasnip that the filetype "_"
      -- contains global snippets:
      -- ls.filetype_extend("all", { "_" })

      -- require("luasnip.loaders.from_snipmate").load({ include = { "c" } }) -- Load only snippets for c.

      -- Load snippets from my-snippets folder
      -- The "." refers to the directory where of your `$MYVIMRC` (you can print it
      -- out with `:lua print(vim.env.MYVIMRC)`.
      -- NOTE: It's not always set! It isn't set for example if you call neovim with
      -- the `-u` argument like this: `nvim -u yeet.txt`.
      -- require("luasnip.loaders.from_snipmate").load({ path = { "./snippets" } })
      -- If path is not specified, luasnip will look for the `snippets` directory in rtp (for custom-snippet probably
      -- `~/.config/nvim/snippets`).

      -- require("luasnip.loaders.from_snipmate").lazy_load() -- Lazy loading

      -- see DOC.md/LUA SNIPPETS LOADER for some details.
      -- require("luasnip.loaders.from_lua").load()

      local ls = require("luasnip")
      ls.add_snippets(nil, require("util/luaSnippets"))
    end,
  },
}
