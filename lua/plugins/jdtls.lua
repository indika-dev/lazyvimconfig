local jdtls_utils = require("util.jdtlsUtils")

return {
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    opts = function()
      local success, mason_registry = pcall(require, "mason-registry")
      if success then
        mason_registry.refresh()
      end
      local initial_runtimes = function()
        return {
          {
            name = "JavaSE-17",
            path = vim.env.HOME .. "/.local/lib/jvm-17/",
            default = vim.env.USER ~= "stefan",
          },
          {
            name = "JavaSE-21",
            path = vim.env.HOME .. "/.local/lib/jvm-21/",
            default = vim.env.USER == "stefan",
          },
        }
      end
      local initial_format_settings = function()
        return {
          profile = "GoogleStyle",
          url = vim.env.HOME .. "/.local/lib/eclipse-java-google-style.xml",
        }
      end
      local bundles = function()
        local result = {}
        local sb_success, spring_boot = pcall(require, "spring_boot")
        if sb_success then
          jdtls_utils.addAll(result, spring_boot.java_extensions())
        end
        jdtls_utils.addAll(result, jdtls_utils.get_from_mason_registry("vscode-java-decompiler", "bundles/*.jar"))
        jdtls_utils.addAll(result, jdtls_utils.get_from_mason_registry("java-test", "*.jar"))
        return result
      end
      local standard_settings = function()
        return {
          java = {
            format = {
              comments = { enabled = true },
              enabled = true,
              onType = { enabled = true },
            },
          },
        }
      end
      local jdtls_settings = function()
        local settings = standard_settings()
        local status_nlsp, nlsp = pcall(require, "nlspsettings")
        if status_nlsp then
          settings = nlsp.get_settings(vim.fn.stdpath("config") .. "/nlsp-settings", "jdtls")
          if next(settings) == nil then
            vim.notify("No settings found for jdtls in nlsp-settings", vim.log.levels.WARN)
            settings = standard_settings()
          end
        end
        if next(settings.java) == nil then
          settings.java = {}
        end
        if next(settings.java.jdt) == nil then
          settings.java.jdt = {}
        end
        if next(settings.java.jdt.ls) == nil then
          settings.java.jdt.ls = {}
        end
        if settings.java.jdt.ls.vmargs == nil or settings.java.jdt.ls.vmargs == "" then
          settings.java.jdt.ls.vmargs =
            "-XX:+UseParallelGC -XX:+TieredCompilation -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -Dsun.zip.disableMemoryMapping=true -Xmx1G -Xms100m -Xlog:disable"
        end
        settings.java.configuration.runtimes = initial_runtimes()
        settings.java.format.settings = initial_format_settings()
        return settings
      end
      local capabilities = function()
        local status_blink, blink_cmp = pcall(require, "blink.cmp")
        local result = {
          workspace = {
            configuration = true,
          },
          textDocument = {
            completion = {
              completionItem = {
                snippetSupport = true,
              },
            },
          },
        }
        -- result = vim.tbl_deep_extend("keep", result, vim.lsp.protocol.make_client_capabilities())
        if status_blink then
          result = vim.tbl_deep_extend("keep", result, blink_cmp.get_lsp_capabilities())
        end
        return result
      end
      local extendedClientCapabilities = function()
        local status_jdtls, jdtls = pcall(require, "jdtls")
        local std_extended_capbilities = {
          resolveAdditionalTextEditsSupport = true,
          progressReportProvider = false,
        }
        if status_jdtls then
          std_extended_capbilities =
            vim.tbl_deep_extend("keep", std_extended_capbilities, jdtls.extendedClientCapabilities)
        end
        return std_extended_capbilities
      end
      local config = {
        capabilities = capabilities(),
        flags = {
          allow_incremental_sync = true,
          server_side_fuzzy_completion = true,
        },
        settings = jdtls_settings(),
        init_options = {
          bundles = bundles(),
          extendedClientCapabilities = extendedClientCapabilities(),
        },
        on_attach = function()
          local _, _ = pcall(vim.lsp.codelens.refresh)
        end,
        handlers = {
          ["$/progress"] = function() end,
        },
      }

      return {
        -- How to find the root dir for a given filename. The default comes from
        -- lspconfig which provides a function specifically for java projects.
        root_dir = function(fname)
          for _, patterns in ipairs({
            -- Single-module projects
            {
              "build.xml", -- Ant
              "settings.gradle", -- Gradle
              "settings.gradle.kts", -- Gradle
            },
            -- Multi-module projects
            { "build.gradle", "build.gradle.kts", ".mvn", ".git" },
          }) do
            local root = jdtls_utils.root_pattern(unpack(patterns))(fname)
            if root then
              return root
            end
          end
        end,

        -- How to find the project name for a given root dir.
        project_name = function(root_dir)
          return root_dir and vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t") -- vim.fs.basename(root_dir)
        end,
        jdtls_jvm_home = function()
          return vim.env.HOME .. "/.local/lib/jvm-jdtls"
        end,
        -- Where are the config and workspace dirs for a project?
        jdtls_config_dir = function(project_name)
          return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
        end,
        jdtls_workspace_dir = function(project_name)
          return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
        end,
        jdtls = config,
        cmd = { "jdtls" },
        full_cmd = function(opts)
          local fname = vim.api.nvim_buf_get_name(0)
          local root_dir = opts.root_dir(fname)
          local project_name = opts.project_name(root_dir)
          local cmd = {}
          if project_name then
            cmd = {
              opts.jdtls_jvm_home() .. "/bin/java",
              "--add-modules=ALL-SYSTEM",
              "--add-opens",
              "java.base/java.util=ALL-UNNAMED",
              "--add-opens",
              "java.base/java.lang=ALL-UNNAMED",
              "--add-opens",
              "java.base/sun.nio.fs=ALL-UNNAMED",
              "-noverify",
              "-Declipse.application=org.eclipse.jdt.ls.core.id1",
              "-Dosgi.bundles.defaultStartLevel=4",
              "-Declipse.product=org.eclipse.jdt.ls.core.product",
              "-Dosgi.checkConfiguration=true",
              "-Dosgi.sharedConfiguration.area=" .. jdtls_utils.get_from_mason_registry("jdtls", "config/*.ini"),
              "-Dosgi.sharedConfiguration.area.readOnly=true",
              "-Dosgi.configuration.cascaded=true",
              "-javaagent:" .. jdtls_utils.get_from_mason_registry("jdtls", "lombok.jar"),
              "-jar",
              jdtls_utils.get_from_mason_registry("jdtls", "plugins/org.eclipse.equinox.launcher.jar"),
              "-data",
              opts.jdtls_workspace_dir(project_name),
              "-configuration",
              opts.jdtls_config_dir(project_name),
            }
            -- merge vmargs from settings
            local tmp_cmd = {}
            for i = 1, 10 do
              tmp_cmd[#tmp_cmd + 1] = cmd[i]
            end
            for value in opts.jdtls.settings.java.jdt.ls.vmargs:gmatch("%S+") do
              tmp_cmd[#tmp_cmd + 1] = value
            end
            for i = 11, #cmd do
              tmp_cmd[#tmp_cmd + 1] = cmd[i]
            end
            cmd = tmp_cmd
          end
          return cmd
        end,

        -- These depend on nvim-dap, but can additionally be disabled by setting false here.
        dap = { hotcodereplace = "auto", config_overrides = {} },
        test = { config_overrides = {} },
      }
    end,
  },
}
