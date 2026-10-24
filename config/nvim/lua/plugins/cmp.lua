-- ============================================================
-- AUTOCOMPLETE  — blink.cmp + LuaSnip + friendly-snippets
-- ============================================================

local gh = function(r) return 'https://github.com/' .. r end

-- ── Snippet engine ───────────────────────────────────────────
vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
require('luasnip').setup {
  history = true,
  delete_check_events = 'TextChanged',
}

-- Pre-built snippet library (VSCode format)
vim.pack.add { gh 'rafamadriz/friendly-snippets' }
require('luasnip.loaders.from_vscode').lazy_load()

-- ── Completion engine ─────────────────────────────────────────
vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
require('blink.cmp').setup {
  keymap = {
    preset = 'default',
    -- Tab / S-Tab: move through menu OR jump through snippet placeholders
    ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
    -- Explicitly accept with Enter
    ['<CR>'] = { 'accept', 'fallback' },
    -- Dismiss menu
    ['<C-e>'] = { 'hide' },
    -- Force open menu
    ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    -- Navigate docs
    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
  },

  appearance = {
    nerd_font_variant = 'mono',
  },

  completion = {
    -- Show ghost text inline (VS Code style)
    ghost_text = { enabled = false },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 300,
      window = { border = 'rounded' },
    },
    menu = {
      border = 'rounded',
      draw = {
        columns = {
          { 'label', 'label_description', gap = 1 },
          { 'kind_icon', 'kind', gap = 1 },
        },
      },
    },
  },

  sources = {
    -- LSP → snippets → path → buffer (ordered by priority)
    default = { 'lsp', 'snippets', 'path', 'buffer' },
    providers = {
      buffer = {
        -- Only scan open buffers, not the whole project
        opts = { get_bufnrs = function() return vim.api.nvim_list_bufs() end },
      },
    },
  },

  snippets = { preset = 'luasnip' },

  -- Pure Lua fuzzy matcher (no pre-built binary required)
  fuzzy = { implementation = 'lua' },

  -- Signature help popup while typing arguments
  signature = {
    enabled = true,
    window = { border = 'rounded' },
  },
}
