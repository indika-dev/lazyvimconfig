local function splitTime(time)
  local result = {}
  local counter = 0
  for part in (time .. ":"):gmatch("([^:]*):") do
    if counter == 0 then
      result.hour = tonumber(part)
    elseif counter == 1 then
      result.minutes = tonumber(part)
    end
    counter = counter + 1
  end
  return result
end

local stringtoboolean = { ["true"] = true, ["false"] = false }

local function getSunMoonTimes()
  local scriptFile = vim.fn.stdpath("config") .. "/lua/util/suntimes"
  local scriptFileResult
  local fh, err = assert(io.popen(scriptFile, "r"))
  if fh then
    scriptFileResult = fh:read()
  end
  -- local scriptFileResult, err = dofile(scriptFile) -- if script is executed with this lua instance, incorrect values are returned
  if err then
    local failureResult = {}
    failureResult.dawn = 0
    failureResult.sunrise = 0
    failureResult.sunset = 0
    failureResult.twilight = 0
    failureResult.solarnoon = true
    vim.notify("can't execute " .. scriptFile .. " : " .. err, vim.log.levels.ERROR)
    return failureResult
  end
  local counter = 0
  local result = {}
  for part in (scriptFileResult .. ","):gmatch("([^,]*),") do
    if counter == 0 then
      result.dawn = splitTime(part)
    elseif counter == 1 then
      result.sunrise = splitTime(part)
    elseif counter == 2 then
      result.sunset = splitTime(part)
    elseif counter == 3 then
      result.twilight = splitTime(part)
    elseif counter == 4 then
      result.solarnoon = stringtoboolean[part]
    end
    counter = counter + 1
  end
  return result
end

local colorscheme = function()
  local _time = os.date("*t")
  getSunMoonTimes()
  local timestable = getSunMoonTimes()
  if _time.hour >= timestable.sunrise.hour and _time.hour < timestable.sunset.hour then
    if "stefan" == vim.env.USER then
      vim.fn.system("kitty +kitten themes Kanagawa_Light")
      return "kanagawa-lotus"
    else
      vim.fn.system("kitty +kitten themes Kanagawa")
      return "kanagawa"
    end
  else
    vim.fn.system("kitty +kitten themes Kanagawabones")
    return "lackluster-hack" --"kanagawa-dragon"
  end
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
