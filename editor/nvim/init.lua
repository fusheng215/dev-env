-- dev-env Neovim configuration (Lua, requires Neovim >= 0.9)
-- Plugins are managed by lazy.nvim (auto-installed on first launch).
-- Team formatting is enforced by the repo-root .editorconfig via editorconfig-vim.

require('config.lazy')   -- bootstrap lazy.nvim
require('config.options')
require('config.keymaps')

require('lazy').setup('plugins', {
  checker = { enabled = true },
  install = { colorscheme = { 'tokyonight' } },
  performance = { rtp = { disabled_plugins = { 'netrw' } } },
})

vim.cmd('colorscheme tokyonight')
