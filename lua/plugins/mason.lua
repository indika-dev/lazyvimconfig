return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "shfmt",
        "shellcheck",
        "bash-language-server",
        "luacheck",
        "stylua",
        "lemminx",
        "prettier",
        "eslint_d",
        "eslint-lsp",
        "marksman",
        "dockerfile-language-server",
        "css-lsp",
        "fixjson",
        "json-lsp",
        "jsonlint",
        "html-lsp",
        "tailwindcss-language-server",
        "taplo",
        "typescript-language-server",
        "vscode-java-decompiler",
        "yaml-language-server",
        "yamllint",
      })
    end,
  },
}
