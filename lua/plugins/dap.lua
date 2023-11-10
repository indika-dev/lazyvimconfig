local dap = require("dap")
dap.configurations.java = {
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo init on special repo",
    args = "-r /home/maassens/workspace/architecture-management/test-init init",
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo-cli",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo pull 'SSO User Management' on special repo",
    args = '-r /home/maassens/workspace/architecture-management/test-init pull "SSO User Management"',
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo-cli",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo sync with init",
    args = '-r /home/maassens/workspace/architecture-management/test-repo -t sync \
      --init \
      -c /home/maassens/workspace/architecture-management/ts01_single.toml \
      -c /home/maassens/workspace/architecture-management/listeItSysteme.html \
      "TestSystem 01"',
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo-cli",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo sync Business Adapter CTA",
    args = '-r /home/maassens/workspace/architecture-management/test-repo -t sync \
      "Business Adapter CTA"',
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo-cli",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo pull TestSystem 01",
    args = '-r /home/maassens/workspace/architecture-management/test-repo -t pull "TestSystem 01"',
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo-cli",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo pull CrefoTEAM Vertrieb",
    args = '-r /home/maassens/workspace/architecture-management/test-repo -t pull "CrefoTEAM Vertrieb"',
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo-cli",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo merge TestSystem 01",
    args = '-r /home/maassens/workspace/architecture-management/test-repo -t merge "TestSystem 01"',
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo-cli",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo add TestSystem 01",
    args = '-r /home/maassens/workspace/architecture-management/test-repo -t add "TestSystem 01"',
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo-cli",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo commit",
    args = '-r /home/maassens/workspace/architecture-management/test-repo -t commit "TestSystem 01"',
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo-cli",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo push",
    args = "-r /home/maassens/workspace/architecture-management/test-repo -t push",
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo-cli",
    console = "integratedTerminal",
  },
  {
    type = "java",
    request = "launch",
    name = "Debug Shoo status",
    args = "-r /home/maassens/workspace/architecture-management/test-repo -t status",
    vmargs = "-Xms2G -Xmx2G",
    mainClass = "de.creditreform.architecture.management.shoo.ui.ShooCli",
    projectName = "shoo-cli",
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
return {}
