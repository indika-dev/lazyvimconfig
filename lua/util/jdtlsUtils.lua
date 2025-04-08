local SCANDIR = require("util.scandir")

-- originally taken from lspconfig
local JdtlsUtils = {}

JdtlsUtils.is_int = function(n)
  return (type(n) == "number") and (math.floor(n) == n)
end

JdtlsUtils.is_windows = vim.loop.os_uname().version:match("Windows")

JdtlsUtils.jdtls_join = function(...)
  local sep = vim.loop.os_uname().version:match("Windows") and "\\" or "/"
  local result = table.concat(vim.tbl_flatten({ ... }), sep):gsub(sep .. "+", sep)
  return result
end

JdtlsUtils.escape_wildcards = function(path)
  return path:gsub("([%[%]%?%*])", "\\%1")
end

JdtlsUtils.path_join = function(...)
  return table.concat(vim.tbl_flatten({ ... }), "/")
end

JdtlsUtils.path_exists = function(filename)
  local stat = vim.loop.fs_stat(filename)
  return stat and stat.type or false
end

JdtlsUtils.strip_archive_subpath = function(path)
  -- Matches regex from zip.vim / tar.vim
  path = vim.fn.substitute(path, "zipfile://\\(.\\{-}\\)::[^\\\\].*$", "\\1", "")
  path = vim.fn.substitute(path, "tarfile:\\(.\\{-}\\)::.*$", "\\1", "")
  return path
end

JdtlsUtils.dirname = function(path)
  local strip_dir_pat = "/([^/]+)$"
  local strip_sep_pat = "/$"
  if not path or #path == 0 then
    return
  end
  local result = path:gsub(strip_sep_pat, ""):gsub(strip_dir_pat, "")
  if #result == 0 then
    if JdtlsUtils.is_windows then
      return path:sub(1, 2):upper()
    else
      return "/"
    end
  end
  return result
end

JdtlsUtils.is_fs_root = function(path)
  if JdtlsUtils.is_windows then
    return path:match("^%a:$")
  else
    return path == "/"
  end
end

JdtlsUtils.iterate_parents = function(path)
  local function it(_, v)
    if v and not JdtlsUtils.is_fs_root(v) then
      v = JdtlsUtils.dirname(v)
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

JdtlsUtils.search_ancestors = function(startpath, func)
  vim.validate({ func = { func, "f" } })
  if func(startpath) then
    return startpath
  end
  local guard = 100
  for path in JdtlsUtils.iterate_parents(startpath) do
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

JdtlsUtils.root_pattern = function(...)
  local patterns = vim.tbl_flatten({ ... })
  local function matcher(path)
    for _, pattern in ipairs(patterns) do
      for _, p in ipairs(vim.fn.glob(JdtlsUtils.path_join(JdtlsUtils.escape_wildcards(path), pattern), true, true)) do
        if JdtlsUtils.path_exists(p) then
          return path
        end
      end
    end
  end
  return function(startpath)
    startpath = JdtlsUtils.strip_archive_subpath(startpath)
    return JdtlsUtils.search_ancestors(startpath, matcher)
  end
end

local file_exists = function(name)
  local f = io.open(name, "r")
  return f ~= nil and io.close(f)
end

JdtlsUtils.get_shared_links_from_mason_receipt = function(package_name, key_prefix)
  local success, mason_registry = pcall(require, "mason-registry")
  local result = {}
  if success then
    local has_package, mason_package = pcall(mason_registry.get_package, package_name)
    if has_package then
      if mason_package:is_installed() then
        local install_path = mason_package:get_install_path()
        mason_package:get_receipt():if_present(function(recipe)
          local version_mismatch = false
          for key, value in pairs(recipe.links.share) do
            if key:sub(1, #key_prefix) == key_prefix then
              if not file_exists(install_path .. "/" .. value) then
                version_mismatch = true
              end
              table.insert(result, install_path .. "/" .. value)
            end
          end
          if version_mismatch then
            result = {}
            vim.notify(package_name .. " will be loaded without mason", vim.log.levels.WARN)
            for _, fname in ipairs(SCANDIR.scandir(install_path, true, "jar")) do
              table.insert(result, fname)
            end
          end
        end)
      end
    end
  end
  return result
end

JdtlsUtils.addAll = function(target, insertion)
  for _, value in pairs(insertion) do
    table.insert(target, value)
  end
end

return JdtlsUtils
