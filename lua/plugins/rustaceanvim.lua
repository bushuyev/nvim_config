return {
  {
    "mrcjkb/rustaceanvim",
    version = "^4", -- Recommended
    ft = { "rust" },
    lazy = false,

    init = function()
      vim.g.rustaceanvim = {
        server = {
          cmd = function()
            local mason_registry = require('mason-registry')
            local ra_binary = mason_registry.is_installed('rust-analyzer')
              -- This may need to be tweaked, depending on the operating system.
              and mason_registry.get_package('rust-analyzer'):get_install_path() .. "/rust-analyzer"
              or "rust-analyzer"
            return { ra_binary } -- You can add args to the list, such as '--log-file'
          end,
        },
      }
    end
  },
 -- {
 --   'neovim/nvim-lspconfig',
 --   opts = {
 --     setup = {
 --       rust_analyzer = function()
 --         return true 
 --       end,
 --     },
 --   },
 -- }
}
