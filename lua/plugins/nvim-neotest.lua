return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      --"rouge8/neotest-rust",
      "mrcjkb/rustaceanvim",

      "nvim-lua/plenary.nvim",
      "alfaix/neotest-gtest"
    },
    opts = {
      -- Can be a list of adapters like what neotest expects,
      -- or a list of adapter names,
      -- or a table of adapter names, mapped to adapter configs.
      -- The adapter will then be automatically loaded with the config.
      -- adapters = {},
      -- Example for loading neotest-go with a custom config
      adapters = {
        --["neotest-rust"] = {
        --  args = {
        --    "--no-capture",
        --  },
        --  dap_adapter = "codelldb",
        --},
	["neotest-python"] = {
          -- Here you can specify the settings for the adapter, i.e.
          runner = "pytest",
          -- python = ".venv/bin/python",
          python = "/usr/bin/python3",
        },
	["neotest-gtest"] = {
	  is_test_file = function(file)
	   return true;
          end,
	}
      },
      status = { virtual_text = true },
      output = { open_on_run = true },
      quickfix = {
        open = function()
          if require("lazyvim.util").has("trouble.nvim") then
            require("trouble").open({ mode = "quickfix", focus = false })
          else
            vim.cmd("copen")
          end
        end,
      },

     --local dap = require("dap")
     --if not dap.adapters["codelldb"] then
     --  require("dap").adapters["codelldb"] = {
     --    type = "server",
     --    host = "localhost",
     --    port = "${port}",
     --    executable = {
     --      command = "codelldb",
     --      args = {
     --        "--port",
     --        "${port}",
     --      },
     --    },
     --  }
     --end
     --dap.configurations['cpp'] = {
     --  {
     --    type = "codelldb",
     --    request = "launch",
     --    name = "Launch file",
     --    program = function()
     --      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
     --    end,
     --    cwd = "${workspaceFolder}",
     --  },
     --  {
     --    type = "codelldb",
     --    request = "attach",
     --    name = "Attach to process",
     --    pid = require("dap.utils").pick_process,
     --    cwd = "${workspaceFolder}",
     --  },
     --}


    },
    config = function(_, opts)
      local dap = require("dap")
      dap.adapters.codelldb = {
          type = 'executable',
          command = '/usr/bin/lldb-dap-18', -- adjust as needed, must be absolute path
          name = 'codelldb'
      }

     dap.configurations['cpp'] = {
       {
         type = "codelldb",
         request = "launch",
         name = "Launch file",
         program = function()
           return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
         end,
         cwd = "${workspaceFolder}",
       },
       {
         type = "codelldb",
         request = "attach",
         name = "Attach to process",
         pid = require("dap.utils").pick_process,
         cwd = "${workspaceFolder}",
       },
     }



      opts.adapters = opts.adapters or {}
      vim.list_extend(opts.adapters, {
        require('rustaceanvim.neotest'){
       	   args = { "--show-output" },
	},
      })
      local neotest_ns = vim.api.nvim_create_namespace("neotest")
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            -- Replace newline and tab characters with space for more compact diagnostics
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)

      if require("lazyvim.util").has("trouble.nvim") then
        opts.consumers = opts.consumers or {}
        -- Refresh and auto close trouble after running tests
        ---@type neotest.Consumer
        opts.consumers.trouble = function(client)
          client.listeners.results = function(adapter_id, results, partial)
            if partial then
              return
            end
            local tree = assert(client:get_position(nil, { adapter = adapter_id }))

            local failed = 0
            for pos_id, result in pairs(results) do
              if result.status == "failed" and tree:get_key(pos_id) then
                failed = failed + 1
              end
            end
            vim.schedule(function()
              local trouble = require("trouble")
              if trouble.is_open() then
                trouble.refresh()
                if failed == 0 then
                  trouble.close()
                end
              end
            end)
            return {}
          end
        end
      end

      if opts.adapters then
        local adapters = {}
        for name, config in pairs(opts.adapters or {}) do
          if type(name) == "number" then
            if type(config) == "string" then
              config = require(config)
            end
            adapters[#adapters + 1] = config
          elseif config ~= false then
            local adapter = require(name)
            if type(config) == "table" and not vim.tbl_isempty(config) then
              local meta = getmetatable(adapter)
              if adapter.setup then
                adapter.setup(config)
              elseif meta and meta.__call then
                adapter(config)
              else
                error("Adapter " .. name .. " does not support setup")
              end
            end
            adapters[#adapters + 1] = adapter
          end
        end
        opts.adapters = adapters
      end

      require("neotest").setup(opts)
    end,
  -- stylua: ignore
    keys = {
      { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File" },
      { "<leader>tT", function() require("neotest").run.run(vim.loop.cwd()) end, desc = "Run All Test Files" },
      { "<leader>tr", function() require("neotest").run.run() end, desc = "Run Nearest" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop" },
      --- my
      { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run last" },
     },
  },
  {
    "mfussenegger/nvim-dap",
    optional = false,
    dependencies = {
      -- Ensure C/C++ debugger is installed
      "williamboman/mason.nvim",
      optional = false,
      opts = { ensure_installed = { "codelldb" } },
    },
  -- stylua: ignore
    keys = {
      { "<leader>td", function() require("neotest").run.run({strategy = "dap"}) end, desc = "Debug Nearest" },


       { "<leader>d", "", desc = "+debug", mode = {"n", "v"} },
       { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
       { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
       { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
       { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
       { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
       { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
       { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
       { "<leader>dj", function() require("dap").down() end, desc = "Down" },
       { "<leader>dk", function() require("dap").up() end, desc = "Up" },
       { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
       { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
       { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
       { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
       { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
       { "<leader>ds", function() require("dap").session() end, desc = "Session" },
       { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
       { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    },
    --opts = function()
    --end
  },

  --{
   -- "rouge8/neotest-rust",
   --"mrcjkb/rustaceanvim"
  --},
}
