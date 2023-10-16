return {
  {
    "epwalsh/obsidian.nvim",
    dependencies = {
      -- "preservim/vim-markdown",
      -- "godlygeek/tabular",
    },
    keys = {
      {
        "gl",
        function()
          if require("obsidian").util.cursor_on_markdown_link() then
            return "<cmd>ObsidianFollowLink<CR>"
          else
            return "gl"
          end
        end,
      },
    },
    opts = function()
      local options = {
        completion = {
          nvim_cmp = true, -- if using nvim-cmp, otherwise set to false
        },
        note_id_func = function(title)
          -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
          local suffix = ""
          if title ~= nil then
            -- If title is given, transform it into valid file name.
            suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
          else
            -- If title is nil, just add 4 random uppercase letters to the suffix.
            for _ = 1, 4 do
              suffix = suffix .. string.char(math.random(65, 90))
            end
          end
          return tostring(os.time()) .. "-" .. suffix
        end,
        templates = {
          date_format = "%Y-%m-%d-%a",
          time_format = "%H:%M",
        },
        note_frontmatter_func = function(note)
          local out = { id = note.id, aliases = note.aliases, tags = note.tags }
          -- `note.metadata` contains any manually added fields in the frontmatter.
          -- So here we just make sure those fields are kept in the frontmatter.
          if note.metadata ~= nil and require("obsidian").util.table_length(note.metadata) > 0 then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end
          return out
        end,
        use_advanced_uri = false,
      }
      if "stefan" == vim.env.USER then
        options.dir = vim.env.HOME .. "/Dokumente/obsidian/my-vault"
        options.templates.subdir = "my-templates-folder"
      else
        options.dir = vim.env.HOME .. "/Dokumente/obsidian-vault/Makroarchitektur"
        options.templates.subdir = "Templates"
      end
      return options
    end,
    config = function(_, opts)
      require("obsidian").setup(opts)
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "markdown", "markdown_inline" },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "markdown" },
        },
      })
    end,
  },
}
