-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.termguicolors = true
if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0.01
  vim.g.neovide_cursor_trail_size = 0.05
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_cursor_animate_in_insert_mode = false
  vim.g.neovide_cursor_unfocused_outline_width = 0.125
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_padding_left = 0
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_refresh_rate = 60
  vim.g.neovide_refresh_rate_idle = 5
  vim.g.neovide_fullscreen = false
  vim.g.neovide_profiler = false
  -- vim.g.neovide_cursor_vfx_mode = ''
  -- command -nargs=0 NeovideToggleFullscreen :let g:neovide_fullscreen = !g:neovide_fullscreen
  -- nnoremap <a-cr> :NeovideToggleFullscreen<cr>
  -- vim.o.guifont = "JetBrainsMono Nerd Font:h12"
  -- vim.o.guifont = "CaskaydiaCove Nerd Font:h14"
  if "stefan" == vim.env.USER then
    vim.o.guifont = "FiraCode Nerd Font Mono:h16"
  else
    vim.o.guifont = "FiraCode Nerd Font Mono:h14"
  end
  -- vim.o.guifont ="GoMono NF:h16"
  -- vim.o.guifont ="FuraCode NF:h16"
  -- vim.o.guifont ="Hack Nerd Font:h16"
  -- vim.o.guifont ="NotoSansMono Nerd Font:h16"
  -- vim.o.guifont ="SaucecodePro Nerd Font:h16"
  -- vim.o.guifont ="UbuntuMonoDerivativePowerline Nerd Font:h16"
  -- vim.cmd [[set guifont=FiraCode\ Nerd\ Font:h12]]
  -- vim.api.nvim_set_keymap("n", "p", "<cmd>:put +<cr>Jk", { noremap = true, silent = true })
  -- vim.api.nvim_set_keymap("n", "p", "<cmd>:set paste | put + | set nopaste<cr>Jk", { noremap = true, silent = true })
  -- vim.api.nvim_set_keymap("n", "<s-p>", "<cmd>:put! +<cr>Jk", { noremap = true, silent = true })
  -- Ctrl-ScrollWheel for zooming in/out
  vim.api.nvim_set_keymap("n", "<C-ScrollWheelUp>", "<cmd>:set guifont=+<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "<C-ScrollWheelDown>", "<cmd>:set guifont=-<CR>", { noremap = true, silent = true })
end

if vim.g.nvui then
  -- Configure nvui here
  vim.cmd([[NvuiCmdFontFamily FiraCode Nerd Font]])
  vim.cmd([[set linespace=1]])
  if "stefan" == vim.env.USER then
    vim.cmd([[set guifont=FiraCode\ Nerd\ Font:h16]])
  else
    vim.cmd([[set guifont=FiraCode\ Nerd\ Font:h14]])
  end
  vim.cmd([[NvuiPopupMenuDefaultIconFg white]])
  vim.cmd([[NvuiCmdBg #1e2125]])
  vim.cmd([[NvuiCmdFg #abb2bf]])
  vim.cmd([[NvuiCmdBigFontScaleFactor 1.0]])
  vim.cmd([[NvuiCmdPadding 10]])
  vim.cmd([[NvuiCmdCenterXPos 0.5]])
  vim.cmd([[NvuiCmdTopPos 0.0]])
  vim.cmd([[NvuiCmdFontSize 20.0]])
  vim.cmd([[NvuiCmdBorderWidth 5]])
  vim.cmd([[NvuiPopupMenuIconFg variable #56b6c2]])
  vim.cmd([[NvuiPopupMenuIconFg function #c678dd]])
  vim.cmd([[NvuiPopupMenuIconFg method #c678dd]])
  vim.cmd([[NvuiPopupMenuIconFg field #d19a66]])
  vim.cmd([[NvuiPopupMenuIconFg property #d19a66]])
  vim.cmd([[NvuiPopupMenuIconFg module white]])
  vim.cmd([[NvuiPopupMenuIconFg struct #e5c07b]])
  vim.cmd([[NvuiCaretExtendTop 15]])
  vim.cmd([[NvuiCaretExtendBottom 8]])
  vim.cmd([[NvuiTitlebarFontSize 12]])
  vim.cmd([[NvuiTitlebarFontFamily Arial]])
  vim.cmd([[NvuiCursorAnimationDuration 0.1]])
  -- vim.cmd [[NvuiToggleFrameless]]
  vim.cmd([[NvuiOpacity 0.99]])
end

if vim.g.fvim_loaded then
  if "stefan" == vim.env.USER then
    vim.cmd([[set guifont=FiraCode\ Nerd\ Font:h18]])
  else
    vim.cmd([[set guifont=FiraCode\ Nerd\ Font:h14]])
  end

  -- Toggle between normal and fullscreen
  -- vim.cmd [[FVimToggleFullScreen]]

  -- Cursor tweaks
  vim.cmd([[FVimCursorSmoothMove v:true]])
  vim.cmd([[FVimCursorSmoothBlink v:true]])
  -- Background composition
  -- vim.cmd [[FVimBackgroundComposition 'acrylic']]   -- 'none', 'transparent', 'blur' or 'acrylic'
  -- vim.cmd [[FVimBackgroundOpacity 0.85]]            -- value between 0 and 1, default bg opacity.
  -- vim.cmd [[FVimBackgroundAltOpacity 0.85]]         -- value between 0 and 1, non-default bg opacity.
  -- vim.cmd [[FVimBackgroundImage 'C:/foobar.png']]   -- background image
  -- vim.cmd [[FVimBackgroundImageVAlign 'center']]    -- vertial position, 'top', 'center' or 'bottom'
  -- vim.cmd [[FVimBackgroundImageHAlign 'center']]    -- horizontal position, 'left', 'center' or 'right'
  -- vim.cmd [[FVimBackgroundImageStretch 'fill']]     -- 'none', 'fill', 'uniform', 'uniformfill'
  -- vim.cmd [[FVimBackgroundImageOpacity 0.85]]       -- value between 0 and 1, bg image opacity
  -- Title bar tweaks
  -- vim.cmd [[FVimCustomTitleBar v:true ]]
  -- Debug UI overlay
  -- vim.cmd [[FVimDrawFPS v:true]]

  -- Font weight tuning, possible valuaes are 100..900
  vim.cmd([[FVimFontNormalWeight 400]])
  vim.cmd([[FVimFontBoldWeight 700]])
  -- UI options (all default to v:false)
  vim.cmd([[FVimUIPopupMenu v:true]])
  vim.cmd([[FVimUIWildMenu v:false]])
  -- Font tweaks
  vim.cmd([[FVimFontAntialias v:true]])
  vim.cmd([[FVimFontAutohint v:true]])
  vim.cmd([[FVimFontHintLevel 'full']])
  vim.cmd([[FVimFontLigature v:true]])
  vim.cmd([[FVimFontLineHeight '+1.0']])
  vim.cmd([[FVimFontSubpixel v:true]])
  vim.cmd([[FVimFontNoBuiltinSymbols v:true]])
  -- Try to snap the fonts to the pixels, reduces blur
  -- in some situations (e.g. 100% DPI).
  vim.cmd([[FVimFontAutoSnap v:true]])

  -- Keyboard mapping options
  vim.cmd([[FVimKeyDisableShiftSpace v:true]]) -- disable unsupported sequence <S-Space>
  vim.cmd([[FVimKeyAutoIme v:true]]) -- Automatic input method engagement in Insert mode
  vim.cmd([[FVimKeyAltGr v:true]]) -- Recognize AltGr. Side effect is that <C-A-Key> is then impossible

  --   Default options (workspace-agnostic)
  vim.cmd([[FVimDefaultWindowWidth 1600]]) -- Default window size in a new workspace
  vim.cmd([[FVimDefaultWindowHeight 900]])

  -- Detach from a remote session without killing the server
  -- If this command is executed on a standalone instance,
  -- the embedded process will be terminated anyway.
  -- vim.cmd [[FVimDetach]]

  vim.cmd([[FVimKeyAltGr v:true]])
  -- Ctrl-ScrollWheel for zooming in/out
  -- nnoremap <silent> <C-ScrollWheelUp> :set guifont=+<CR>
  -- nnoremap <silent> <C-ScrollWheelDown> :set guifont=-<CR>
  -- nnoremap <A-CR> :FVimToggleFullScreen<CR>
end
