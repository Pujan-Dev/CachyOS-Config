-- ============================================================
-- TELESCOPE  — fuzzy finder
-- ============================================================

local gh = function(r) return 'https://github.com/' .. r end

local deps = {
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
}
if vim.fn.executable 'make' == 1 then
  table.insert(deps, gh 'nvim-telescope/telescope-fzf-native.nvim')
end
vim.pack.add(deps)

-- Lazy initialisation: setup runs on first call, not at startup.
local _loaded = false
local function setup()
  if _loaded then return end
  _loaded = true
  require('telescope').setup {
    defaults = {
      prompt_prefix = '  ',
      selection_caret = ' ',
      path_display = { 'truncate' },
      sorting_strategy = 'ascending',
      layout_config = {
        horizontal = { prompt_position = 'top', preview_width = 0.55 },
      },
      mappings = {
        i = { ['<C-u>'] = false, ['<C-d>'] = false },
      },
      -- ── speed: skip big dirs, trim rg work ──
      file_ignore_patterns = {
        '%.git/',
        'node_modules/',
        'target/',
        'build/',
        'dist/',
        '%.lock$',
        '%.min%.js$',
      },
      vimgrep_arguments = {
        'rg',
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case',
        '--trim', -- trim indent, less preview work
        '--glob=!%.git/*',
        '--glob=!node_modules/*',
        '--glob=!target/*',
        '--glob=!build/*',
        '--glob=!dist/*',
      },
      -- ── speed: don't treesitter-highlight huge preview files ──
      buffer_previewer_maker = function(filepath, bufnr, opts)
        opts = opts or {}
        local max = 100 * 1024 -- 100KB
        local ok, stat = pcall(vim.loop.fs_stat, filepath)
        if ok and stat and stat.size > max then
          return
        end
        require('telescope.previewers').buffer_previewer_maker(filepath, bufnr, opts)
      end,
      preview = { timeout = 150, filesize_limit = 0.1 }, -- ms / MB
    },
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_dropdown() },
    },
  }
  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')
end

-- Helper: returns a callback that lazily calls a builtin picker.
local function pick(name, opts)
  return function()
    setup()
    require('telescope.builtin')[name](opts or {})
  end
end

-- ── File / search keymaps ────────────────────────────────────
local has_fd = vim.fn.executable 'fd' == 1
local find_cmd
if has_fd then
  find_cmd = { 'fd', '--type', 'f', '--strip-cwd-prefix', '--hidden', '--exclude', '.git', '--exclude', 'node_modules', '--exclude', 'target' }
end
vim.keymap.set('n', '<leader>ff', pick('find_files', { find_command = find_cmd }), { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fg', pick 'live_grep', { desc = '[F]ind by [G]rep' })
vim.keymap.set('n', '<leader>fb', pick 'buffers', { desc = '[F]ind [B]uffers' })
vim.keymap.set('n', '<leader>fo', pick 'oldfiles', { desc = '[F]ind [O]ld files' })
vim.keymap.set('n', '<leader>fh', pick 'help_tags', { desc = '[F]ind [H]elp' })
vim.keymap.set('n', '<leader><leader>', pick 'buffers', { desc = '[ ] Find existing buffers' })

-- ── Secondary search keymaps ─────────────────────────────────
vim.keymap.set('n', '<leader>sk', pick 'keymaps', { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>ss', pick 'builtin', { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', pick 'grep_string', { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sd', pick 'diagnostics', { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', pick 'resume', { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>sc', pick 'commands', { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader>D', pick 'diagnostics', { desc = 'Workspace [D]iagnostics' })

-- Config files shortcut
vim.keymap.set('n', '<leader>sn', function()
  setup()
  require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config', follow = true }
end, { desc = '[S]earch [N]eovim files' })

-- Buffer fuzzy search
vim.keymap.set('n', '<leader>/', function()
  setup()
  require('telescope.builtin').current_buffer_fuzzy_find(
    require('telescope.themes').get_dropdown { winblend = 10, previewer = false }
  )
end, { desc = '[/] Fuzzy search current buffer' })

-- Live grep in open files
vim.keymap.set('n', '<leader>s/', function()
  setup()
  require('telescope.builtin').live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
end, { desc = '[S]earch [/] in Open Files' })

-- ── LSP pickers (attached per buffer) ───────────────────────
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    local function lmap(key, picker, desc)
      vim.keymap.set('n', key, function()
        setup()
        require('telescope.builtin')[picker]()
      end, { buffer = buf, desc = desc })
    end
    -- Standard gr* bindings
    lmap('grr', 'lsp_references', '[G]oto [R]eferences')
    lmap('gri', 'lsp_implementations', '[G]oto [I]mplementation')
    lmap('grd', 'lsp_definitions', '[G]oto [D]efinition')
    lmap('grt', 'lsp_type_definitions', '[G]oto [T]ype Definition')
    lmap('gO', 'lsp_document_symbols', 'Document [S]ymbols')
    lmap('gW', 'lsp_dynamic_workspace_symbols', '[W]orkspace Symbols')
    -- Short aliases the user spec asked for
    lmap('gd', 'lsp_definitions', '[G]oto [D]efinition')
    lmap('gr', 'lsp_references', '[G]oto [R]eferences')
    lmap('gi', 'lsp_implementations', '[G]oto [I]mplementation')
  end,
})
