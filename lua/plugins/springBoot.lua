return {
  {
    "JavaHello/spring-boot.nvim",
    ft = "java",
    init = function()
      vim.g.spring_boot = {
        jdt_extensions_path = vim.env.HOME .. "/.local/lib/spring-boot-tools/extension", -- 默认使用 ~/.vscode/extensions/vmware.vscode-spring-boot-x.xx.x
        jdt_extensions_jars = {
          "/jars/io.projectreactor.reactor-core.jar",
          "/jars/org.reactivestreams.reactive-streams.jar",
          "/jars/jdt-ls-commons.jar",
          "/jars/jdt-ls-extension.jar",
        },
      }
    end,
    opts = function()
      return {
        ls_path = vim.g.spring_boot.jdt_extensions_path .. "/language-server",
        java_cmd = vim.env.HOME .. "/.local/lib/semeru-17/bin/java",
      }
    end,
    config = function(_, opts)
      local spring_boot = require("spring_boot")
      spring_boot.setup(opts)
      spring_boot.init_lsp_commands()
    end,
  },
}
