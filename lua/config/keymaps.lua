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

if vim.g.neovide then
  -- vim.api.nvim_set_keymap("n", "p", "<cmd>:put +<cr>Jk", { noremap = true, silent = true })
  -- vim.api.nvim_set_keymap("n", "p", "<cmd>:set paste | put + | set nopaste<cr>Jk", { noremap = true, silent = true })
  -- vim.api.nvim_set_keymap("n", "<s-p>", "<cmd>:put! +<cr>Jk", { noremap = true, silent = true })
  -- Ctrl-ScrollWheel for zooming in/out
  vim.api.nvim_set_keymap("n", "<C-ScrollWheelUp>", "<cmd>:set guifont=+<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "<C-ScrollWheelDown>", "<cmd>:set guifont=-<CR>", { noremap = true, silent = true })
end
