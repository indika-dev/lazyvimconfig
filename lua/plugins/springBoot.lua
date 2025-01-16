return {
  {
    "JavaHello/spring-boot.nvim",
    ft = { "jproperties" },
    opts = function()
      require("mason").setup()
      local success, mason_registry = pcall(require, "mason-registry")
      if success then
        mason_registry.refresh()
      end
      vim.api.nvim_create_user_command("SpringBootSymbols", function(_)
        -- vim.cmd({ cmd = "FzfLua", args = { "lsp_live_workspace_symbols" } })
        require("fzf-lua").lsp_live_workspace_symbols()
      end, { nargs = 0 })
      return {
        java_cmd = vim.env.HOME .. "/.local/lib/semeru-17/bin/java",
      }
    end,
  },
}
