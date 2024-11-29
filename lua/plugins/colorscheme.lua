---@module 'util.SunTimes'
local FromDuskTillDawn = require("util.SunTimes")

local function isKitty()
  return os.getenv("KITTY_WINDOW_ID") ~= nil
end

function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

local colorscheme

local scheduler = {}

scheduler.timer = vim.uv.new_timer()

scheduler.scheduleColorSchemeChange = function(futureTimestamp)
  -- ensure that only one timer is active
  scheduler.timer:stop()
  scheduler.timer:close()
  scheduler.timer = vim.uv.new_timer()
  local _nowepochtime = os.time(os.date("!*t"))
  local timeoutInSec = futureTimestamp - _nowepochtime + 1
  scheduler.timer:start(timeoutInSec * 1000, 0, function()
    scheduler.timer:stop()
    scheduler.timer:close()
    vim.schedule_wrap(function()
      local _colorscheme = "colorscheme " .. colorscheme()
      vim.cmd(_colorscheme)
    end)
  end)
  -- vim.notify("scheduled colorscheme change @" .. os.date("%c", _nowepochtime + timeoutInSec), vim.log.levels.INFO)
end

colorscheme = function()
  if "stefan" == vim.env.USER then
    local _nowepochtime = os.time(os.date("!*t"))
    local epochTimesTable = FromDuskTillDawn.GetSunTimes(51.09102, 6.5827)
    if
      _nowepochtime >= epochTimesTable.sunrise
      and _nowepochtime < epochTimesTable.sunset
      and "sunrise" == os.getenv("NVIM_THEME_SELECTOR")
    then
      scheduler.scheduleColorSchemeChange(epochTimesTable.sunset)
      if isKitty() then
        vim.fn.system("kitty +kitten themes Kanagawa_Light")
      end
      return "kanagawa-lotus"
    else
      local _tomorrowepochtime = epochTimesTable.sunrise + 24 * 60 * 60
      scheduler.scheduleColorSchemeChange(_tomorrowepochtime)
      if isKitty() then
        vim.fn.system("kitty +kitten themes Kanagawabones")
      end
      return "kanagawa-dragon" -- "lackluster-hack"
    end
  else
    if isKitty() then
      vim.fn.system("kitty +kitten themes Kanagawa")
    end
    return "kanagawa"
  end
end

-- Creating a simple setInterval wrapper
local function setInterval(interval, callback)
  local timer = uv.new_timer()
  timer:start(interval, interval, function()
    callback()
  end)
  return timer
end

-- And clearInterval
local function clearInterval(timer)
  timer:stop()
  timer:close()
end

return {
  -- add kanagawa
  {
    "rebelot/kanagawa.nvim",
    opts = {
      compile = false, -- enable compiling the colorscheme
      undercurl = true, -- enable undercurls
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false, -- do not set background color
      dimInactive = false, -- dim inactive window `:h hl-NormalNC`
      terminalColors = true, -- define vim.g.terminal_color_{0,17}
      colors = { -- add/modify theme and palette colors
        palette = {},
        theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
      },
      overrides = function(colors) -- add/modify highlights
        return {}
      end,
      theme = "wave", -- Load "wave" theme when 'background' option is not set
      background = { -- map the value of 'background' option to a theme
        dark = "wave", -- try "dragon" !
        light = "lotus",
      },
    },
  },
  {
    "slugbyte/lackluster.nvim",
    -- vim.cmd.colorscheme("lackluster")
    -- vim.cmd.colorscheme("lackluster-hack")
    -- vim.cmd.colorscheme("lackluster-mint")
  },

  -- Configure LazyVim to load kanagawa
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = colorscheme(),
    },
  },
}
