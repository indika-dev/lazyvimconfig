return {
  { "antoinemadec/FixCursorHold.nvim" },
  -- { "rcasia/neotest-java" },
  { "atm1020/neotest-jdtls" },
  -- { "weilbith/neotest-gradle" },
  -- { "beneeng/neotest-gradle", dev = true, dir = "/home/stefan/Projekte/neotest-gradle" },
  { "bkolof/neotest-gradle" },
  -- { "codymikol/neotest-kotlin", branch = "v2.0.0" },
  {
    "nvim-neotest/neotest",
    event = "LspAttach",
    opts = {
      adapters = { "neotest-gradle", "neotest-jdtls" },
      output = {
        enabled = true,
        open_on_run = "short",
      },
    },

    --   vim.api.nvim_create_autocmd("User", {
    --     pattern = "NeotestFinished",
    --     callback = function()
    --       -- schedule it in case we’re still in a libuv callback
    --       vim.schedule(function()
    --         vim.cmd.redraw()
    --       end)
    --     end,
    --   })
    -- end,
  },
}
