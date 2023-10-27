return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    keys = {
      {
        "<leader>do",
        function()
          require("dap").step_over({})
        end,
        desc = "Step Over",
      },
      {
        "<leader>dO",
        function()
          require("dapui").step_out()
        end,
        desc = "Step Out",
      },
    },
  },
}
