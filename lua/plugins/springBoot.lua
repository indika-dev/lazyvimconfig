return {
  {
    "JavaHello/spring-boot.nvim",
    ft = "java",
    dependencies = {
      "mfussenegger/nvim-jdtls",
    },
    opts = function()
      require("spring_boot").init_lsp_commands()
      return {
        -- ls_path = vim.g.spring_boot.jdt_extensions_path .. "/language-server",
        java_cmd = vim.env.HOME .. "/.local/lib/semeru-17/bin/java",
      }
    end,
  },
}
