return {
  {
    -- "JavaHello/spring-boot.nvim",
    dir = "~/workspace/spring-boot.nvim",
    ft = { "java", "jproperties" },
    opts = function()
      return {
        java_cmd = vim.env.HOME .. "/.local/lib/semeru-17/bin/java",
      }
    end,
  },
}
