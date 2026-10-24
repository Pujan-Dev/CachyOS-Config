-- ============================================================
-- GO  — language-specific settings and keymaps
--
-- The gopls LSP server is configured in plugins/lsp.lua.
-- goimports + gofumpt formatting is configured in plugins/formatting.lua.
-- golangci-lint is configured in plugins/linting.lua.
--
-- This file holds Go-specific:
--   • buffer-local options (tabs, not spaces)
--   • autocmds (organise imports on save via LSP)
--   • convenience keymaps
-- ============================================================

local augroup = vim.api.nvim_create_augroup('user-go', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'go',
  callback = function(ev)
    local buf = ev.buf

    -- Go canonical style: hard tabs, width 4
    vim.bo[buf].expandtab  = false
    vim.bo[buf].tabstop    = 4
    vim.bo[buf].shiftwidth = 4
    vim.bo[buf].softtabstop = 4

    -- ── Go-specific keymaps ─────────────────────────────────
    local map = function(key, cmd, desc)
      vim.keymap.set('n', key, cmd, { buffer = buf, desc = 'Go: ' .. desc })
    end

    -- Quickly run current file / package
    map('<leader>gr', '<cmd>!go run %<CR>',       '[G]o [R]un file')
    map('<leader>gt', '<cmd>!go test ./...<CR>',  '[G]o [T]est all')
    map('<leader>gb', '<cmd>!go build ./...<CR>', '[G]o [B]uild')
    map('<leader>gv', '<cmd>!go vet ./...<CR>',   '[G]o [V]et')

    -- Organise imports via gopls code action (supplements goimports in conform)
    map('<leader>go', function()
      vim.lsp.buf.code_action {
        apply = true,
        context = {
          only = { 'source.organizeImports' },
          diagnostics = {},
        },
      }
    end, '[G]o [O]rganise imports')
  end,
})

-- On save, organise imports via gopls before conform runs
vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup,
  pattern = '*.go',
  callback = function()
    -- Only run if gopls is attached
    local clients = vim.lsp.get_clients { bufnr = 0, name = 'gopls' }
    if #clients == 0 then return end
    vim.lsp.buf.code_action {
      apply = true,
      context = { only = { 'source.organizeImports' }, diagnostics = {} },
    }
  end,
})
