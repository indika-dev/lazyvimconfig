return {
  {
    "rcasia/neotest-java",
    ft = "java",
    dependencies = {
      "mfussenegger/nvim-jdtls",
      "mfussenegger/nvim-dap", -- for debugging (optional)
      "rcarriga/nvim-dap-ui", -- recommended
      "theHamsta/nvim-dap-virtual-text", -- recommended
    },
  },
  {
    "atm1020/neotest-jdtls",
    dependencies = {
      "nvim-neotest/neotest",
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "rcasia/neotest-java",
      "atm1020/neotest-jdtls",
      "weilbith/neotest-gradle",
      "codymikol/neotest-kotlin",
    },
    opts = function()
      return {
        adapters = {
          ["neotest-jdtls"] = {},
          ["neotest-kotlin"] = {},
        },
      }
    end,
  },
}
