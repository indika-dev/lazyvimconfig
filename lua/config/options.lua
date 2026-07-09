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
  vim.g.neovide_refresh_rate_idle = 5
  vim.g.neovide_refresh_rate = 60
  vim.g.neovide_scroll_animation_length = 0.75
end

vim.g.kitty_navigator_no_mappings = 1

vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- vim.opt.foldlevelstart = 0

vim.opt.spelllang = "en_us"
vim.opt.spell = true

vim.g.pi = {
  cmd = vim.env.HOME .. "/.nvm/versions/node/v24.15.0/bin/pi",
  standard_llm = { provider = "llama-cpp", model = "ornith-1.0-9b-Q4_K_M", context_length = 65536 },
  local_llms = {
    gemma4_26b = { provider = "llama-cpp", model = "gemma-4-26B-A4B-it-MXFP4_MOE", context_length = 65536 },
    qwen36_35B = { provider = "llama-cpp", model = "Qwen3.6-35B-A3B-MXFP4_MOE", context_length = 65536 },
    qwen35_14B = {
      provider = "llama-cpp",
      model = "Qwen3.5-14B-A3B-Claude-Opus-Reasoning-Distilled-4.6-MXFP4_MOE",
      context_length = 65536,
    },
    gemma4_12b = { provider = "llama-cpp", model = "gemma-4-12b-it-qat-q4_0", context_length = 65536 },
    qwen35_9B = { provider = "llama-cpp", model = "Qwen3.5-9B-Q4_K_M", context_length = 65536 },
    qwen35_8B = { provider = "llama-cpp", model = "Qwen3-8B-UD-Q4_K_XL", context_length = 65536 },
    qwythos35_9b = {
      provider = "llama-cpp",
      model = "Qwythos-9B-Claude-Mythos-5-1M-MTP-Q4_K_M",
      context_length = 65536,
    },
    ornith10_9b = { provider = "llama-cpp", model = "ornith-1.0-9b-Q4_K_M", context_length = 65536 },
    falconh1r_7b = { provider = "llama-cpp", model = "Falcon-H1R-7B-UD-Q4_K_XL", context_length = 65536 },
  },
}
