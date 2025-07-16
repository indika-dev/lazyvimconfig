return {
  {
    "ravitemer/mcphub.nvim",
    enabled = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
    config = function()
      require("mcphub").setup()
    end,
  },
  {
    "yetone/avante.nvim",
    enabled = false,
    build = "make BUILD_FROM_SOURCE=true",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@type avante.Config
    opts = {
      -- add any opts here
      -- for example
      provider = "gemini", -- default provider
      providers = {
        ollama = {
          endpoint = "http://localhost:11434",
          model = "cogito:14b",
          -- disable_tools = true,
          -- timeout = 30000, -- Timeout in milliseconds
          -- extra_request_body = {
          --   temperature = 0.75,
          --   max_tokens = 20480,
          -- },
        },
        gemini = {
          model = "gemini-2.0-flash",
          api_key = "AVANTE_GEMINI_API_KEY", -- Environment variable name for the LLM API key
          timeout = 30000, -- Timeout in milliseconds
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 20480,
          },
        },
      },
      rag_service = { -- RAG Service configuration
        enabled = false, -- Enables the RAG service
        host_mount = os.getenv("HOME"), -- Host mount path for the rag service (Docker will mount this path)
        runner = "podman", -- Runner for the RAG service (can use docker or nix)
        llm = { -- Language Model (LLM) configuration for RAG service
          provider = "ollama", -- LLM provider
          endpoint = "http://localhost:11434", -- LLM API endpoint
          -- api_key = "OPENAI_API_KEY", -- Environment variable name for the LLM API key
          model = "cogito:14b", -- LLM model name
          extra = nil, -- Additional configuration options for LLM
        },
        embed = { -- Embedding model configuration for RAG service
          provider = "ollama", -- Embedding provider
          endpoint = "http://localhost:11434", -- Embedding API endpoint
          -- api_key = "OPENAI_API_KEY", -- Environment variable name for the embedding API key
          model = "cogito:14b", -- Embedding model name
          extra = nil, -- Additional configuration options for the embedding model
        },
        docker_extra_args = "", -- Extra arguments to pass to the docker command
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- 'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      -- 'echasnovski/mini.pick', -- for file_selector provider mini.pick
      -- 'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
      -- 'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
      -- 'ibhagwan/fzf-lua', -- for file_selector provider fzf
      -- 'stevearc/dressing.nvim', -- for input provider dressing
      -- 'folke/snacks.nvim', -- for input provider snacks
      -- 'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
      -- 'zbirenbaum/copilot.lua', -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
    },
  },
}
