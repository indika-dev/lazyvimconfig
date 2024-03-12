return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["mustache"] = { "my_djlint" },
      },
      formatters = {
        my_djlint = {
          -- condition = function(ctx)
          --   return vim.fs.find({ "mustache" }, { path = ctx.filename, upward = true })[1]
          -- end,
          stdin = true,
          stream = "stderr",
          command = "/home/maassens/.local/share/nvim/mason/bin/djlint",
          args = {
            "-",
            "--preserve-blank-lines",
            "--preserve-leading-space",
            "--profile",
            "handlebars",
            "--reformat",
            "-e",
            "mustache",
            "--quiet",
          },
        },
      },
    },
  },
}
