-- ============================================================
-- TERMINAL  — toggleterm.nvim
-- Fully lazy: setup runs on first keypress.
-- ============================================================

local gh = function(r) return 'https://github.com/' .. r end

vim.pack.add { gh 'akinsho/toggleterm.nvim' }

local _loaded = false
local function setup()
  if _loaded then return end
  _loaded = true
  require('toggleterm').setup {
    size = function(term)
      if term.direction == 'horizontal' then return 15
      elseif term.direction == 'vertical' then return math.floor(vim.o.columns * 0.4)
      end
    end,
    hide_numbers = true,
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    persist_mode = true,
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
      border = 'curved',
      winblend = 3,
      highlights = { border = 'Normal', background = 'Normal' },
    },
    winbar = { enabled = false },
  }
end

-- ── Keymaps ──────────────────────────────────────────────────
vim.keymap.set('n', '<leader>tt', function()
  setup()
  require('toggleterm').toggle(1, nil, nil, 'float')
end, { desc = '[T]erminal [F]loating' })

vim.keymap.set('n', '<leader>th', function()
  setup()
  require('toggleterm').toggle(2, 15, nil, 'horizontal')
end, { desc = '[T]erminal [H]orizontal' })

vim.keymap.set('n', '<leader>tv', function()
  setup()
  require('toggleterm').toggle(3, nil, nil, 'vertical')
end, { desc = '[T]erminal [V]ertical' })

-- Exit terminal insert mode with Esc
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = 'term://*toggleterm#*',
  callback = function(ev)
    vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { buffer = ev.buf, silent = true })
    vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h', { buffer = ev.buf, silent = true })
    vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j', { buffer = ev.buf, silent = true })
    vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k', { buffer = ev.buf, silent = true })
    vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l', { buffer = ev.buf, silent = true })
  end,
})
