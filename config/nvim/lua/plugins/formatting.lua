-- ============================================================
-- FORMATTING  — conform.nvim  (format-on-save)
-- ============================================================

local gh = function(r) return 'https://github.com/' .. r end

vim.pack.add { gh 'stevearc/conform.nvim' }

require('conform').setup {
  notify_on_error = true,
  notify_no_formatters = false,

  -- Format on save for all supported filetypes
  format_on_save = function(bufnr)
    -- Skip large files
    if vim.api.nvim_buf_line_count(bufnr) > 10000 then return nil end
    return { timeout_ms = 3000, lsp_format = 'fallback' }
  end,

  formatters_by_ft = {
    lua = { 'stylua' },

    -- ruff_format is preferred; fall back to black if ruff not available
    python = { 'ruff_format', 'black', stop_after_first = true },

    -- goimports handles both import organisation and formatting;
    -- gofumpt applies stricter formatting on top.
    go = { 'goimports', 'gofumpt' },

    -- rustfmt via LSP (rust-analyzer) is the canonical formatter.
    -- conform falls back to LSP automatically when no external formatter matches.
    rust = { lsp_format = 'prefer' },

    sh = { 'shfmt' },
    bash = { 'shfmt' },
    json = { 'jq' },
    yaml = { 'prettier' },
    markdown = { 'prettier' },
    toml = { 'taplo' },
  },
}

-- Manual format keymap
vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = '[F]ormat buffer' })
