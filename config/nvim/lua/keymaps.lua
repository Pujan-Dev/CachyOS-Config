-- ============================================================
-- CORE KEYMAPS  (no plugin dependencies)
-- Plugin-specific keymaps live alongside their plugin setup.
-- ============================================================

-- Clear search highlights
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- ── Window navigation ────────────────────────────────────────
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus left' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus right' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus down' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus up' })

-- ── Window splits ────────────────────────────────────────────
vim.keymap.set('n', '<leader>sv', '<cmd>vsplit<CR>', { desc = '[S]plit [V]ertical' })
vim.keymap.set('n', '<leader>sh', '<cmd>split<CR>', { desc = '[S]plit [H]orizontal' })
vim.keymap.set('n', '<leader>se', '<C-w>=', { desc = '[S]plits [E]qualize' })
vim.keymap.set('n', '<leader>sx', '<cmd>close<CR>', { desc = '[S]plit [X] Close' })

-- ── Buffer navigation ────────────────────────────────────────
vim.keymap.set('n', '<S-l>', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-h>', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = '[B]uffer [D]elete' })

-- ── Diagnostics ──────────────────────────────────────────────
vim.keymap.set('n', '[d', function() vim.diagnostic.jump { count = -1 } end, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', function() vim.diagnostic.jump { count = 1 } end, { desc = 'Next diagnostic' })
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = '[D]iagnostic float' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = '[Q]uickfix diagnostics' })

-- ── Terminal ─────────────────────────────────────────────────
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- ── Better defaults ──────────────────────────────────────────
-- Keep cursor centred when searching
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next match (centred)' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Prev match (centred)' })

-- Move selected lines up/down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Keep cursor in place when joining lines
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join line' })

-- Don't yank on paste in visual mode
vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste without yanking' })
