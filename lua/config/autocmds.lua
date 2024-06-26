-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- refresh code lens automatically
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = { "*.java", "*.rs", "*.js", "*.ts" },
  callback = function(args)
    local _, _ = pcall(vim.lsp.codelens.refresh)
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_augroup("wrap_spell", {})
vim.api.nvim_create_autocmd("FileType", {
  group = "wrap_spell",
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    -- try_lint without arguments runs the linters defined in `linters_by_ft`
    -- for the current filetype
    require("lint").try_lint()

    -- You can call `try_lint` with a linter name or a list of names to always
    -- run specific linters, independent of the `linters_by_ft` configuration
    -- require("lint").try_lint("cspell")
  end,
})

-- Disable some sources of slowdown in large buffers.
-- local LARGE_BUFFER = 1000000
--
-- local function detect_large_buffer(buffer)
--   buffer = buffer or vim.api.nvim_get_current_buf()
--   local stats_ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buffer))
--   if stats_ok and stats and (stats.size > LARGE_BUFFER) then
--     return true
--   end
--   return false
-- end
--
-- -- stylua: ignore start
-- local LARGE_BUFFER_DISABLED = {
--   copilot = function() vim.b.copilot_enabled = false end,
--   cmp = function() require("cmp").setup.buffer({ enabled = false }) end, ---@diagnostic disable-line: missing-fields
--   syntax = "syntax off",
--   indent_blankline = "IBLDisable",
--   treesitter_context = "TSContextDisable",
--   treesitter_highlight = "TSBufDisable highlight",
--   spell = function() vim.opt_local.spell = false end,
--   folds = function() vim.opt_local.foldmethod = "manual" end,
--   illuminate = function() require("illuminate").pause_buf() end,
--   ufo = function() require("ufo").detach() end,
-- }
-- -- stylua: ignore end
--
-- local function disable_large_buffer(buffer)
--   buffer = buffer or vim.api.nvim_get_current_buf()
--
--   if pcall(vim.api.nvim_buf_get_var, buffer, "large_buffer") then
--     return
--   end
--
--   vim.api.nvim_buf_set_var(buffer, "large_buffer", true)
--
--   local disabled = {}
--   for path, cmd in pairs(LARGE_BUFFER_DISABLED) do
--     if type(cmd) == "function" then
--       local ok = pcall(cmd)
--       if ok then
--         vim.notify(path .. " disabled", vim.log.levels.DEBUG)
--         table.insert(disabled, path)
--       else
--         vim.notify("Failed to disable " .. path, vim.log.levels.ERROR)
--       end
--     elseif pcall(vim.cmd, cmd) then ---@diagnostic disable-line: param-type-mismatch
--       vim.notify(path .. " disabled with " .. cmd, vim.log.levels.DEBUG)
--       table.insert(disabled, path)
--     else
--       vim.notify(cmd .. " failed", vim.log.levels.ERROR)
--     end
--   end
--   vim.notify("Disabling:\n  " .. table.concat(disabled, "\n  "), vim.log.levels.INFO)
-- end
--
-- vim.api.nvim_create_user_command("DisableLargeBuffer", function()
--   disable_large_buffer()
-- end, {})
--
-- vim.api.nvim_create_autocmd({ "BufReadPost" }, {
--   pattern = "*",
--   group = vim.api.nvim_create_augroup("large_buffer", { clear = true }),
--   callback = function()
--     local buffer = vim.api.nvim_get_current_buf()
--     vim.api.nvim_buf_set_var(buffer, "large_buffer", false)
--     if detect_large_buffer(buffer) then
--       vim.notify("Large file detected!", vim.log.levels.INFO)
--       disable_large_buffer(buffer)
--     end
--   end,
-- })
--
-- vim.keymap.set("n", "<leader>bL", "<cmd>DisableLargeBuffer<cr>", { desc = "Disable large buffer" })
