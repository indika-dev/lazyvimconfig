return {
  {
    "atm1020/neotest-jdtls",
  },
  {
    "weilbith/neotest-gradle",
  },
  {
    "codymikol/neotest-kotlin",
  },
  {
    "nvim-neotest/neotest-plenary",
  },
  {
    "nvim-neotest/neotest",
    event = "LspAttach",
    opts = function(_, opts)
      opts.adapters = { "neotest-jdtls", "neotest-kotlin", "neotest-plenary" }
    end,
  },
}
