-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--if lvim.builtin.inlay_hints.active then
vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
vim.api.nvim_create_autocmd("LspAttach", {
  pattern = { "*.java", "*.rs", "*.js", "*.ts" },
  group = "LspAttach_inlayhints",
  callback = function(args)
    if not (args.data and args.data.client_id) then
      return
    end

    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local status_lspinlay, lsp_inlayhints = pcall(require, "lsp-inlayhints")
    if status_lspinlay then
      lsp_inlayhints.on_attach(client, bufnr)
    end
  end,
})
-- end
