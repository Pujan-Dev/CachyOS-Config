-- ============================================================
-- LINTING  — nvim-lint
-- LSP already provides most diagnostics; nvim-lint adds extra
-- linters (ruff for Python, golangci-lint for Go).
-- ============================================================

local gh = function(r) return 'https://github.com/' .. r end

vim.pack.add { gh 'mfussenegger/nvim-lint' }

local lint = require 'lint'

lint.linters_by_ft = {
  python = { 'ruff' },
  -- golangcilint is nvim-lint's name for golangci-lint
  go = { 'golangcilint' },
}

-- Run linters after write or on buffer enter (throttled by modifiable check)
local lint_augroup = vim.api.nvim_create_augroup('user-lint', { clear = true })
vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter', 'InsertLeave' }, {
  group = lint_augroup,
  callback = function()
    if vim.bo.modifiable and not vim.bo.readonly then lint.try_lint() end
  end,
})
