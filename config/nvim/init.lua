-- ============================================================
-- BOOTSTRAP
-- Sets leader, enables Lua bytecode cache, registers build
-- hooks for vim.pack, then delegates everything to modules.
-- ============================================================

vim.loader.enable()

-- Must be set before any plugin loads
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Toggle this once you install a Nerd Font in your terminal
vim.g.have_nerd_font = true

-- ============================================================
-- PACK BUILD HOOKS
-- Runs after telescope-fzf-native, LuaSnip, or treesitter
-- are installed / updated by vim.pack.
-- ============================================================
local function run_build(name, cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd }):wait()
  if result.code ~= 0 then
    local out = result.stderr ~= '' and result.stderr or result.stdout or 'No output'
    vim.notify(('Build failed for %s:\n%s'):format(name, out), vim.log.levels.ERROR)
  end
end

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind, path = ev.data.spec.name, ev.data.kind, ev.data.path
    if kind ~= 'install' and kind ~= 'update' then return end

    if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
      run_build(name, { 'make' }, path)
    elseif name == 'LuaSnip' and vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then
      run_build(name, { 'make', 'install_jsregexp' }, path)
    elseif name == 'nvim-treesitter' then
      if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
      vim.cmd 'TSUpdate'
    end
  end,
})

-- ============================================================
-- CORE (order matters: options → autocmds → keymaps)
-- ============================================================
require 'options'
require 'autocmds'
require 'keymaps'

-- ============================================================
-- PLUGINS
-- ============================================================
require 'plugins.ui'
require 'plugins.editing'
require 'plugins.telescope'
require 'plugins.fzf'
require 'plugins.treesitter'
require 'plugins.lsp'
require 'plugins.cmp'
require 'plugins.formatting'
require 'plugins.linting'
require 'plugins.git'
require 'plugins.neo-tree'
require 'plugins.terminal'
require 'plugins.rust'
require 'plugins.go'
require 'plugins.python'
require 'plugins.dap'

-- vim: ts=2 sts=2 sw=2 et
