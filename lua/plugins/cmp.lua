require("cmp").register_source("pivio", require("util/cmp_pivio"))

return {
  {
    "hrsh7th/nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, { name = "pivio" })
    end,
  },
}
