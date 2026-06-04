return {
  {
    "carlos-algms/agentic.nvim",

    --- @type agentic.PartialUserConfig
    opts = {
      -- Any ACP-compatible provider works. Built-in: "claude-agent-acp" | "gemini-acp" | "codex-acp" | "opencode-acp" | "cursor-acp" | "copilot-acp" | "auggie-acp" | "mistral-vibe-acp" | "cline-acp" | "goose-acp" | "kiro-acp" | "pi-acp"
      provider = "pi-acp", -- setting the name here is all you need to get started
    },

    -- these are just suggested keymaps; customize as desired
    keys = {
      {
        "<C-\\>",
        function()
          require("agentic").toggle()
        end,
        mode = { "n", "v", "i" },
        desc = "Toggle Agentic Chat",
      },
      {
        "<C-'>",
        function()
          require("agentic").add_selection_or_file_to_context()
        end,
        mode = { "n", "v" },
        desc = "Add file or selection to Agentic to Context",
      },
      {
        "<C-,>",
        function()
          require("agentic").new_session()
        end,
        mode = { "n", "v", "i" },
        desc = "New Agentic Session",
      },
      {
        "<A-i>r", -- ai Restore
        function()
          require("agentic").restore_session()
        end,
        desc = "Agentic Restore session",
        silent = true,
        mode = { "n", "v", "i" },
      },
      {
        "<leader>ad", -- ai Diagnostics
        function()
          require("agentic").add_current_line_diagnostics()
        end,
        desc = "Add current line diagnostic to Agentic",
        mode = { "n" },
      },
      {
        "<leader>aD", -- ai all Diagnostics
        function()
          require("agentic").add_buffer_diagnostics()
        end,
        desc = "Add all buffer diagnostics to Agentic",
        mode = { "n" },
      },
    },
  },
}

-- return {
--   {
--     "aldoborrero/pi-agent.nvim",
--     opts = {
--       -- -- Terminal window
--       -- window = {
--       --   split_ratio = 0.3,
--       --   position = "botright", -- "botright", "topleft", "vertical", "float"
--       --   enter_insert = true,
--       --   hide_numbers = true,
--       --   hide_signcolumn = true,
--       --   -- Floating window (when position = "float")
--       --   float = {
--       --     width = "80%",
--       --     height = "80%",
--       --     row = "center",
--       --     col = "center",
--       --     relative = "editor",
--       --     border = "rounded",
--       --   },
--       -- },
--       -- -- File refresh
--       -- refresh = {
--       --   enable = true,
--       --   updatetime = 100,
--       --   timer_interval = 1000,
--       --   show_notifications = true,
--       -- },
--       -- -- Git
--       -- git = {
--       --   use_git_root = true,
--       -- },
--       -- Command
--       command = "/var/home/stefan/.local/pi/pi",
--       --   command_variants = {
--       --     continue = "--continue",
--       --     resume = "--resume",
--       --     verbose = "--verbose",
--       --   },
--       --   -- Keymaps
--       --   keymaps = {
--       --     toggle = {
--       --       normal = "<C-,>",
--       --       terminal = "<C-,>",
--       --       variants = {
--       --         continue = "<leader>pC",
--       --         verbose = "<leader>pV",
--       --       },
--       --     },
--       --     window_navigation = true,
--       --     scrolling = true,
--       --   },
--     },
--   },
-- }
--
--
--
-- if true then
--   return {
--     {
--       "aliou/nvim-pi",
--       keys = {
--         {
--           "<leader>po",
--           function()
--             require("pi-nvim").open()
--           end,
--           mode = { "n" },
--           desc = "Open Pi",
--         },
--         {
--           "<leader>pc",
--           function()
--             require("pi-nvim").close()
--           end,
--           mode = { "n" },
--           desc = "Close Pi",
--         },
--         {
--           "<leader>pp",
--           function()
--             require("pi-nvim").toggle()
--           end,
--           mode = { "n" },
--           desc = "Toggle Pi",
--         },
--       },
--       opts = {
--         auto_start = true,
--         data_dir = nil,
--
--         -- Pi CLI flags
--         models = { "gemma-4-31b-it", "gemma-4-26b-a4b-it" },
--         provider = "google",
--         model = "gemma-4-31b-it",
--         thinking = "high",
--         load_extension = "auto", -- "auto": skip --extension if installed globally; true: always pass; false: never pass
--         extra_args = nil,
--
--         -- Window configuration
--         win = {
--           layout = "auto",
--           width_threshold = 150,
--           width = 80,
--           height = 20,
--           focus_source_on_stopinsert = true, -- switch to source window on exiting terminal mode
--           keys = {
--             close = { "<C-q>", mode = "n", desc = "Close Pi" },
--             stopinsert = { "<C-q>", mode = "t", desc = "Exit terminal mode" },
--             suspend = { "<C-z>", mode = "t", desc = "Suspend Neovim" },
--             picker = { "<C-Space>", mode = "t", desc = "Open context picker" },
--           },
--         },
--       },
--     },
--   }
-- else
--   return {
--     {
--       "pablopunk/pi.nvim",
--       opts = {
--         binary = "~/.local/pi/pi", -- or { "env", "FOO=1", "pi-wrapper" }
--         provider = "openrouter",
--         model = "google/gemma-4-31b-it:free", -- openrouter/free",
--         thinking = "off", -- be careful, thinking is time-consuming, it's not a great experience if you want simplicity
--         system_prompt = "You are a helpful assistant.",
--         append_system_prompt = "Always respond concisely.",
--         context = {
--           max_bytes = 24000,
--           ask = {
--             surrounding_lines = 80,
--           },
--           selection = {
--             surrounding_lines = 40,
--           },
--           diagnostics = {
--             enabled = false,
--           },
--         },
--         skills = true,
--         extensions = true,
--       },
--     },
--   }
-- end
