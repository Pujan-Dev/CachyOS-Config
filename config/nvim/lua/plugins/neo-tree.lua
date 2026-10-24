-- ============================================================
-- NEO-TREE  — file explorer
-- ============================================================

local gh = function(r) return 'https://github.com/' .. r end

vim.pack.add {
  { src = gh 'nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  gh 'nvim-lua/plenary.nvim',
  gh 'MunifTanjim/nui.nvim',
}

-- Reveal current file
vim.keymap.set('n', '\\', '<cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })
-- Toggle
vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', { desc = '[E]xplorer toggle' })

require('neo-tree').setup {
  close_if_last_window = true,
  popup_border_style = 'rounded',
  enable_git_status = true,
  enable_diagnostics = true,

  sources = { 'filesystem', 'buffers', 'git_status' },

  source_selector = {
    winbar = false,
    statusline = false,
  },

  default_component_configs = {
    indent = {
      indent_size = 2,
      padding = 1,
      with_markers = true,
      indent_marker = '│',
      last_indent_marker = '└',
      highlight = 'NeoTreeIndentMarker',
    },
    icon = {
      folder_closed = '',
      folder_open = '',
      folder_empty = '',
      default = ' ',
    },
    git_status = {
      symbols = vim.g.have_nerd_font and {
        added     = '',
        modified  = '',
        deleted   = '✖',
        renamed   = '➜',
        untracked = '',
        ignored   = '',
        unstaged  = '',
        staged    = '',
        conflict  = '',
      } or {
        added     = '+',
        modified  = '~',
        deleted   = '-',
        renamed   = '>',
        untracked = '?',
        ignored   = 'I',
        unstaged  = 'U',
        staged    = 'S',
        conflict  = 'C',
      },
    },
    diagnostics = {
      symbols = {
        error = '✘ ',
        warn  = '▲ ',
        info  = '» ',
        hint  = '⚑ ',
      },
      highlights = {
        error = 'DiagnosticError',
        warn  = 'DiagnosticWarn',
        info  = 'DiagnosticInfo',
        hint  = 'DiagnosticHint',
      },
    },
  },

  window = {
    position = 'left',
    width = 35,
    mapping_options = { noremap = true, nowait = true },
    mappings = {
      ['<CR>']  = 'open',
      ['<Esc>'] = 'cancel',
      ['s']     = 'open_vsplit',
      ['S']     = 'open_split',
      ['t']     = 'open_tabnew',
      ['P']     = { 'toggle_preview', config = { use_float = true } },
      ['l']     = 'focus_preview',
      ['C']     = 'close_node',
      ['z']     = 'close_all_nodes',
      ['a']     = 'add',
      ['A']     = 'add_directory',
      ['d']     = 'delete',
      ['r']     = 'rename',
      ['y']     = 'copy_to_clipboard',
      ['x']     = 'cut_to_clipboard',
      ['p']     = 'paste_from_clipboard',
      ['c']     = 'copy',
      ['m']     = 'move',
      ['q']     = 'close_window',
      ['R']     = 'refresh',
      ['?']     = 'show_help',
    },
  },

  filesystem = {
    filtered_items = {
      visible = false,
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_by_name = { '.git', 'node_modules' },
    },
    follow_current_file = { enabled = true, leave_dirs_open = true },
    group_empty_dirs = true,
    use_libuv_file_watcher = true,
    window = {
      mappings = {
        ['\\'] = 'close_window',
        ['<BS>'] = 'navigate_up',
        ['.']  = 'set_root',
        ['H']  = 'toggle_hidden',
        ['/']  = 'fuzzy_finder',
        ['f']  = 'filter_on_submit',
        ['<C-x>'] = 'clear_filter',
        ['[g'] = 'prev_git_modified',
        [']g'] = 'next_git_modified',
      },
    },
  },

  buffers = {
    follow_current_file = { enabled = true },
    group_empty_dirs = true,
    window = {
      mappings = {
        ['d'] = 'buffer_delete',
        ['<BS>'] = 'navigate_up',
        ['.'] = 'set_root',
      },
    },
  },

  git_status = {
    window = {
      mappings = {
        ['A'] = 'git_add_all',
        ['gu'] = 'git_unstage_file',
        ['ga'] = 'git_add_file',
        ['gr'] = 'git_revert_file',
        ['gc'] = 'git_commit',
        ['gp'] = 'git_push',
        ['gg'] = 'git_commit_and_push',
      },
    },
  },
}
