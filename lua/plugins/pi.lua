if false then
  return {
    {
      "carderne/pi-nvim",
      opts = {
        socket_path = nil, -- auto-discover
        set_default_keymaps = true,
      },
    },
  }
else
  return {
    {
      "pablopunk/pi.nvim",
      keys = {
        -- Ask pi with the current buffer as context
        { "<leader>ai", ":PiAsk<CR>", desc = "Ask pi", mode = "n" },

        -- Ask pi with visual selection as context
        { mode = "v", "<leader>ai", ":PiAskSelection<CR>", desc = "Ask pi (selection)" },
      },
      opts = {
        binary = "~/.nvm/versions/node/v24.15.0/bin/pi", -- or { "env", "FOO=1", "pi-wrapper" }
        provider = "ollama",
        model = "gemma4:e2b", -- openrouter/free
        thinking = "off", -- be careful, thinking is time-consuming, it's not a great experience if you want simplicity
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
  }
end
