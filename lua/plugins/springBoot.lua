return {
  {
    "JavaHello/spring-boot.nvim",
    ft = { "jproperties" },
    opts = function()
      require("mason").setup()
      local success, mason_registry = pcall(require, "mason-registry")
      if success then
        mason_registry.refresh()
      end
      return {
        java_cmd = vim.env.HOME .. "/.local/lib/semeru-17/bin/java",
        autocmd = true,
      }
    end,
  },
}
