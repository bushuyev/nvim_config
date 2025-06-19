-- ~/.config/nvim/lua/plugins/nvim-neotest.lua
return {

  -----------------------------------------------------------------------------
  --  Neotest core + all adapters
  -----------------------------------------------------------------------------
  {
    "nvim-neotest/neotest",

    -- Everything this file depends on
    dependencies = {
      -------------------------------------------------------------------------
      -- Mason-nvim-DAP first, so Mason’s DAP registry is ready (codelldb)
      -------------------------------------------------------------------------
      { "jay-babu/mason-nvim-dap.nvim", opts = { ensure_installed = { "codelldb" } } },

      -------------------------------------------------------------------------
      -- Adapters -------------------------------------------------------------
      -------------------------------------------------------------------------
      "rouge8/neotest-rust",          -- Rust  (uses cargo-nextest ≥ 0.9.6x)
      "alfaix/neotest-gtest",         -- C / C++ (Google-Test)
      "nvim-neotest/neotest-python",  -- Python (pytest)

      -------------------------------------------------------------------------
      -- Core libs ------------------------------------------------------------
      -------------------------------------------------------------------------
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
    },

    -- Options that Neotest will receive
    opts = {
      -------------------------------------------------------------------------
      -- 1.  Only Python goes here directly.  Rust & GTest are injected later.
      -------------------------------------------------------------------------
      adapters = {
        ["neotest-python"] = {
          runner = "pytest",
          python = "/usr/bin/python3",
        },
      },

      -------------------------------------------------------------------------
      -- 2.  UI / behaviour
      -------------------------------------------------------------------------
      status     = { virtual_text = true },
      output     = { open_on_run  = true  },

      -- We still want Overseer, but only for GTest (see strategies below)
      consumers  = { overseer = require("neotest.consumers.overseer") },

      -- Per-adapter strategy map.
      strategies = {
        ["neotest-gtest"] = "overseer",   -- build & run through Overseer
        -- everything else (Rust, Py, …) falls back to "integrated"
      },
    },

    ---------------------------------------------------------------------------
    -- 3. Runtime config
    ---------------------------------------------------------------------------
    config = function(_, opts)
      -------------------------------------------------------------------------
      -- 3-A  Rust adapter (insert at runtime so Mason is already initialised)
      -------------------------------------------------------------------------
      	local rust = require("neotest-rust")
	rust.args        = { "--nocapture" }   -- extra flags (optional)
	rust.dap_adapter = "codelldb"          -- reuse your DAP config
	table.insert(opts.adapters, rust)

      -------------------------------------------------------------------------
      -- 3-B  GTest adapter with *real* build dir and build command
      -------------------------------------------------------------------------
      local gtest = require("neotest-gtest")   -- ← returns a plain table

       -- configure it in-place
  	gtest.build_dir     = "build/tests"
  	gtest.build_command = { "cmake", "--build", "build", "--parallel" }
  	gtest.filter_dir    = function(name, _)  -- ignore Rust’s target dir
           return name ~= "target"
        end

  	table.insert(opts.adapters, gtest)       -- register the adapter

      -------------------------------------------------------------------------
      -- 3-C  Compact virtual-text formatter  (your original code)
      -------------------------------------------------------------------------
      local ns = vim.api.nvim_create_namespace("neotest")
      vim.diagnostic.config({
        virtual_text = {
          format = function(d)
            return d.message:gsub("[\n\t]", " "):gsub("%s+", " "):gsub("^%s+", "")
          end,
        },
      }, ns)

      -------------------------------------------------------------------------
      -- 3-D  Trouble auto-refresh (kept unchanged)
      -------------------------------------------------------------------------
      if require("lazyvim.util").has("trouble.nvim") then
        opts.consumers.trouble = function(client)
          client.listeners.results = function(adapter_id, results, partial)
            if partial then return end
            local tree   = assert(client:get_position(nil, { adapter = adapter_id }))
            local failed = 0
            for pos_id, res in pairs(results) do
              if res.status == "failed" and tree:get_key(pos_id) then failed = failed + 1 end
            end
            vim.schedule(function()
              local trouble = require("trouble")
              if trouble.is_open() then
                trouble.refresh()
                if failed == 0 then trouble.close() end
              end
            end)
          end
        end
      end

      -------------------------------------------------------------------------
      -- 3-E  Fire it up
      -------------------------------------------------------------------------
      require("neotest").setup(opts)
    end,
  },

  -----------------------------------------------------------------------------
  --  GTest adapter lazy-loaded by filetype (extra safety)
  -----------------------------------------------------------------------------
  { "alfaix/neotest-gtest", ft = { "c", "cpp", "cc", "cxx", "hpp", "h" } },
}

