local function get_lsp_fallback(bufnr)
  local always_use_lsp = not vim.bo[bufnr].filetype:match("^kotlin")
  return always_use_lsp and "always" or true
end

local function get_debug_adapter()
  local mason_registry = require("mason-registry")
  local debug_adapter = mason_registry.get_package("kotlin-debug-adapter")
  return debug_adapter:get_install_path() .. "/adapter/bin/kotlin-debug-adapter"
end

return {
  recommended = function()
    return LazyVim.extras.wants({
      ft = "kotlin",
      root = {
        "settings.gradle", -- Gradle (multi-project)
        "settings.gradle.kts", -- Gradle (multi-project)
        "build.xml", -- Ant
        "pom.xml", -- Maven
        "build.gradle", -- Gradle
        "build.gradle.kts", -- Gradle
      },
    })
  end,
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  },
  {
    "AlexandrosAlexiou/kotlin.nvim",
    ft = "kotlin",
    -- dev = true,
    -- dir = "/home/stefan/Projekte/kotlin.nvim",
    opts = {
      root_markers = {
        ".git",
      },

      -- Optional: Java Runtime to run the kotlin-lsp server itself
      -- LEGACY ONLY — ignored on v262.4739.0+ (bin/intellij-server manages
      -- its own JBR; a warning is shown if this is set on a new install).
      -- Only useful with older builds that ship kotlin-lsp.sh / kotlin-lsp.cmd.
      --
      -- When set, the plugin parses JVM args from the bundled launcher script
      -- and invokes your custom JRE with the correct flags
      -- Must point to JAVA_HOME (directory containing bin/java)
      -- Examples:
      --   macOS:   "/Library/Java/JavaVirtualMachines/jdk-25.jdk/Contents/Home"
      --   Linux:   "/usr/lib/jvm/java-25-openjdk"
      --   Windows: "C:\\Program Files\\Java\\jdk-25"
      --   Env var: os.getenv("JAVA_HOME") or os.getenv("JDK25")
      jre_path = nil,

      -- Optional: JDK for symbol resolution (analyzing your Kotlin code)
      -- This is the JDK that your project code will be analyzed against
      -- Different from jre_path (which runs the server)
      -- Required for: Analyzing JDK APIs, standard library symbols, platform types
      --
      -- Usually should match your project's target JDK version
      -- Examples:
      --   macOS:   "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home"
      --   Linux:   "/usr/lib/jvm/java-17-openjdk"
      --   Windows: "C:\\Program Files\\Java\\jdk-17"
      --   SDKMAN:  os.getenv("HOME") .. "/.sdkman/candidates/java/17.0.8-tem"
      jdk_for_symbol_resolution = nil, -- Auto-detect from project

      -- Optional: Specify additional JVM arguments for the kotlin-lsp server
      jvm_args = {
        "-Xmx4g", -- Increase max heap (useful for large projects)
      },

      -- Optional: Configure inlay hints (requires kotlin-lsp v261+)
      -- All settings default to true, set to false to disable specific hints
      inlay_hints = {
        enabled = true, -- Enable inlay hints (auto-enable on LSP attach)
        parameters = true, -- Show parameter names
        parameters_compiled = true, -- Show compiled parameter names
        parameters_excluded = false, -- Show excluded parameter names
        types_property = true, -- Show property types
        types_variable = true, -- Show local variable types
        function_return = true, -- Show function return types
        function_parameter = true, -- Show function parameter types
        lambda_return = true, -- Show lambda return types
        lambda_receivers_parameters = true, -- Show lambda receivers/parameters
        value_ranges = true, -- Show value ranges
        kotlin_time = true, -- Show kotlin.time warnings
      },

      -- Optional: LSP-driven folding (requires kotlin-lsp v262.4739.0+)
      -- Enabled by default; set folding.enabled = false to opt out.
      folding = { enabled = true },

      -- Optional: build-importer preference (requires kotlin-lsp v262.4739.0+)
      -- Mirrors the VSCode `intellij.buildTool` setting:
      --   nil = let the server pick (default)
      --   "gradle" or "maven" = force a specific importer
      --   ""    = none (single-file / no build system)
      -- build_tool = "gradle",

      -- Optional: file templates for new Kotlin files (requires kotlin-lsp v262.4739.0+)
      -- When you create a new .kt file the plugin asks the server to interpolate the
      -- chosen template. Pass a table of name → Velocity template to override the
      -- defaults (Class, File, Interface, Data Class, Enum, Annotation, Object).
      -- Set { enabled = false } on the table to disable the prompt entirely.
      -- file_templates = {
      --     enabled = true,
      --     -- Class = "package ${PACKAGE_NAME}\n\nclass ${NAME} {\n\t|\n}",
      -- },
    },
  },
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")

      if not dap.adapters.kotlin then
        dap.adapters.kotlin = {
          type = "executable",
          command = get_debug_adapter(),
          options = { auto_continue_if_many_stopped = false },
        }
      end
    end,
  },
  -- Add packages(linting, debug adapter)
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "detekt", "ktfmt" } },
  },
  -- Add syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "kotlin" } },
  },
  -- Add language server
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        kotlin_lsp = {},
      },
    },
  },
  -- Add linting
  {
    "mfussenegger/nvim-lint",
    optional = true,
    dependencies = "mason-org/mason.nvim",
    opts = {
      linters_by_ft = { kotlin = { "detekt" } },
    },
  },
  -- Add formatting
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = { kotlin = { "ktfmt" } },
      formatters = {
        ktfmt = {
          prepend_args = {
            -- "--enable-editorconfig",
            "--kotlinlang-style",
          },
        },
      },
    },
    -- -- This option will handle creating the autocmd and saving for you
    -- format_after_save = function(bufnr)
    --   return {
    --     lsp_fallback = get_lsp_fallback(bufnr),
    --   }
    -- end,
  },
  -- Add formatting and linting
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.formatting.ktfmt,
        nls.builtins.diagnostics.detekt,
      })
    end,
  },
  -- Add debugger
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = "mason-org/mason.nvim",
    opts = function()
      local dap = require("dap")
      if not dap.adapters.kotlin then
        dap.adapters.kotlin = {
          type = "executable",
          command = "kotlin-debug-adapter",
          options = { auto_continue_if_many_stopped = false },
        }
      end

      dap.configurations.kotlin = {
        {
          type = "kotlin",
          request = "launch",
          name = "This file",
          -- may differ, when in doubt, whatever your project structure may be,
          -- it has to correspond to the class file located at `build/classes/`
          -- and of course you have to build before you debug
          mainClass = function()
            local root = vim.fs.find("src", { path = vim.uv.cwd(), upward = true, stop = vim.env.HOME })[1] or ""
            local fname = vim.api.nvim_buf_get_name(0)
            -- src/main/kotlin/websearch/Main.kt -> websearch.MainKt
            return fname:gsub(root, ""):gsub("main/kotlin/", ""):gsub(".kt", "Kt"):gsub("/", "."):sub(2, -1)
          end,
          projectRoot = "${workspaceFolder}",
          jsonLogFile = "",
          enableJsonLogging = false,
        },
        {
          -- Use this for unit tests
          -- First, run
          -- ./gradlew --info cleanTest test --debug-jvm
          -- then attach the debugger to it
          type = "kotlin",
          request = "attach",
          name = "Attach to debugging session",
          port = 5005,
          args = {},
          projectRoot = vim.fn.getcwd,
          hostName = "localhost",
          timeout = 2000,
        },
      }
    end,
  },
}
