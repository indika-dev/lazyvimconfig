return {
  {
    "JavaHello/spring-boot.nvim",
    dir = "/Users/maassens/workspace/spring-boot.nvim",
    dev = { true },
    ft = { "jproperties", "java" },
    opts = function()
      require("mason").setup()
      local success, mason_registry = pcall(require, "mason-registry")
      if success then
        mason_registry.refresh()
      end
      vim.api.nvim_create_user_command("SpringBootSymbols", function(_)
        require("fzf-lua").lsp_live_workspace_symbols()
      end, { nargs = 0 })
      return {
        java_cmd = vim.env.HOME .. "/.local/lib/jvm-jdtls/bin/java",
      }
    end,
  },
}
