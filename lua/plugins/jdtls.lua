local jdtls_utils = require("util.jdtlsUtils")

return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "<never>",
    opts = function()
      local add_jars_from_package = function(package_name, key_prefix, list)
        local success, mason_registry = pcall(require, "mason-registry")
        if success then
          local mason_package = mason_registry.get_package(package_name)
          if mason_package:is_installed() then
            local install_path = mason_package:get_install_path()
            mason_package:get_receipt():if_present(function(recipe)
              for key, value in pairs(recipe.links.share) do
                if key:sub(1, #key_prefix) == key_prefix then
                  table.insert(list, install_path .. "/" .. value)
                end
              end
            end)
          end
        end
      end
      local get_jar_or_dir_from_package = function(package_name, key_name)
        local success, mason_registry = pcall(require, "mason-registry")
        local result = nil
        if success then
          local mason_package = mason_registry.get_package(package_name)
          if mason_package:is_installed() then
            local install_path = mason_package:get_install_path()
            mason_package:get_receipt():if_present(function(recipe)
              for key, value in pairs(recipe.links.share) do
                if key:sub(1, #key_name) == key_name then
                  result = install_path .. "/" .. value
                  break
                end
              end
            end)
          end
        end
        return result
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
          url = vim.env.HOME .. "/.local/lib/java-google-formatter.xml",
        }
      end
      local bundles = function()
        local result = {}
        add_jars_from_package("vscode-spring-boot-tools", "vscode-spring-boot-tools/jdtls/", result)
        if #result == 0 then
          local success, spring_boot = pcall(require, "spring_boot")
          if success then
            for _, v in pairs(spring_boot.java_extensions()) do
              table.insert(result, v)
            end
          end
        end
        add_jars_from_package("vscode-java-decompiler", "vscode-java-decompiler/bundles/", result)
        add_jars_from_package("java-debug-adapter", "java-debug-adapter/", result)
        add_jars_from_package("java-test", "java-test/", result)
        return result
      end
      local jdtls_settings = function()
        local settings = {}
        local status_nlsp, nlsp = pcall(require, "nlspsettings")
        if status_nlsp then
          settings = nlsp.get_settings(vim.fn.stdpath("config"), "jdtls")
        else
          settings = {
            java = {
              configuration = {
                runtimes = initial_runtimes(),
              },
              format = {
                comments = { enabled = true },
                enabled = true,
                onType = { enabled = true },
                settings = initial_format_settings(),
              },
            },
          }
        end
        if settings.java.configuration.runtimes == nil or settings.java.configuration.runtimes == {} then
          settings.java.configuration.runtimes = initial_runtimes()
        end
        if settings.java.format.settings == nil or settings.java.format.settings == {} then
          settings.java.format.settings = initial_format_settings()
        end
        return settings
      end
      local extendedClientCapabilities = function()
        local status_jdtls, jdtls = pcall(require, "jdtls")
        local std_extended_capbilities = {
          resolveAdditionalTextEditsSupport = true,
        }
        if not status_jdtls then
          return std_extended_capbilities
        end
        return vim.tbl_deep_extend("keep", std_extended_capbilities, jdtls.extendedClientCapabilities)
      end
      local config = {
        capabilities = {
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
        },
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
          return vim.env.HOME .. "/.local/lib/semeru-17"
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
              -- "-noverify",
              "-Declipse.application=org.eclipse.jdt.ls.core.id1",
              "-Dosgi.bundles.defaultStartLevel=4",
              "-Declipse.product=org.eclipse.jdt.ls.core.product",
              "-Dosgi.checkConfiguration=true",
              "-Dosgi.sharedConfiguration.area=" .. get_jar_or_dir_from_package("jdtls", "jdtls/config/"),
              "-Dosgi.sharedConfiguration.area.readOnly=true",
              "-Dosgi.configuration.cascaded=true",
              "-Dsun.zip.disableMemoryMapping=true",
              "-XX:+UseParallelGC",
              "-XX:GCTimeRatio=4",
              "-XX:AdaptiveSizePolicyWeight=90",
              "-Xmx1G",
              "-Xms100m",
              "-Xlog:disable",
              "-javaagent:" .. get_jar_or_dir_from_package("jdtls", "jdtls/lombok.jar"),
              "-jar",
              get_jar_or_dir_from_package("jdtls", "jdtls/plugins/org.eclipse.equinox.launcher.jar"),
              "-data",
              opts.jdtls_workspace_dir(project_name),
              "-configuration",
              opts.jdtls_config_dir(project_name),
            }
          end
          return cmd
        end,

        -- These depend on nvim-dap, but can additionally be disabled by setting false here.
        dap = { hotcodereplace = "auto", config_overrides = {} },
        test = { config_overrides = {} },
      }
    end,
    -- config = function(_, opts)
    --   require("lspconfig").jdtls.setup(opts)
    --   local status_sts, spring_boot = pcall(require, "spring_boot")
    --   if status_sts then
    --     spring_boot.init_lsp_commands()
    --   else
    --     vim.notify("SpringBoot Tools couldn't be started", vim.log.levels.ERROR)
    --   end
    -- end,
  },
}
