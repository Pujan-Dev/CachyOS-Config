-- ============================================================
-- AUTOCOMMANDS (non-plugin)
-- ============================================================

local augroup = function(name) return vim.api.nvim_create_augroup('user-' .. name, { clear = true }) end

-- Flash yanked region
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup 'yank-highlight',
  callback = function() vim.hl.on_yank() end,
})

-- Close ephemeral windows with q
vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'close-with-q',
  pattern = {
    'help', 'lspinfo', 'man', 'notify', 'qf',
    'startuptime', 'checkhealth', 'tsplayground',
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = ev.buf, silent = true })
  end,
})

-- Re-equalise splits after terminal resize
vim.api.nvim_create_autocmd('VimResized', {
  group = augroup 'resize-splits',
  callback = function() vim.cmd 'tabdo wincmd =' end,
})

-- Strip trailing whitespace on save (skips binary and diff buffers)
vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup 'strip-trailing-ws',
  callback = function()
    if vim.bo.binary or vim.bo.filetype == 'diff' then return end
    local view = vim.fn.winsaveview()
    vim.cmd [[keeppatterns %s/\s\+$//e]]
    vim.fn.winrestview(view)
  end,
})
