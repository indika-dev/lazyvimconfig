return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "codelldb",
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
        "vscode-spring-boot-tools",
      })
      opts.registries = {
        "github:indika-dev/personal-mason-registry",
        "github:mason-org/mason-registry",
      }
    end,
  },
}
