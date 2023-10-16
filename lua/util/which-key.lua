local wkstatus_ok, which_key = pcall(require, "which-key")
if wkstatus_ok then
  local nopts = {
    mode = "n",
    prefix = "<leader>",
    buffer = vim.fn.bufnr(),
    silent = true,
    noremap = true,
    nowait = true,
  }

  local vopts = {
    mode = "v",
    prefix = "<leader>",
    buffer = vim.fn.bufnr(),
    silent = true,
    noremap = true,
    nowait = true,
  }

  local mappings = {
    j = {
      name = " Java",
      o = { "<Cmd>lua require'jdtls'.organize_imports()<CR>", "Organize Imports" },
      v = { "<Cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable" },
      c = { "<Cmd>lua require('jdtls').extract_constant()<CR>", "Extract Constant" },
      t = { "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", "Test Method" },
      T = { "<Cmd>lua require'jdtls'.test_class()<CR>", "Test Class" },
      u = { "<Cmd>JdtUpdateConfig<CR>", "Update Config" },
      i = { "<Cmd>JdtCompile incremental<CR>", "Compile incrementaly" },
      f = { "<Cmd>JdtCompile full<CR>", "Compile fully" },
      s = { "<Cmd>lua require'jdtls'.super_implementation()<CR>", "Go to super implementation" },
      r = { "<Cmd>JdtSetRuntime<CR>", "Set runtime" },
    },
  }

  local vmappings = {
    j = {
      name = " Java",
      v = { "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract Variable" },
      c = { "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", "Extract Constant" },
      m = { "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method" },
    },
  }
  which_key.register(mappings, nopts)
  which_key.register(vmappings, vopts)
end
