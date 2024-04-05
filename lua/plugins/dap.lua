local dap = require("dap")
dap.configurations.java = {
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo pull Listenverarbeitung on test-init",
    args = "-r /home/maassens/workspace/architecture-management/test-init pull Listenverarbeitung",
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo-cli",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo generate-catalogue 'Listenverarbeitung' on test-init",
    args = '-t -r /home/maassens/workspace/architecture-management/test-init generate-catalogue "Listenverarbeitung"',
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo-cli",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo init on test-init",
    args = "-r /home/maassens/workspace/architecture-management/test-init init",
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo-cli",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo status on test-init",
    args = "-r /home/maassens/workspace/architecture-management/test-init status",
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo add on test-init",
    args = '-r /home/maassens/workspace/architecture-management/test-init add "Business Adapter BI"',
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo commit on test-init",
    args = '-r /home/maassens/workspace/architecture-management/test-init commit "commit to debug"',
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo push on test-init",
    args = "-t -r /home/maassens/workspace/architecture-management/test-init push",
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo sync on test-init",
    args = '-r /home/maassens/workspace/architecture-management/test-init -t sync "Creditreform Customer Management"',
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo-cli",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "attach",
    hostName = "127.0.0.1",
    port = 8000,
    name = "Debug remote on port 8000",
    console = "integratedTerminal",
  },
  -- {
  --   type = "java",
  --   request = "attach",
  --   name = "Attach to CrateDB",
  --   hostName = "127.0.0.1",
  --   port = 5005,
  --   projectName = "app",
  -- },
  --   host = function()
  --     local value = vim.fn.input "Host [127.0.0.1]: "
  --     if value ~= "" then
  --       return value
  --     end
  --     return "127.0.0.1"
  --   end,
  --   port = function()
  --     local val = tonumber(vim.fn.input "Port: ")
  --     assert(val, "Please provide a port number")
  --     return val
  --   end,
  -- },
}

return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    keys = {
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "Step Out",
      },
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
    },
  },
}
