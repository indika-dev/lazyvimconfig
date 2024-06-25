-- local pattern = '[^:]+:(%d+):(%d+):(%w+):(.+)'
-- local groups = { 'lnum', 'col', 'code', 'message' }
-- local default_severity = {
-- ['error'] = vim.diagnostic.severity.ERROR,
-- ['warning'] = vim.diagnostic.severity.WARN,
-- ['information'] = vim.diagnostic.severity.INFO,
-- ['hint'] = vim.diagnostic.severity.HINT,
-- }

return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      -- Event to trigger linters
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        mustache = { "djlint" },
        handlebars = { "djlint" },
        yaml = { "yamllint" },
        json = { "jsonlint" },
        -- Use the "*" filetype to run linters on all filetypes.
        -- ['*'] = { 'global linter' },
        -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
        -- ['_'] = { 'fallback linter' },
      },
    },
  },
}
