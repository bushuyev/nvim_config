return {
  "stevearc/overseer.nvim",
  opts = {
    -- extend the built-in alias that neotest uses for its tasks
    component_aliases = {
      default_neotest = {
        -- ❶ our new dependency
        { "dependencies", task_names = {
            -- in-line one-off “shell” task
            { "shell", cmd = "cmake --build build --parallel" },
          } },
        -- ❷ keep the rest of the default behaviour
        "default",
      },
    },
  },
}

-- enable the Overseer extra in LazyVim (once):
-- :LazyExtras editor.overseer
