-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.api.nvim_set_keymap(
  "n",
  "g?",
  ":lua vim.diagnostic.open_float()<CR>",
  { desc = "show Typeinfo", noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "gp", "<cmd>LazyPodman<CR>", { desc = "LazyPodman", noremap = true, silent = true })

vim.api.nvim_set_keymap(
  "n",
  "<leader>xr",
  ":lua vim.diagnostic.reset()<CR>",
  { desc = "reset Diagnostics cache", noremap = true, silent = true }
)

-- vim.api.nvim_set_keymap.set("n", "gC", function()
--   require("telescope").extensions.diff.diff_files({ hidden = true })
-- end, { desc = "Compare 2 files" })
vim.keymap.set("n", "gC", function()
  require("telescope").extensions.diff.diff_current({ hidden = true })
end, { desc = "Compare file with current" })
