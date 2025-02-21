local class = require("util.class")
local Popup = require("nui.popup")

--[[
 config
]]
local config = {}

function config.defaults()
  local defaults = {
    popup_window = {
      enter = true,
      focusable = true,
      zindex = 40,
      position = "50%",
      relative = "win",
      size = {
        width = "90%",
        height = "90%",
      },
      buf_options = {
        modifiable = true,
        readonly = false,
      },
      win_options = {
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        winblend = 0,
      },
      border = {
        highlight = "FloatBorder",
        style = "rounded",
        text = {
          top = " Lazydocker ",
        },
      },
    },
  }
  return defaults
end

config.options = {}

config.namespace_id = vim.api.nvim_create_namespace("LazyDocker")

function config.setup(options)
  options = options or {}
  config.options = vim.tbl_deep_extend("force", {}, config.defaults(), options)
end

--[[
utils
--]]
local utils = {}

utils.is_lazydocker_available = function()
  local install_dirs = {
    vim.env.HOME .. "/.local/bin/lazydocker",
    "/opt/homebrew/bin/lazydocker",
    "/usr/local/bin/lazydocker",
    vim.env.HOME .. "/.cargo/bin/lazydocker",
  }
  for _, v in pairs(install_dirs) do
    if vim.fn.executable(v) == 1 then
      return true
    end
  end
  return false
end

utils.is_docker_available = function()
  return vim.fn.executable("podman") == 1
end

--[[
main part
--]]

local View = class({})

function View:init()
  self.is_open = false
  self.docker_panel = nil
end

function View:set_listeners()
  self.docker_panel:map("n", "q", function()
    self:close("disable_autocmd")
  end, { noremap = true })

  self.docker_panel:on("BufLeave", function()
    self:close()
  end)
end

function View:check_requirements()
  if utils.is_lazydocker_available() ~= true then
    print("Missing requirement: lazydocker not installed")
    return false
  end

  if utils.is_docker_available() ~= true then
    print("Missing requirement: docker not installed")
    return false
  end

  return true
end

function View:open()
  local all_requirements_ok = self:check_requirements()
  if all_requirements_ok ~= true then
    return
  end

  self.docker_panel = Popup(config.options.popup_window)
  self.docker_panel:mount()
  self:render()
  self:set_listeners()
  self.is_open = true
end

function View:close(opts)
  if opts == "disable_autocmd" then
    self.docker_panel:off("BufLeave")
  end

  self.docker_panel:unmount()
  self.is_open = false
  vim.cmd("silent! :checktime")
end

function View:render()
  vim.fn.termopen(vim.fn.expand("$HOME/Applications/lazydocker"), {
    on_exit = function()
      self:close()
    end,
  })
  vim.cmd("startinsert")
end

function View:toggle()
  if self.is_open == false then
    self:open()
  else
    self:close("disable_autocmd")
  end
end

--[[
instantiate
--]]
local LazyPodman = {}

local LazyPodmanView = View()

function LazyPodman.toggle()
  LazyPodmanView:toggle()
end

--[[
integration
--]]
config.setup()

return LazyPodman
