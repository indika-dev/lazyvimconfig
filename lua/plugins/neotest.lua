return {
  { "nvim-neotest/neotest-plenary" },
  -- { "rcasia/neotest-java" },
  { "atm1020/neotest-jdtls" },
  { "beneeng/neotest-gradle" },
  -- {   "weilbith/neotest-gradle"},
  { "codymikol/neotest-kotlin" },
  {
    "nvim-neotest/neotest",
    event = "LspAttach",
    opts = { adapters = { "neotest-jdtls", "neotest-kotlin", "neotest-plenary" } },
  },
}
