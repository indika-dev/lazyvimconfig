-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- open a note from Obsidian app in Neovim
local vault_location = "/**.md"
if "stefan" == vim.env.USER then
  vault_location = vim.env.HOME .. "/Dokumente/obsidian/my-vault" .. vault_location
else
  vault_location = vim.env.HOME .. "/Dokumente/obsidian-vault/Makroarchitektur" .. vault_location
end
local group = vim.api.nvim_create_augroup("obsidian_cmds", { clear = true })
vim.api.nvim_create_autocmd("BufAdd", {
  command = "ObsidianOpen",
  pattern = { vault_location },
  group = group,
  desc = "Opens the current buffer in Obsidian",
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

if vim.g.neovide then
  -- Dieser Autocommand schaltet die relative Nummerierung aus, wenn wir mit dem Scrollen beginnen
  vim.api.nvim_create_autocmd({ "WinScrolled" }, {
    callback = function(ev)
      if vim.o.relativenumber then
        vim.cmd("set relativenumber norelativenumber")
        vim.g.neovide_winscrolled = true
      end
    end,
  })

  -- Dieser Autocommand schaltet die relative Nummerierung ein, wenn wir untätig waren (mit dem Scrollen aufgehört haben)
  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    callback = function(ev)
      if not vim.o.relativenumber and vim.g.neovide_winscrolled then
        vim.cmd("set relativenumber relativenumber")
      end
      vim.g.neovide_winscrolled = false
    end,
  })
end

-- vim.api.nvim_create_autocmd("ColorScheme", {
--   pattern = "kanagawa",
--   callback = function()
--     if vim.o.background == "light" then
--       vim.fn.system("kitty +kitten themes Kanagawa_light")
--     elseif vim.o.background == "dark" then
--       vim.fn.system("kitty +kitten themes Kanagawa_dragon")
--     else
--       vim.fn.system("kitty +kitten themes Kanagawa")
--     end
--   end,
-- })
