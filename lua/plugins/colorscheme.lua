local SunsetMoonrise = require("util.WeaterSunMoonTimes")

local timestable = SunsetMoonrise:GetSunMoonTimes(51.09102, 6.5827, 1, 1730062503, "false", 0, 1)

local colorscheme = function()
  local _time = os.date("*t")
  if _time.hour >= timestable.sunrise.hours and _time.hour < timestable.sunset.hours then
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
