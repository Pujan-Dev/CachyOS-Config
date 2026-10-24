-- ============================================================
-- GIT  — gitsigns · vim-fugitive
-- ============================================================

local gh = function(r) return 'https://github.com/' .. r end

-- ── Gitsigns ─────────────────────────────────────────────────
vim.pack.add { gh 'lewis6991/gitsigns.nvim' }

require('gitsigns').setup {
  signs = {
    add          = { text = '│' },
    change       = { text = '│' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 0,
    virt_text_pos = 'eol',
  },
  on_attach = function(bufnr)
    local gs = require 'gitsigns'

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- ── Navigation ─────────────────────────────────────────
    map('n', ']c', function()
      if vim.wo.diff then vim.cmd.normal { ']c', bang = true }
      else gs.nav_hunk 'next' end
    end, { desc = 'Next git change' })

    map('n', '[c', function()
      if vim.wo.diff then vim.cmd.normal { '[c', bang = true }
      else gs.nav_hunk 'prev' end
    end, { desc = 'Prev git change' })

    -- ── Hunk operations ────────────────────────────────────
    map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = '[H]unk [S]tage' })
    map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = '[H]unk [R]eset' })
    map('n', '<leader>hs', gs.stage_hunk,     { desc = '[H]unk [S]tage' })
    map('n', '<leader>hr', gs.reset_hunk,     { desc = '[H]unk [R]eset' })
    map('n', '<leader>hS', gs.stage_buffer,   { desc = '[H]unk stage [B]uffer' })
    map('n', '<leader>hR', gs.reset_buffer,   { desc = '[H]unk reset [B]uffer' })
    map('n', '<leader>hu', gs.undo_stage_hunk, { desc = '[H]unk [U]nstage' })
    map('n', '<leader>hp', gs.preview_hunk,   { desc = '[H]unk [P]review' })
    map('n', '<leader>hi', gs.preview_hunk_inline, { desc = '[H]unk preview [I]nline' })

    -- ── Blame ──────────────────────────────────────────────
    map('n', '<leader>gb', function() gs.blame_line { full = true } end, { desc = '[G]it [B]lame line' })
    map('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = 'Git [B]lame line' })
    map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = '[T]oggle inline [B]lame' })

    -- ── Diff ───────────────────────────────────────────────
    map('n', '<leader>hd', gs.diffthis,                          { desc = '[H]unk [D]iff index' })
    map('n', '<leader>hD', function() gs.diffthis '@' end,       { desc = '[H]unk [D]iff last commit' })
    map('n', '<leader>tw', gs.toggle_word_diff,                  { desc = '[T]oggle [W]ord diff' })

    -- ── Quickfix ───────────────────────────────────────────
    map('n', '<leader>hq', gs.setqflist, { desc = '[H]unk [Q]uickfix (file)' })
    map('n', '<leader>hQ', function() gs.setqflist 'all' end, { desc = '[H]unk [Q]uickfix (repo)' })

    -- ── Text object ────────────────────────────────────────
    map({ 'o', 'x' }, 'ih', gs.select_hunk, { desc = 'Inside hunk' })
  end,
}

-- ── Fugitive ─────────────────────────────────────────────────
vim.pack.add { gh 'tpope/vim-fugitive' }

vim.keymap.set('n', '<leader>gs', '<cmd>Git<CR>',           { desc = '[G]it [S]tatus (fugitive)' })
vim.keymap.set('n', '<leader>gd', '<cmd>Gvdiffsplit<CR>',   { desc = '[G]it [D]iff split' })
vim.keymap.set('n', '<leader>gc', '<cmd>Git commit<CR>',    { desc = '[G]it [C]ommit' })
vim.keymap.set('n', '<leader>gp', '<cmd>Git push<CR>',      { desc = '[G]it [P]ush' })
vim.keymap.set('n', '<leader>gl', '<cmd>Git log --oneline<CR>', { desc = '[G]it [L]og' })
