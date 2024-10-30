local FromDuskTillDawn = require("util.WeaterSunMoonTimes")
local uv = vim.uv

colorscheme = function()
  local _nowepochtime = os.time(os.date("!*t"))
  local epochTimesTable = FromDuskTillDawn.GetSunMoonTimes(51.09102, 6.5827, 1, _nowepochtime, "false", 0, 1)
  if _nowepochtime >= epochTimesTable.sunrise and _nowepochtime < epochTimesTable.sunset then
    setTimeout((epochTimesTable.sunset - _nowepochtime) * 1000, colorscheme)
    if "stefan" == vim.env.USER then
      vim.fn.system("kitty +kitten themes Kanagawa_Light")
      return "kanagawa-lotus"
    else
      vim.fn.system("kitty +kitten themes Kanagawa")
      return "kanagawa"
    end
  else
    local _tomorrowepochtime = epochTimesTable.sunrise + 24 * 60 * 60
    epochTimesTable = FromDuskTillDawn.GetSunMoonTimes(51.09102, 6.5827, 1, _tomorrowepochtime, "false", 0, 1)
    setTimeout((epochTimesTable.sunrise - _nowepochtime) * 1000, colorscheme)
    vim.fn.system("kitty +kitten themes Kanagawabones")
    return "lackluster-hack" --"kanagawa-dragon"
  end
end

-- Creating a simple setTimeout wrapper
function setTimeout(timeout, callback)
  local timer = uv.new_timer()
  timer:start(timeout, 0, function()
    timer:stop()
    timer:close()
    callback()
  end)
  return timer
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
