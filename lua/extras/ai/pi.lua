return {
  {
    "carlos-algms/agentic.nvim",
    enabled = false,
    --- @type agentic.PartialUserConfig
    opts = {
      -- Any ACP-compatible provider works. Built-in: "claude-agent-acp" | "gemini-acp" | "codex-acp" | "opencode-acp" | "cursor-acp" | "copilot-acp" | "auggie-acp" | "mistral-vibe-acp" | "cline-acp" | "goose-acp" | "kiro-acp" | "pi-acp"
      provider = "pi-acp", -- setting the name here is all you need to get started
      ["pi-acp"] = {
        command = vim.g.pi.cmd,
        initial_model = vim.g.pi.standard_llm.model,
        default_thought_level = "medium",
      },
    },
    keys = {
      { "<leader>p", "", desc = "+acp", mode = { "n", "v" } },
      {
        "<leader>pt",
        function()
          require("agentic").toggle()
        end,
        mode = { "n", "v", "i" },
        desc = "Toggle Agentic Chat",
      },
      {
        "<leader>pa",
        function()
          require("agentic").add_selection_or_file_to_context()
        end,
        mode = { "n", "v" },
        desc = "Add file or selection to Agentic to Context",
      },
      {
        "<leader>ps",
        function()
          require("agentic").new_session()
        end,
        mode = { "n", "v", "i" },
        desc = "New Agentic Session",
      },
      {
        "<leader>pr", -- ai Restore
        function()
          require("agentic").restore_session()
        end,
        desc = "Agentic Restore session",
        silent = true,
        mode = { "n", "v", "i" },
      },
      {
        "<leader>pd", -- ai Diagnostics
        function()
          require("agentic").add_current_line_diagnostics()
        end,
        desc = "Add current line diagnostic to Agentic",
        mode = { "n" },
      },
      {
        "<leader>pD", -- ai all Diagnostics
        function()
          require("agentic").add_buffer_diagnostics()
        end,
        desc = "Add all buffer diagnostics to Agentic",
        mode = { "n" },
      },
    },
  },
  {
    "carderne/pi-nvim",
    -- mainly send data to a pi session
    keys = {
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      { "<leader>ao", mode = { "n", "v" }, ":Pi<CR>", desc = "Open the 'Send to pi' dialog" },
      { "<leader>at", mode = { "n" }, ":PiSend<CR>", desc = "Type a prompt and send to pi" },
      { "<leader>af", mode = { "n" }, ":PiSendFile<CR>", desc = "Send current file path + prompt" },
      { "<leader>av", mode = { "v" }, ":PiSendSelection<CR>", desc = "Send visual selection + prompt" },
      { "<leader>ab", mode = { "n" }, ":PiSendBuffer<CR>", desc = "Send entire buffer + prompt" },
      { "<leader>ar", mode = { "n" }, ":PiPing<CR>", desc = "Check if pi is reachable" },
      { "<leader>as", mode = { "n" }, ":PiSessions<CR>", desc = "List/switch between running pi sessions" },
    },
    opts = {
      socket_path = nil, -- auto-discover
      set_default_keymaps = false,
    },
  },
  {
    "pablopunk/pi.nvim",
    keys = {
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      -- Ask pi with the current buffer as context
      { "<leader>aa", ":PiAsk<CR>", desc = "Ask pi", mode = "n" },

      -- Ask pi with visual selection as context
      { mode = "v", "<leader>ai", ":PiAskSelection<CR>", desc = "Ask pi (selection)" },
    },
    opts = {
      binary = vim.g.pi.cmd, -- or { "env", "FOO=1", "pi-wrapper" }
      provider = vim.g.pi.standard_llm.provider,
      model = vim.g.pi.standard_llm.model, -- openrouter/free
      thinking = "medium", -- be careful, thinking is time-consuming, it's not a great experience if you want simplicity
      hideThinkingBlock = true,
      system_prompt = "You are a helpful assistant.",
      append_system_prompt = "Always respond concisely.",
      context = {
        max_bytes = 24000,
        ask = {
          surrounding_lines = 80,
        },
        selection = {
          surrounding_lines = 40,
        },
        diagnostics = {
          enabled = false,
        },
      },
      skills = true,
      extensions = true,
    },
  },
  {
    -- The GitHub repository for the codecompanion.nvim plugin.
    "olimorris/codecompanion.nvim",
    keys = {
      { "<leader>p", "", desc = "+acp", mode = { "n" } },
      { "<leader>pp", mode = { "n" }, ":CodeCompanion<CR>", desc = "Enter a Prompt" },
      { "<leader>pe", mode = { "n" }, ":CodeCompanionActions<CR>", desc = "Entry Point for Configuration Options" },
      { "<leader>po", mode = { "n" }, ":CodeCompanionChat<CR>", desc = "Open Chat window" },
      { "<leader>pi", mode = { "n" }, ":CodeCompanionCLI<CR>", desc = "Interact With Agents via CLI" },
      { "<leader>pd", mode = { "n" }, ":CodeCompanionCmd<CR>", desc = "Send a slash command" },
    },
    -- Specifies other plugins that codecompanion.nvim needs to function correctly.
    -- dependencies = {
    --  -- plenary.nvim provides common utility functions that are used by many Neovim plugins.
    --   "nvim-lua/plenary.nvim",
    -- },
    -- The 'opts' table contains all the user-specific settings for the plugin.
    opts = {
      -- This 'strategies' table sets the DEFAULT AI PROVIDER and MODEL
      -- for different categories of actions within the plugin.
      strategies = {
        -- Configures the default model for running custom prompts.
        cmd = vim.g.pi.standard_llm.model,
        -- Configures the model for the interactive chat window (:CompanionChat).
        chat = vim.g.pi.standard_llm.model,
        -- Configures the model for any action that modifies code directly in your buffer
        -- using the 'inline' strategy.
        inline = vim.g.pi.standard_llm.model,
      },
      -- The 'prompt_library' is where you define your own reusable, custom AI commands.
      prompt_library = {
        -- The name of the custom prompt. Run with :CodeCompanionActions
        ["Boilerplate HTML"] = {
          strategy = "inline",
          description = "Generate some boilerplate HTML",
          prompts = {
            {
              role = "system",
              content = "You are an expert HTML programmer",
            },
            {
              role = "user",
              content = "<user_prompt>Please generate some HTML boilerplate for me. Return the code only and no markdown codeblocks</user_prompt>",
            },
          },
        },
      },
    },
  },
}
