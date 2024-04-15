return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",
    },
    cmd = { "ObsidianOpen", "ObsidianNew", "ObsidianSearch", "ObsidianQuickSwitch", "ObsidianToday" },
    keys = {
      { "<leader>oO", "<cmd>ObsidianOpen<CR>", desc = "Open Obsidian" },
      { "<leader>on", "<cmd>ObsidianNew<CR>", desc = "New note" },
      { "<leader>os", "<cmd>ObsidianSearch<CR>", desc = "Search" },
      { "<leader>oo", "<cmd>ObsidianQuickSwitch<CR>", desc = "Find note" },
      { "<leader>ot", "<cmd>ObsidianToday<CR>", desc = "Open Today" },
      { "<leader>oT", "<cmd>ObsidianTemplate<CR>", desc = "Insert from template" },
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
        mappings = {
          ["gf"] = {
            action = function()
              if require("obsidian").util.cursor_on_markdown_link() then
                return "<cmd>ObsidianFollowLink<CR>"
              else
                return "gf"
              end
            end,
            opts = { noremap = false, expr = true, buffer = true },
          },
          -- Toggle check-boxes.
          ["<CR>"] = {
            action = function()
              local line = vim.api.nvim_get_current_line()
              for _, char in ipairs({ " ", "x", "~", ">", "-" }) do
                if string.match(line, "^%s*- %[" .. char .. "%].*") then
                  return "<cmd>lua require('obsidian').util.toggle_checkbox()<CR>"
                end
              end
              return "<CR>"
            end,
            opts = { noremap = false, expr = true, buffer = true },
          },
        },
        ui = {
          checkboxes = {
            -- NOTE: the 'char' value has to be a single character
            [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
            ["x"] = { char = "", hl_group = "ObsidianDone" },
            [">"] = { char = "", hl_group = "ObsidianRightArrow" },
            ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },

            -- You can also add more custom ones...
          },
          external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
        },
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
