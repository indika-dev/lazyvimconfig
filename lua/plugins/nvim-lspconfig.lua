if true then
  return {}
end
return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = {
        enabled = false,
      },
      -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the code lenses.
      codelens = {
        enabled = false,
      },
      servers = {
        lemminx = {
          settings = {
            xsl = {
              format = {
                enabled = true,
                insertSpaces = true,
                tabSize = 2,
              },
            },
            xslt = {
              format = {
                enabled = true,
                insertSpaces = true,
                tabSize = 2,
              },
            },
          },
        },
      },
    },
  },
}
