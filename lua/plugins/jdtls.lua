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
      local get_shared_links_from_mason_receipt = function(package_name, key_prefix)
        if success == false then
          success, mason_registry = pcall(require, "mason-registry")
        end
        local result = {}
        if success then
          local has_package, mason_package = pcall(mason_registry.get_package, package_name)
          if has_package then
            if mason_package:is_installed() then
              local install_path = mason_package:get_install_path()
              mason_package:get_receipt():if_present(function(recipe)
                for key, value in pairs(recipe.links.share) do
                  if key:sub(1, #key_prefix) == key_prefix then
                    table.insert(result, install_path .. "/" .. value)
                  end
                end
              end)
            end
          end
        end
        return result
      end
      local addAll = function(target, insertion)
        for _, value in pairs(insertion) do
          table.insert(target, value)
        end
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
        local sb_success, spring_boot = pcall(require, "spring_boot")
        if sb_success then
          addAll(result, spring_boot.java_extensions())
        end
        addAll(result, get_shared_links_from_mason_receipt("vscode-java-decompiler", "vscode-java-decompiler/bundles/"))
        addAll(result, get_shared_links_from_mason_receipt("java-debug-adapter", "java-debug-adapter/"))
        addAll(result, get_shared_links_from_mason_receipt("java-test", "java-test/"))
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
        handlers = {
          ["$/progress"] = function(_, result, ctx)
            -- disable progress updates.
          end,
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
          return vim.env.HOME .. "/.local/lib/semeru-jdtls"
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
              "-Dosgi.sharedConfiguration.area=" .. get_shared_links_from_mason_receipt("jdtls", "jdtls/config/")[1],
              "-Dosgi.sharedConfiguration.area.readOnly=true",
              "-Dosgi.configuration.cascaded=true",
              "-Dsun.zip.disableMemoryMapping=true",
              "-XX:+UseParallelGC",
              "-XX:GCTimeRatio=4",
              "-XX:AdaptiveSizePolicyWeight=90",
              "-Xmx1G",
              "-Xms100m",
              "-Xlog:disable",
              "-javaagent:" .. get_shared_links_from_mason_receipt("jdtls", "jdtls/lombok.jar")[1],
              "-jar",
              get_shared_links_from_mason_receipt("jdtls", "jdtls/plugins/org.eclipse.equinox.launcher.jar")[1],
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
  },
}
