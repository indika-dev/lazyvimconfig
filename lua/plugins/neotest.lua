return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "rcasia/neotest-java",
      "atm1020/neotest-jdtls",
      "weilbith/neotest-gradle",
      "codymikol/neotest-kotlin",
      "nvim-neotest/neotest-plenary",
    },
    opts = function()
      return {
        adapters = {
          ["neotest-jdtls"] = {},
          ["neotest-kotlin"] = {},
          ["neotest-plenary"] = {},
        },
      }
    end,
  },
}
