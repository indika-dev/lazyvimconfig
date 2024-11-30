---@return string|nil path_to_ls path to directory of spring-boot language server or nil for using default value
local try_jar_from_mason = function(package_name, key_prefix)
  local success, mason_registry = pcall(require, "mason-registry")
  if success then
    local mason_package = mason_registry.get_package(package_name)
    if mason_package:is_installed() then
      local install_path = mason_package:get_install_path()
      mason_package:get_receipt():if_present(function(recipe)
        for key, value in pairs(recipe.links.share) do
          if key:sub(1, #key_prefix) == key_prefix then
            return vim.fn.fnamemodify(install_path .. "/" .. value, ":h")
          end
        end
      end)
    end
  end
  return nil
end

return {
  {
    "JavaHello/spring-boot.nvim",
    ft = "java",
    dependencies = {
      "mfussenegger/nvim-jdtls",
    },
    opts = function()
      return {
        ls_path = try_jar_from_mason("vscode-spring-boot-tools", "vscode-spring-boot-tools/language-server.jar"),
        java_cmd = vim.env.HOME .. "/.local/lib/semeru-17/bin/java",
      }
    end,
    setup = function(_, opts)
      require("spring_boot").init_lsp_commands()
      require("spring_boot").setup(opts)
    end,
  },
}
