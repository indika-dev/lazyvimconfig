local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

if "stefan" == vim.env.USER then
  vim.opt.rtp:append("/usr/bin/")
else
  vim.opt.rtp:append("/home/linuxbrew/.linuxbrew/bin/")
end
vim.filetype.add({
  extension = {
    mustache = "mustache",
    hogan = "mustache",
    hulk = "mustache",
    hjs = "mustache",
    handlebars = "handlebars",
    hdbs = "handlebars",
    hbs = "handlebars",
    hb = "handlebars",
  },
})
vim.treesitter.language.register("glimmer", "mustache") -- the someft filetype will use the python parser and queries.
vim.treesitter.language.register("glimmer", "handlebars") -- the someft filetype will use the python parser and queries.

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
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
