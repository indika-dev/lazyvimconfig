---@diagnostic disable: undefined-global
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      kmp_lsp = {
        cmd = {
          "kmp-lsp",
          "--gradle-home",
          "/home/stefan/.sdkman/candidates/gradle/current/bin/gradle",
        },
        filetypes = { "kotlin", "java", "swift" },
        root_dir = require("lspconfig").util.root_pattern(
          "build.gradle",
          "build.gradle.kts",
          "pom.xml",
          "settings.gradle",
          "Package.swift",
          ".git"
        ),
        settings = {},
      },
    },
  },
}
