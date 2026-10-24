-- ============================================================
-- FZF-LUA — fast picker for files / grep (replaces the
-- hot Telescope paths; Telescope stays for LSP/help/etc.)
-- ============================================================

local gh = function(r) return 'https://github.com/' .. r end

vim.pack.add { gh 'ibhagwan/fzf-lua' }

local _loaded = false
local function setup()
  if _loaded then return end
  _loaded = true
  require('fzf-lua').setup {
    'hide',
    winopts = { preview = { layout = 'horizontal', horizontal = 'right:55%' } },
    files = {
      fd_opts = '--color=never --type f --hidden '
        .. '--exclude .git --exclude node_modules --exclude target --exclude build --exclude dist',
    },
    grep = {
      rg_opts = '--column --line-number --no-heading --color=always --smart-case --trim '
        .. '--glob=!.git/* --glob=!node_modules/* --glob=!target/* --glob=!build/* --glob=!dist/* --glob=!*.lock --glob=!*.min.js*',
    },
    previewers = { head = { lines = 200 }, cat = { cmd = 'cat' } },
  }
end

local function fz(name)
  return function(...)
    setup()
    require('fzf-lua')[name](...)
  end
end

-- Hot paths — same keys as before, now instant:
vim.keymap.set('n', '<leader>ff', fz 'files', { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fg', fz 'live_grep', { desc = '[F]ind by [G]rep' })
vim.keymap.set('n', '<leader>fb', fz 'buffers', { desc = '[F]ind [B]uffers' })
vim.keymap.set('n', '<leader><leader>', fz 'buffers', { desc = '[ ] Find existing buffers' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', fz 'grep_cword', { desc = '[S]earch current [W]ord' })
vim.keymap.set('v', '<leader>sv', fz 'grep_visual', { desc = '[S]earch [V]isual selection' })
vim.keymap.set('n', '<leader>/', fz 'blines', { desc = '[/] Fuzzy search current buffer' })
vim.keymap.set('n', '<leader>s/', fz 'lgrep_curbuf', { desc = '[S]earch [/] in current buffer' })
vim.keymap.set('n', '<leader>fo', fz 'oldfiles', { desc = '[F]ind [O]ld files' })
vim.keymap.set('n', '<leader>sn', function()
  setup()
  require('fzf-lua').files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })
