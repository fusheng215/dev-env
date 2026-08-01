local opts = { noremap = true, silent = true }
local keymap = vim.keymap.set

-- Files / fuzzy find (telescope)
keymap('n', '<C-p>', '<cmd>Telescope find_files<cr>', opts)
keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', opts)
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', opts)
keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', opts)
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', opts)

-- File tree (neo-tree)
keymap('n', '<leader>e', '<cmd>Neotree toggle<cr>', opts)

-- Git (gitsigns)
keymap('n', '<leader>gg', '<cmd>Gitsigns<cr>', opts)

-- Format (conform)
keymap('n', '<leader>sf', function() require('conform').format({ async = true }) end, opts)

-- Diagnostics
keymap('n', '<leader>df', vim.diagnostic.open_float, opts)
keymap('n', '[d', vim.diagnostic.goto_prev, opts)
keymap('n', ']d', vim.diagnostic.goto_next, opts)

-- Debugging (DAP)
keymap('n', '<leader>db', '<cmd>lua require("dap").toggle_breakpoint()<cr>', opts)
keymap('n', '<leader>dc', '<cmd>lua require("dap").continue()<cr>', opts)

-- Window navigation
keymap('n', '<C-h>', '<C-w>h', opts)
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)
keymap('n', '<C-l>', '<C-w>l', opts)

-- Clear search highlight
keymap('n', '<Esc>', '<cmd>nohlsearch<cr>', opts)
