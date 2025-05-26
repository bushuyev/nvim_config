return {
  "stevearc/overseer.nvim",
  opts = {
    component_aliases = {
      default_neotest = {
        {
          "dependencies",
          task_names = {
            { "shell", cmd = "cmake --build build --parallel" },
          },
        },
        "default",
      },
    },
  },
  config = function(_, opts)
    require("overseer").setup(opts)

    require("overseer").register_template({
      name = "CMake Build",
      builder = function()
        return {
          cmd = { "cmake" },
          args = { "--build", "build", "--parallel" },
          name = "CMake Build",
          cwd = vim.fn.getcwd(),
          components = { "default" },
        }
      end,
      condition = {
        filetype = { "cpp", "c", "cuda" },
      },
    })
  end,
}
