return {
  "mfussenegger/nvim-dap",

  -- ← no `opts` key at all, so Lazy will *not* try dap.setup()

  config = function()
    local dap = require("dap")

    dap.adapters.codelldb = {
      type    = "executable",
      command = "/usr/bin/lldb-dap-18",   -- adjust if needed
      name    = "codelldb",
    }

    dap.configurations.cpp = {
      {
        name    = "Launch file",
        type    = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
      },
      {
        name    = "Attach to process",
        type    = "codelldb",
        request = "attach",
        pid     = require("dap.utils").pick_process,
        cwd     = "${workspaceFolder}",
      },
    }
  end,
}
