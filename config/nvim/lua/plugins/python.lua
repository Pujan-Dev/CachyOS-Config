-- ============================================================
-- PYTHON  — language-specific settings and keymaps
--
-- The pyright LSP server is configured in plugins/lsp.lua.
-- ruff + black formatting is configured in plugins/formatting.lua.
-- ruff linting is configured in plugins/linting.lua.
--
-- This file holds Python-specific:
--   • buffer-local options (4-space indent, PEP 8)
--   • virtual-environment awareness
--   • convenience keymaps
-- ============================================================

local augroup = vim.api.nvim_create_augroup('user-python', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'python',
  callback = function(ev)
    local buf = ev.buf

    -- PEP 8: 4 spaces
    vim.bo[buf].expandtab   = true
    vim.bo[buf].tabstop     = 4
    vim.bo[buf].shiftwidth  = 4
    vim.bo[buf].softtabstop = 4

    -- PEP 8 line-length hint
    vim.wo.colorcolumn = '88'

    local map = function(key, cmd, desc)
      vim.keymap.set('n', key, cmd, { buffer = buf, desc = 'Python: ' .. desc })
    end

    -- Run current file
    map('<leader>pr', '<cmd>!python3 %<CR>', '[P]ython [R]un file')
    -- pytest
    map('<leader>pt', '<cmd>!python3 -m pytest %<CR>', '[P]ython [T]est file')
    -- ruff check + fix
    map('<leader>pl', '<cmd>!ruff check --fix %<CR>', '[P]ython [L]int (ruff fix)')
    -- Type check with pyright
    map('<leader>py', '<cmd>!pyright %<CR>', '[P]y[r]ight check')

    -- Notify pyright when the active virtualenv changes
    -- (works automatically when pyrightconfig.json / .python-version present)
  end,
})

-- Remove the colorcolumn when leaving Python files
vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = '*',
  callback = function()
    if vim.bo.filetype ~= 'python' then vim.wo.colorcolumn = '' end
  end,
})
