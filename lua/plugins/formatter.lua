return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        mustache = { "djlint" },
        sh = { "shfmt" },
        json = { "fixjson" },
        xml = { "prettier" },
      },
    },
  },
}
