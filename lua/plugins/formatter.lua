return {
  {
    "stevearc/conform.nvim",
    ---@class ConformOpts
    opts = {
      ---@type table<string, conform.FormatterUnit[]>
      formatters_by_ft = {
        mustache = { "djlint" },
        handlebars = { "djlint" },
        sh = { "shfmt" },
        json = { "fixjson" },
        xml = { "prettier" },
      },
      -- The options you set here will be merged with the builtin formatters.
      -- You can also define any custom formatters here.
      ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
      formatters = {
        injected = { options = { ignore_errors = true } },
        -- # Example of using dprint only when a dprint.json file is present
        -- dprint = {
        --   condition = function(ctx)
        --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
        --
        -- # Example of using shfmt with extra args
        -- shfmt = {
        --   prepend_args = { "-i", "2", "-ci" },
        -- },
        djlint = {
          prepend_args = {
            "--profile=handlebars",
            "--reformat",
            "--line-break-after-multiline-tag",
            "--max-blank-lines",
            "2",
            "--preserve-blank-lines",
            "--preserve-leading-space",
          },
        },
      },
    },
  },
}
