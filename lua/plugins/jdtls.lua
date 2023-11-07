local is_int = function(n)
  return (type(n) == "number") and (math.floor(n) == n)
end
local is_windows = vim.loop.os_uname().version:match("Windows")
local jdtls_join = function(...)
  sep = vim.loop.os_uname().version:match("Windows") and "\\" or "/"
  local result = table.concat(vim.tbl_flatten({ ... }), sep):gsub(sep .. "+", sep)
  return result
end
local escape_wildcards = function(path)
  return path:gsub("([%[%]%?%*])", "\\%1")
end
local function path_join(...)
  return table.concat(vim.tbl_flatten({ ... }), "/")
end
local path_exists = function(filename)
  local stat = vim.loop.fs_stat(filename)
  return stat and stat.type or false
end
local strip_archive_subpath = function(path)
  -- Matches regex from zip.vim / tar.vim
  path = vim.fn.substitute(path, "zipfile://\\(.\\{-}\\)::[^\\\\].*$", "\\1", "")
  path = vim.fn.substitute(path, "tarfile:\\(.\\{-}\\)::.*$", "\\1", "")
  return path
end
local dirname = function(path)
  local strip_dir_pat = "/([^/]+)$"
  local strip_sep_pat = "/$"
  if not path or #path == 0 then
    return
  end
  local result = path:gsub(strip_sep_pat, ""):gsub(strip_dir_pat, "")
  if #result == 0 then
    if is_windows then
      return path:sub(1, 2):upper()
    else
      return "/"
    end
  end
  return result
end
local function is_fs_root(path)
  if is_windows then
    return path:match("^%a:$")
  else
    return path == "/"
  end
end
local iterate_parents = function(path)
  local function it(_, v)
    if v and not is_fs_root(v) then
      v = dirname(v)
    else
      return
    end
    if v and vim.loop.fs_realpath(v) then
      return v, path
    else
      return
    end
  end
  return it, path, path
end
local search_ancestors = function(startpath, func)
  vim.validate({ func = { func, "f" } })
  if func(startpath) then
    return startpath
  end
  local guard = 100
  for path in iterate_parents(startpath) do
    -- Prevent infinite recursion if our algorithm breaks
    guard = guard - 1
    if guard == 0 then
      return
    end

    if func(path) then
      return path
    end
  end
end

local root_pattern = function(...)
  local patterns = vim.tbl_flatten({ ... })
  local function matcher(path)
    for _, pattern in ipairs(patterns) do
      for _, p in ipairs(vim.fn.glob(path_join(escape_wildcards(path), pattern), true, true)) do
        if path_exists(p) then
          return path
        end
      end
    end
  end
  return function(startpath)
    startpath = strip_archive_subpath(startpath)
    return search_ancestors(startpath, matcher)
  end
end

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
        local std_extended_capbilities = {
          resolveAdditionalTextEditsSupport = true,
          classFileContentsSupport = false,
          -- progressReportProvider = false,
          -- classFileContentsSupport = false,
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
        -- handlers = {
        -- ["language/status"] = function(_, result)
        --   -- Print or whatever.
        -- end,
        -- ["$/progress"] = function(error, result, ctx)
        -- disable progress updates.
        -- if result.value then
        --   if result.value.title then
        --     if
        --       (result.value.kind == "begin" and result.value.message:find("Building") ~= nil)
        --       or result.value.kind == "report"
        --       or result.value.kind == "end"
        --     then
        --       return vim.lsp.handlers["$/progress"](error, result, ctx)
        --     end
        --   end
        -- end
        --   end,
        -- },
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
            { "build.gradle", "build.gradle.kts", ".git" },
          }) do
            local root = root_pattern(unpack(patterns))(fname)
            if root then
              return root
            end
          end
        end,

        -- require("lspconfig.server_configurations.jdtls").default_config.root_dir,
        -- root_dir = function(bufname)
        --   local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", ".project" }
        --   bufname = bufname or vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
        --   local dirname = vim.fn.fnamemodify(bufname, ":p:h")
        --   local getparent = function(p)
        --     return vim.fn.fnamemodify(p, ":h")
        --   end
        --   while getparent(dirname) ~= dirname do
        --     for _, marker in ipairs(root_markers) do
        --       if vim.loop.fs_stat(jdtls_join(dirname, marker)) then
        --         return dirname
        --       end
        --     end
        --     dirname = getparent(dirname)
        --   end
        --   return dirname

        -- root_markers = {
        --   -- Single-module projects
        --   {
        --     "build.xml", -- Ant
        --     "pom.xml", -- Maven
        --     "settings.gradle", -- Gradle
        --     "settings.gradle.kts", -- Gradle
        --   },
        --   -- Multi-module projects
        --   { "build.gradle", "build.gradle.kts" },
        -- }
        -- local root_dir = require("jdtls.setup").find_root(root_markers, fname)
        -- return root_dir or vim.fn.getcwd()
        --   for _, patterns in ipairs(root_files) do
        --     local root = require("lspconfig.util").root_pattern(unpack(patterns))(fname)
        --     if root then
        --       return root
        --     end
        --   end
        -- end,

        -- root_dir = function()
        --   -- Find root of project
        --   local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", ".project" }
        --   local root_dir = require("jdtls.setup").find_root(root_markers)
        --   if root_dir == "" then
        --     return
        --   end
        -- end,
        -- root_dir = function(fname)
        -- for _, patterns in ipairs(root_files) do
        --   local root = util.root_pattern(unpack(patterns))(fname)
        --   if root then
        --     return root
        --   end
        -- end
        -- -- Find root of project
        --   local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", ".project" }
        --   local root_dir = require("jdtls.setup").find_root(root_markers, fname)
        --   if root_dir == "" then
        --     return
        --   end
        -- end,
        --
        -- How to find the project name for a given root dir.
        project_name = function(root_dir)
          return root_dir and vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t") -- vim.fs.basename(root_dir)
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
              "-Dosgi.sharedConfiguration.area=" .. jdtls_install_path .. "/config_" .. opts.config_os(),
              "-Dosgi.sharedConfiguration.area.readOnly=true",
              "-Dosgi.configuration.cascaded=true",
              "-Djava.import.generatesMetadataFilesAtProjectRoot=false",
              "-DDetectVMInstallationsJob.disabled=true",
              '-D"aether.dependencyCollector.impl=bf"',
              "-Dsun.zip.disableMemoryMapping=true",
              "-XX:+UseParallelGC",
              "-XX:GCTimeRatio=4",
              "-XX:AdaptiveSizePolicyWeight=90",
              "-XX:+UseStringDeduplication",
              "-Xmx1G",
              "-Xms100m",
              "-Xlog:disable",
              "-javaagent:" .. jdtls_install_path .. "/lombok.jar",
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
