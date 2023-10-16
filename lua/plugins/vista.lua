return {
  {
    "liuchengxu/vista.vim",
    keys = {
      { "<leader>cO", "<cmd>Vista!!<cr>", desc = "Outline Symbols" },
    },
    config = function(_, _)
      vim.g.vista_default_executive = "nvim_lsp"
      vim.g.vista_echo_cursor_strategy = "floating_win"
      vim.g.vista_floating_delay = 100
      vim.g.vista_cursor_delay = 200
      vim.g.vista_update_on_text_changed = 1
      vim.g.vista_update_on_text_changed_delay = 200
      vim.g.vista_sort = true
      vim.cmd([[
        " let g:vista_sidebar_width = 'vertical botright'
        " let g:vista_sidebar_position = 30
        " let g:vista_blink = [2, 100]
        " let g:vista_top_level_blink = [2, 100]
        " let g:vista_icon_indent = ['└ ', '│ ']
        " let g:vista_fold_toggle_icons = ['▼', '▶']
        " let g:vista_update_on_text_changed = 1
        " let g:vista_update_on_text_changed_delay = 200
        " let g:vista_echo_cursor = 0
        " let g:vista_echo_cursor_strategy = 'floating_win'
        " let g:vista_no_mappings = 0
        " let g:vista_stay_on_open = 1
        " let g:vista_close_on_jump = 0
        " let g:vista_close_on_fzf_select = 0
        " let g:vista_disable_statusline = exists('g:loaded_airline') || exists('g:loaded_lightline')
        " let g:vista_cursor_delay = 200
        " let g:vista_ignore_kinds = []
        " let g:vista_executive_for = {}
        " let g:vista_default_executive = 'nvim_lsp'
        " let g:vista_enable_centering_jump = 1
        " let g:vista_find_nearest_method_or_function_delay = 200
        " let g:vista_finder_alternative_executives = ['coc']
        " " Select the absolute nearest function when using binary search.
        " let g:vista_find_absolute_nearest_method_or_function = 0
        " let g:vista_fzf_preview = ['right:50%']
        " let g:vista_fzf_opt = []
        " let g:vista_keep_fzf_colors = 0
        " let g:vista_cversions_executable = 'cversions'
        " let g:vista_cversions_cmd = {}
        " let g:vista_highlight_whole_line = 0
        " let g:vista_floating_delay = 100
        " let g:vista#renderer#enable_icon = exists('g:vista#renderer#icons') || exists('g:airline_powerline_fonts')
        " let g:vista#renderer#enable_kind = !g:vista#renderer#enable_icon
        " let g:vista#renderer#icons = {}
        " let g:vista#renderer#cversions = 'default'
      ]])
    end,
  },
}
