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
      -- LazyVim extension to easily override linter options
      -- or add custom linters.
      ---@type table<string,table>
      linters = {
        -- -- Example of using selene only when a selene.toml file is present
        -- selene = {
        --   -- `condition` is another LazyVim extension that allows you to
        --   -- dynamically enable/disable linters based on the context.
        --   condition = function(ctx)
        --     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
        prepend_args = {
          "--profile=handlebars",
          "--lint",
        },
      },
    },
  },
}
