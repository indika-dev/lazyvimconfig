return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
        "jsonlint",
        "fixjson",
        "bash-language-server",
        "lemminx",
        "vscode-java-decompiler",
        "yamlfmt",
        "yamllint",
        "djlint",
        "jdtls",
        "yq",
      },
      -- registries = {
      --   "file:~/workspace/mason-registry",
      -- },
    },
  },
}
