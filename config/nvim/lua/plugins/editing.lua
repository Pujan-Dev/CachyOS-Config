-- ============================================================
-- EDITING PLUGINS
-- guess-indent · mini.ai · mini.surround · mini.pairs ·
-- Comment.nvim
-- ============================================================

local gh = function(r) return 'https://github.com/' .. r end

-- mini.nvim already added in ui.lua — just setup the modules.

-- ── Auto indentation detection ───────────────────────────────
vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
require('guess-indent').setup {}

-- ── Better text objects (va), yiiq, ci', etc.) ───────────────
require('mini.ai').setup {
  -- Avoid conflicts with Neovim ≥ 0.12 built-in incremental selection
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
}

-- ── Surround (saiw), sd', sr)') ──────────────────────────────
require('mini.surround').setup {
  mappings = {
    add = 'sa',
    delete = 'sd',
    find = 'sf',
    find_left = 'sF',
    highlight = 'sh',
    replace = 'sr',
    update_n_lines = 'sn',
  },
}

-- ── Auto pairs ───────────────────────────────────────────────
require('mini.pairs').setup {
  modes = { insert = true, command = false, terminal = false },
}

-- ── Commenting ───────────────────────────────────────────────
-- Neovim ≥ 0.10 ships `gc` built-in; Comment.nvim extends it
-- with dot-repeat and treesitter-aware contexts.
vim.pack.add { gh 'numToStr/Comment.nvim' }
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function() require('Comment').setup() end,
})
