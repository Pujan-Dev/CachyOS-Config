-- ============================================================
-- NEOVIM OPTIONS
-- ============================================================

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Mouse
vim.o.mouse = 'a'

-- Statusline shows mode already
vim.o.showmode = false

-- Clipboard: deferred because it can add ~10ms on some systems
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Indentation
vim.o.breakindent = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartindent = true

-- Persistent undo
vim.o.undofile = true

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Gutter
vim.o.signcolumn = 'yes'

-- Faster CursorHold (affects gitsigns, LSP highlights)
vim.o.updatetime = 200

-- Key sequence timeout
vim.o.timeoutlen = 300

-- Splits
vim.o.splitright = true
vim.o.splitbelow = true
vim.opt.fillchars = { vert = ' ', vertleft = ' ', vertright = ' ', verthoriz = ' ', horiz = ' ' }

-- Whitespace characters
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Live substitution preview
vim.o.inccommand = 'split'

-- Cursor line highlight
vim.o.cursorline = true

-- Keep context lines around cursor
vim.o.scrolloff = 10

-- No line wrapping
vim.o.wrap = false

-- Ask to save instead of failing
vim.o.confirm = true

-- Completion popup height
vim.o.pumheight = 10

-- Fold
vim.o.foldlevel = 99

-- Diagnostics config (here rather than in lsp.lua because it is a core vim setting)
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = { prefix = '■' },
  virtual_lines = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '✘',
      [vim.diagnostic.severity.WARN] = '▲',
      [vim.diagnostic.severity.HINT] = '⚑',
      [vim.diagnostic.severity.INFO] = '»',
    },
  },
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float { bufnr = bufnr, scope = 'cursor', focus = false }
    end,
  },
}
