--https://sharksforarms.dev/posts/neovim-rust/
-- ensure the packer plugin manager is installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end



local packer_bootstrap = ensure_packer()

require("packer").startup(function(use)
  -- Packer can manage itself
  use("wbthomason/packer.nvim")
  -- Collection of common configurations for the Nvim LSP client
  use("neovim/nvim-lspconfig")
  -- Visualize lsp progress
  use({
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup()
    end
  })

  -- Autocompletion framework
  use("hrsh7th/nvim-cmp")
  use({
    -- cmp LSP completion
    "hrsh7th/cmp-nvim-lsp",
    -- cmp Snippet completion
    "hrsh7th/cmp-vsnip",
    -- cmp Path completion
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-cmdline",
    after = { "hrsh7th/nvim-cmp" },
    requires = { "hrsh7th/nvim-cmp" },
  })
  -- See hrsh7th other plugins for more great completion sources!
  -- Snippet engine
  use('hrsh7th/vim-vsnip')
  -- Adds extra functionality over rust analyzer
  use("simrat39/rust-tools.nvim")

  -- Optional
  use("nvim-lua/popup.nvim")
  use("nvim-lua/plenary.nvim")
  --use({"nvim-telescope/telescope.nvim", config = function()
  --   require("extensions.telescope").setup()
  --end })

  -- Some color scheme other then default
  use("arcticicestudio/nord-vim")

  -- fzf
  use({ "junegunn/fzf", run = "./install --bin" })
  use({
     "ibhagwan/fzf-lua",
     requires = {"nvim-tree/nvim-web-devicons" }
  })

  --use ("BurntSushi/ripgrep")
  use ({"BurntSushi/ripgrep",
    config = function()
       --require("telescope.builtin").load_extension("find_files")
       --require("telescope.builtin").load_extension("grep_string")
    end
  })

  use({
     'crusj/bookmarks.nvim',
     branch = 'main',
     requires = { 'kyazdani42/nvim-web-devicons' },
     config = function()
         require("bookmarks").setup()
         --require("telescope").load_extension("bookmarks")
     end
  })

  use ({"nvim-treesitter/nvim-treesitter"})
  use ({"sharkdp/fd"})

  use({
    "klen/nvim-test",
    config = function()
      require('nvim-test').setup()
    end
  })

  use({"rhysd/git-messenger.vim"})
  use({
    "folke/which-key.nvim",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
 })
end)

-- the first run will install packer and our plugins
if packer_bootstrap then
  require("packer").sync()
  return
end



--require('lsp_setup') -- configured through rust_tools
require('bookmarks_setup')
require('nvim-treesitter')
require('rust_analyzer_setup_2')
require('rust_tools_setup')
--require('telescope_setup')
require('fzf_setup')
require('nvim-test_setup')

local wk = require("which-key")

wk.setup()
