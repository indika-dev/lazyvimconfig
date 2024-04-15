return {
  {
    "LiadOz/nvim-dap-repl-highlights",
    opts = {},
    config = function(_, opts)
      require("nvim-dap-repl-highlights").setup(opts)
    end,
  },
}
