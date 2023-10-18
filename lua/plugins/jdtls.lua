return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function()
      local bundles = function()
        local jar_patterns = {
          vim.fn.glob(
            require("mason-registry").get_package("vscode-java-decompiler"):get_install_path() .. "/server/dg.jdt*.jar"
          ),
          vim.fn.glob(
            require("mason-registry").get_package("java-debug-adapter"):get_install_path()
              .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"
          ),
          vim.fn.glob(
            require("mason-registry").get_package("java-test"):get_install_path()
              .. "/extension/server/com.microsoft.java.test.runner-jar-with-dependencies.jar"
          ),
          vim.fn.glob(
            require("mason-registry").get_package("java-test"):get_install_path()
              .. "/extension/server/com.microsoft.java.test.plugin-*.jar"
          ),
        }
        local bundles = {}
        for _, jar_pattern in ipairs(jar_patterns) do
          for _, bundle in ipairs(vim.split(jar_pattern, "\n", {})) do
            if bundle ~= {} then
              table.insert(bundles, bundle)
            end
          end
        end
        return bundles
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
                runtimes = {
                  {
                    name = "JavaSE-17",
                    path = vim.env.HOME .. "/.local/lib/jvm-17/",
                    default = true,
                  },
                },
              },
              format = {
                settings = {
                  profile = "GoogleStyle",
                },
              },
            },
          }
        end
        if settings.java.configuration.runtimes == nil then
          settings.java.configuration.runtimes = {
            {
              name = "JavaSE-17",
              path = vim.env.HOME .. "/.local/lib/jvm-17/",
              default = true,
            },
          }
        end
        if settings.java.format.settings.profile == "GoogleStyle" then
          settings.java.format.settings.url = vim.fn.stdpath("config") .. "/.java-google-formatter.xml"
        else
          settings.java.format.settings.url = vim.fn.stdpath("config") .. "/.eclipse-formatter.xml"
        end
        return settings
      end
      local extendedClientCapabilities = function()
        local status_jdtls, jdtls = pcall(require, "jdtls")
        if not status_jdtls then
          return {
            resolveAdditionalTextEditsSupport = true,
            classFileContentsSupport = false,
          }
        end
        return vim.tbl_deep_extend("keep", {
          resolveAdditionalTextEditsSupport = true,
          classFileContentsSupport = false,
        }, jdtls.extendedClientCapabilities)
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
        -- handlers = {
        --   ["language/status"] = function(_, result)
        --     -- Print or whatever.
        --   end,
        --   ["$/progress"] = function(_, result, ctx)
        --     -- disable progress updates.
        --   end,
        -- },
        on_attach = function()
          local _, _ = pcall(vim.lsp.codelens.refresh)
        end,
      }

      return {
        -- How to find the root dir for a given filename. The default comes from
        -- lspconfig which provides a function specifically for java projects.
        root_dir = require("lspconfig.server_configurations.jdtls").default_config.root_dir,

        -- How to find the project name for a given root dir.
        project_name = function(root_dir)
          return root_dir and vim.fs.basename(root_dir)
        end,
        config_os = function()
          if vim.fn.has("mac") == 1 then
            return "mac"
          elseif vim.fn.has("unix") == 1 then
            return "linux"
          elseif vim.fn.has("win32") == 1 then
            return "win"
          else
            vim.notify("Unsupported system", vim.log.levels.ERROR)
            return
          end
        end,
        launcher_path = function(jdtls_install_path)
          return vim.fn.glob(jdtls_install_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        end,
        java_home = function()
          return vim.env.HOME .. "/.local/lib/jvm-17"
        end,
        -- Where are the config and workspace dirs for a project?
        jdtls_config_dir = function(project_name)
          return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
        end,
        jdtls_workspace_dir = function(project_name)
          return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
        end,
        jdtls_install_path = function()
          return require("mason-registry").get_package("jdtls"):get_install_path()
        end,
        jdtls = config,
        cmd = { "jdtls" },
        -- full_cmd = function(opts)
        --   local fname = vim.api.nvim_buf_get_name(0)
        --   local root_dir = opts.root_dir(fname)
        --   local project_name = opts.project_name(root_dir)
        --   local cmd = vim.deepcopy(opts.cmd)
        --   if project_name then
        --     vim.list_extend(cmd, {
        --       "-configuration",
        --       opts.jdtls_config_dir(project_name),
        --       "-data",
        --       opts.jdtls_workspace_dir(project_name),
        --       "--jvm-arg=-javaagent:" .. opts.jdtls_install_path() .. "/lombok.jar",
        --     })
        --   end
        --   return cmd
        -- end,
        --
        -- How to run jdtls. This can be overridden to a full java command-line
        -- if the Python wrapper script doesn't suffice.
        -- cmd = {
        --   vim.env.HOME .. "/.local/lib/jvm-17" .. "/bin/java",
        -- },
        full_cmd = function(opts)
          local fname = vim.api.nvim_buf_get_name(0)
          local root_dir = opts.root_dir(fname)
          local project_name = opts.project_name(root_dir)
          local cmd = {}
          local jdtls_install_path = opts.jdtls_install_path()
          if project_name then
            cmd = {
              opts.java_home() .. "/bin/java",
              "-Declipse.application=org.eclipse.jdt.ls.core.id1",
              "-Dosgi.bundles.defaultStartLevel=4",
              "-Declipse.product=org.eclipse.jdt.ls.core.product",
              "-Dosgi.checkConfiguration=true",
              "-Dosgi.sharedConfiguration.area=" .. jdtls_install_path .. "/config_" .. opts.config_os(),
              "-Dosgi.sharedConfiguration.area.readOnly=true",
              "-Dosgi.configuration.cascaded=true",
              "-XX:+UseParallelGC",
              "-XX:GCTimeRatio=4",
              "-XX:AdaptiveSizePolicyWeight=90",
              "-Dsun.zip.disableMemoryMapping=true",
              "-Xmx1G",
              "-Xms100m",
              "-javaagent:" .. jdtls_install_path .. "/lombok.jar",
              "--add-modules=ALL-SYSTEM",
              "--add-opens",
              "java.base/java.util=ALL-UNNAMED",
              "--add-opens",
              "java.base/java.lang=ALL-UNNAMED",
              "-jar",
              opts.launcher_path(jdtls_install_path),
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
        test = true,
      }
    end,
  },
}
