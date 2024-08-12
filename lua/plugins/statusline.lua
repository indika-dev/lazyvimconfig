local icons = require("util.config").icons

-- local icons = require("config").icons.highlighted
local filetypes = require("util.config").filetypes

local window_width_limit = 70

local function service_status()
  local buf = vim.api.nvim_get_current_buf()
  local buf_ft = vim.bo.filetype

  ---@class ServiceStatus
  ---@field diagnostic_providers string[]
  ---@field formatting_providers string[]
  ---@field copilot_active boolean
  ---@field treesitter_active boolean
  ---@field session_active boolean
  ---@field lazy_updates boolean
  local status = {
    diagnostic_providers = {},
    formatting_providers = {},
    copilot_active = false,
    treesitter_active = vim.treesitter.highlighter.active[buf] ~= nil and next(vim.treesitter.highlighter.active[buf]),
    session_active = require("persistence").current ~= nil,
    lazy_updates = require("lazy.status").has_updates(),
    -- TODO: check for mason updates
    -- mason_updates
  }

  -- add lsp clients
  for _, client in pairs(vim.lsp.get_clients()) do
    if client.name == "copilot" then
      status.copilot_active = true
    else
      table.insert(status.diagnostic_providers, client.name)
    end
  end

  -- add linters
  local lint_ok, lint = pcall(require, "lint")
  if lint_ok then
    local active = lint._resolve_linter_by_ft(buf_ft)
    if active then
      -- concat the active linters to the list of diagnostic providers
      for _, linter in pairs(active) do
        table.insert(status.diagnostic_providers, linter)
      end
    end
  end

  -- add formatters
  local conform_ok, conform = pcall(require, "conform")
  if conform_ok then
    local active = conform.list_formatters(buf)
    if active then
      for _, formatter in ipairs(active) do
        table.insert(status.formatting_providers, formatter)
      end
    end
    if conform.list_formatters({ bufnr = buf }) then
      table.insert(status.formatting_providers, "lsp")
    end
  end

  ---@class ServiceStatus
  return status
end

local function visible_for_width(limit)
  limit = limit == nil and window_width_limit or limit
  return vim.fn.winwidth(0) > limit
end

local function visible_for_filetype()
  return not vim.tbl_contains(filetypes.ui, vim.bo.filetype)
end

-- Only show tabline if we have more than one tab open.
local function tabline_active()
  return #vim.api.nvim_list_tabpages() > 1
end

local branch = {
  -- "b:gitsigns_head",
  "branch",
  icon = "",
  color = { gui = "bold" },
  cond = visible_for_width,
}

local tabs = {
  "tabs",
  mode = 0,
  cond = function()
    return visible_for_filetype() and tabline_active()
  end,
}

-- TODO: Look at https://github.com/Iron-E/nvim-libmodal#lualinenvim
-- for example of how to do arbitrary modes with themes.
local mode = {
  function()
    if vim.b.visual_multi == 1 then
      local vm = vim.b.VM_Selection
      if vm then
        return "V-MULTI " .. vm.Vars.index + 1 .. "/" .. #vm.Regions
      else
        return "V-MULTI"
      end
    end
    local hydra_ok, hydra = pcall(require, "hydra.statusline")
    if hydra_ok and hydra.is_active() then
      local name = hydra.get_name()
      local color = hydra.get_color()

      if name ~= nil then
        return name
      end
    end

    return require("lualine.utils.mode").get_mode()
  end,
}

local macro = {
  function()
    return require("noice").api.status.mode.get()
  end,
  cond = function()
    return package.loaded["noice"] and require("noice").api.status.mode.has()
  end,
}

local filepath = {
  "filename",
  file_status = false,
  path = 3, -- 3: Absolute path, with tilde as the home directory
  shorting_target = 20, -- Shortens path to leave 40 spaces in the window for other components.
  color = "Comment",
  cond = visible_for_filetype,
}

local diff = {
  "diff",
  symbols = {
    added = icons.diff.added,
    modified = icons.diff.modified,
    removed = icons.diff.removed,
  },
  cond = nil,
}

local diagnostics = {
  "diagnostics",
  sources = { "nvim_diagnostic" },
  symbols = {
    error = icons.diagnostics.Error,
    warn = icons.diagnostics.Warn,
    info = icons.diagnostics.Info,
    hint = icons.diagnostics.Hint,
  },
}

-- Adapted from https://github.com/LunarVim/LunarVim/blob/48320e/lua/lvim/core/lualine/components.lua#L82
local services = {
  function()
    local display = {}
    local status = service_status()

    if #status.diagnostic_providers > 0 then
      table.insert(display, icons.services.diagnostics .. table.concat(vim.fn.uniq(status.diagnostic_providers), ", "))
    end

    -- add formatters
    if #status.formatting_providers > 0 then
      table.insert(display, icons.services.formatting)
    end

    -- add copilot
    if status.copilot_active then
      table.insert(display, icons.services.copilot)
    end

    -- add treesitter
    if status.treesitter_active then
      table.insert(display, icons.services.treesitter)
    end

    if status.session_active then
      table.insert(display, icons.services.persisting)
    else
      table.insert(display, icons.services.not_persisting)
    end

    if status.lazy_updates then
      local checker = require("lazy.manage.checker")
      table.insert(display, " " .. #checker.updated)
    end

    return table.concat(display, " ")
  end,
}

local searchcount = {
  "searchcount",
  timeout = 200,
}

local tabstop = {
  function()
    return "󰯉 " .. vim.bo.tabstop
  end,
  cond = visible_for_width,
}

-- Returns a string with a list of attached LSP clients, including
-- formatters and linters from null-ls, nvim-lint and formatter.nvim

local get_attached_clients = {
  function()
    local buf_clients = vim.lsp.get_active_clients({ bufnr = 0 })
    if #buf_clients == 0 then
      return "LSP Inactive"
    end

    local buf_ft = vim.bo.filetype
    local buf_client_names = {}

    -- add client
    for _, client in pairs(buf_clients) do
      if client.name ~= "copilot" and client.name ~= "null-ls" then
        table.insert(buf_client_names, client.name)
      end
    end

    -- Generally, you should use either null-ls or nvim-lint + formatter.nvim, not both.

    -- Add sources (from null-ls)
    -- null-ls registers each source as a separate attached client, so we need to filter for unique names down below.
    local null_ls_s, null_ls = pcall(require, "none-ls")
    if null_ls_s then
      local sources = null_ls.get_sources()
      for _, source in ipairs(sources) do
        if source._validated then
          for ft_name, ft_active in pairs(source.filetypes) do
            if ft_name == buf_ft and ft_active then
              table.insert(buf_client_names, source.name)
            end
          end
        end
      end
    end

    -- Add linters (from nvim-lint)
    local lint_s, lint = pcall(require, "lint")
    if lint_s then
      for ft_k, ft_v in pairs(lint.linters_by_ft) do
        if type(ft_v) == "table" then
          for _, linter in ipairs(ft_v) do
            if buf_ft == ft_k then
              table.insert(buf_client_names, linter)
            end
          end
        elseif type(ft_v) == "string" then
          if buf_ft == ft_k then
            table.insert(buf_client_names, ft_v)
          end
        end
      end
    end

    -- Add formatters (from formatter.nvim)
    local formatter_s, _ = pcall(require, "formatter")
    if formatter_s then
      local formatter_util = require("formatter.util")
      for _, formatter in ipairs(formatter_util.get_available_formatters_for_ft(buf_ft)) do
        if formatter then
          table.insert(buf_client_names, formatter)
        end
      end
    end

    -- This needs to be a string only table so we can use concat below
    local unique_client_names = {}
    for _, client_name_target in ipairs(buf_client_names) do
      local is_duplicate = false
      for _, client_name_compare in ipairs(unique_client_names) do
        if client_name_target == client_name_compare then
          is_duplicate = true
        end
      end
      if not is_duplicate then
        table.insert(unique_client_names, client_name_target)
      end
    end

    local client_names_str = table.concat(unique_client_names, ", ")
    local language_servers = string.format("[%s]", client_names_str)

    return language_servers
  end,
}

return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        component_separators = { left = "", right = "" },
        -- section_separators = { left = "", right = "" },
        -- disabled_filetypes = require("config").filetypes.ui,
        globalstatus = true,
      },
      sections = {
        -- lualine_a = { tabs, mode, macro, searchcount },
        -- lualine_b = { branch },
        -- lualine_c = { filepath },
        -- lualine_x = { diagnostics, get_attached_clients },
        -- lualine_y = { tabstop },
        -- lualine_z = { services },
        --
        --
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { services, "progress" },
        lualine_z = { get_attached_clients },
      },
      inactive_sections = {
        -- lualine_a = { filepath },
        -- lualine_b = {},
        -- lualine_c = {},
        -- lualine_x = {},
        -- lualine_y = {},
        -- lualine_z = {},
        --
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
    },
  },
}
