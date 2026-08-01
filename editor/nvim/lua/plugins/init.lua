-- Plugin specifications for lazy.nvim, grouped by purpose.
-- Run `:Lazy` to manage, `:Lazy update` to upgrade.
return {
  -- ---------- color scheme ----------
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
  },

  -- ---------- EditorConfig (team formatting contract) ----------
  { 'editorconfig/editorconfig-vim' },

  -- ---------- syntax highlighting ----------
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { 'lua', 'python', 'go', 'rust', 'typescript', 'json', 'yaml', 'bash', 'markdown', 'toml' },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- ---------- LSP (language servers) ----------
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    build = ':MasonUpdate',
    config = true,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'mason.nvim', 'neovim/nvim-lspconfig' },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = { 'gopls', 'rust_analyzer', 'pyright', 'ts_ls', 'lua_ls', 'jsonls', 'yamlls', 'bashls' },
      })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      local lsp = require('lspconfig')
      local on_attach = function(_, bufnr)
        local o = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, o)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, o)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, o)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, o)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, o)
      end
      for _, s in ipairs({ 'gopls', 'rust_analyzer', 'pyright', 'ts_ls', 'lua_ls', 'jsonls', 'yamlls', 'bashls' }) do
        pcall(function()
          lsp[s].setup({ on_attach = on_attach, capabilities = require('cmp_nvim_lsp').default_capabilities() })
        end)
      end
    end,
  },

  -- ---------- completion ----------
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim-lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },

  -- ---------- fuzzy find ----------
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({ defaults = { file_ignore_patterns = { 'node_modules', '.git/', 'target' } } })
      pcall(telescope.load_extension, 'fzf')
    end,
  },

  -- ---------- git ----------
  { 'lewis6991/gitsigns.nvim', event = 'BufReadPre', opts = {} },

  -- ---------- UI ----------
  {
    'nvim-lualine/lualine.nvim',
    event = 'BufEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons', 'MunifTanjim/nui.nvim' },
    cmd = 'Neotree',
  },

  -- ---------- quality of life ----------
  { 'numToStr/Comment.nvim', opts = {} },
  { 'tpope/vim-surround' },
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },
  { 'folke/which-key.nvim', event = 'VeryLazy', opts = {} },
  { 'folke/trouble.nvim', opts = {} },

  -- ---------- formatting / linting ----------
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'black' },
          go = { 'gofmt' },
          rust = { 'rustfmt' },
          javascript = { 'prettier' },
          typescript = { 'prettier' },
          json = { 'prettier' },
          yaml = { 'prettier' },
          markdown = { 'prettier' },
        },
      })
    end,
  },

  -- ---------- debugging (DAP) ----------
  { 'mfussenegger/nvim-dap' },
  { 'rcarriga/nvim-dap-ui', dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' }, opts = {} },
}
