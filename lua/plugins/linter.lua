-- local pattern = '[^:]+:(%d+):(%d+):(%w+):(.+)'
-- local groups = { 'lnum', 'col', 'code', 'message' }
-- local default_severity = {
-- ['error'] = vim.diagnostic.severity.ERROR,
-- ['warning'] = vim.diagnostic.severity.WARN,
-- ['information'] = vim.diagnostic.severity.INFO,
-- ['hint'] = vim.diagnostic.severity.HINT,
-- }

local djlint = require("lint").linters.djlint
djlint.args = {
  "-",
  "--profile",
  "handlebars",
  "--lint",
  "-e",
  "mustache",
}
djlint.stdin = true

return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        ["mustache"] = { "djlint" },
      },
      --       -- LazyVim extension to easily override linter options
      --       -- or add custom linters.
      --       ---@type table<string,table>
      --             linters = {
      --               my_djlint = {
      --                 cmd = "/home/maassens/.local/share/nvim/mason/bin/djlint",
      --                 args = {
      --                   "-",
      --                   "--profile",
      --                   "handlebars",
      --                   "--lint",
      --                   "-e",
      --                   "mustache",
      --                   "--quiet",
      --                 },
      --       parser = require('lint.parser').from_errorformat(errorformat)
      --               },
      --             },
    },
  },
}
