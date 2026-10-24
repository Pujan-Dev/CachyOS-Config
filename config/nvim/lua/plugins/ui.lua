-- ============================================================
-- UI PLUGINS
-- colorscheme · lualine · mini.icons · todo-comments ·
-- which-key · fidget
-- ============================================================

local gh = function(r) return 'https://github.com/' .. r end

-- ── Colorscheme (must load synchronously before anything draws) ──
vim.pack.add { gh 'folke/tokyonight.nvim' }
require('tokyonight').setup {
  style = 'night',
  transparent = false,
  terminal_colors = true,
  styles = {
    comments = { italic = false },
    keywords = { italic = false },
  },
}
vim.cmd.colorscheme 'tokyonight-night'

-- ── mini.nvim (single repo, many modules) ────────────────────
-- We add it once here; other plugin files just require the sub-modules.
vim.pack.add { gh 'nvim-mini/mini.nvim' }

if vim.g.have_nerd_font then
  require('mini.icons').setup()
  -- Shim for plugins that depend on nvim-web-devicons
  MiniIcons.mock_nvim_web_devicons()
end

-- ── todo-comments ────────────────────────────────────────────
vim.pack.add { gh 'folke/todo-comments.nvim' }
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function() require('todo-comments').setup { signs = false } end,
})

-- ── which-key ────────────────────────────────────────────────
vim.pack.add { gh 'folke/which-key.nvim' }
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    require('which-key').setup {
      delay = 400,
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        -- Groups
        { '<leader>b', group = '[B]uffer' },
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]iagnostics' },
        { '<leader>f', group = '[F]ind / [F]ormat', mode = { 'n', 'v' } },
        { '<leader>g', group = '[G]it' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>r', group = '[R]ename / [R]ust' },
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]erminal' },
        { '<leader>u', group = '[U]I Toggles' },
        { '<leader>db', group = '[D]ebug [B]reakpoint' },
        { 'gr', group = 'LSP', mode = { 'n' } },
      },
    }
  end,
})

-- ── fidget (LSP progress notifications) ──────────────────────
vim.pack.add { gh 'j-hui/fidget.nvim' }
vim.api.nvim_create_autocmd('LspAttach', {
  once = true,
  callback = function()
    require('fidget').setup {
      notification = { window = { winblend = 0 } },
    }
  end,
})

-- ── lualine ──────────────────────────────────────────────────
vim.pack.add { gh 'nvim-lualine/lualine.nvim' }
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    local function lsp_clients()
      local clients = vim.lsp.get_clients { bufnr = 0 }
      if #clients == 0 then return '' end
      local names = vim.tbl_map(function(c) return c.name end, clients)
      return ' ' .. table.concat(names, ' ')
    end

    require('lualine').setup {
      options = {
        icons_enabled = vim.g.have_nerd_font,
        theme = 'tokyonight',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        globalstatus = true,
        refresh = { statusline = 1000 },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = {
          { 'filename', path = 1, symbols = { modified = ' ●', readonly = ' ', unnamed = '' } },
          { lsp_clients, color = { fg = '#7dcfff' } },
        },
        lualine_x = {
          'encoding',
          { 'fileformat', symbols = { unix = 'LF', dos = 'CRLF', mac = 'CR' } },
          'filetype',
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'location' },
      },
    }
  end,
})
