-- Plugins: Tree-sitter and Syntax
-- https://github.com/rafi/vim-config

return {

  -----------------------------------------------------------------------------
  -- Vimscript syntax/indent plugins
  { "chrisbra/csv.vim", ft = "csv" },
  { "lifepillar/pgsql.vim", ft = "pgsql" },
  { "MTDL9/vim-log-highlighting", ft = "log" },

  -----------------------------------------------------------------------------
  -- Nvim Treesitter configurations and abstraction layer
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "comment",
        "css",
        "cue",
        "diff",
        "fish",
        "fennel",
        "git_config",
        "git_rebase",
        "gitcommit",
        "gitignore",
        "gitattributes",
        "graphql",
        "glimmer",
        "hcl",
        "html",
        "http",
        "java",
        "javascript",
        "jsdoc",
        "kotlin",
        "lua",
        "luadoc",
        "luap",
        "make",
        "markdown",
        "markdown_inline",
        "nix",
        "perl",
        "php",
        "pug",
        "regex",
        "scala",
        "scss",
        "sql",
        "svelte",
        "todotxt",
        "toml",
        "vim",
        "vimdoc",
        "vue",
        "zig",
      },
    },
  },
}
