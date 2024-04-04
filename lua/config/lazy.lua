local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
-- vim.opt.rtp:prepend(vim.env.LAZY or lazypath)
-- if "stefan" == vim.env.USER then
--   vim.opt.rtp:append("/usr/bin/fzf")
-- else
--   vim.opt.rtp:append("/home/linuxbrew/.linuxbrew/opt/fzf")
-- end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)
if "stefan" == vim.env.USER then
  -- vim.opt.rtp:append("/usr/bin/rg")
else
  vim.opt.rtp:append("/home/linuxbrew/.linuxbrew/bin")
end

vim.api.nvim_create_user_command("LazyPodman", function()
  if vim.fn.has("nvim-0.5") == 0 then
    print("LazyPodman needs Neovim >= 0.5")
    return
  end

  require("util.lazypodman").toggle()
end, {})

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import any extras modules here
    -- { import = "lazyvim.plugins.extras.lang.typescript" },
    -- { import = "lazyvim.plugins.extras.ui.mini-animate" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "kanagawa" } },
  checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        "netrwPlugin",
        "rplugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
