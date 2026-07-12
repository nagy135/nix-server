local dap = require("dap")
local dap_utils = require("dap.utils")

require("dap-vscode-js").setup({
  debugger_cmd = { "js-debug", "0" },
  adapters = { "pwa-node", "node-terminal", "pwa-chrome" },
})

local js_languages = { "javascript", "typescript", "javascriptreact", "typescriptreact" }

for _, language in ipairs(js_languages) do
  dap.configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch current file",
      program = "${file}",
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      protocol = "inspector",
      skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
      console = "integratedTerminal",
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Next.js: npm run dev",
      runtimeExecutable = "node",
      runtimeArgs = { "./node_modules/next/dist/bin/next", "dev" },
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      protocol = "inspector",
      console = "integratedTerminal",
      skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to running Next.js",
      cwd = "${workspaceFolder}",
      processId = dap_utils.pick_process,
      sourceMaps = true,
      protocol = "inspector",
      skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
    },
    {
      type = "pwa-chrome",
      request = "launch",
      name = "Launch Chrome against localhost:3000",
      url = "http://localhost:3000",
      webRoot = "${workspaceFolder}",
      sourceMaps = true,
      protocol = "inspector",
    },
  }
end
