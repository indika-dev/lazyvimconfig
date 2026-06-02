return {
  {
    "oclay1st/gradle.nvim",
    cmd = { "Gradle", "GradleExec", "GradleInit", "GradleFavorites" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      gradle_executable = "./gradlew",
    }, -- options, see default configuration
    keys = {
      { "<leader>G", desc = "+Gradle", mode = { "n", "v" } },
      { "<leader>Gg", "<cmd>Gradle<cr>", desc = "Gradle Projects" },
      { "<leader>Gf", "<cmd>GradleFavorites<cr>", desc = "Gradle Favorite Commands" },
    },
  },
}
