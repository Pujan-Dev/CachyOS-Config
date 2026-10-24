-- ============================================================
-- TREESITTER  — highlighting · indentation · incremental selection
-- ============================================================

local gh = function(r) return 'https://github.com/' .. r end

vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

-- Pre-install parsers for our target languages + common extras
local parsers = {
  'bash',
  'c',
  'diff',
  'dockerfile',
  'go',
  'gomod',
  'gosum',
  'html',
  'json',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'rust',
  'sql',
  'toml',
  'vim',
  'vimdoc',
  'yaml',
}
require('nvim-treesitter').install(parsers)

-- Attach treesitter features per buffer on FileType
local function attach(buf, lang)
  if not vim.treesitter.language.add(lang) then return end
  vim.treesitter.start(buf, lang)
  -- Treesitter indentation (falls back to vim built-in if no indent query)
  if vim.treesitter.query.get(lang, 'indents') then
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

local available = require('nvim-treesitter').get_available()

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('user-treesitter', { clear = true }),
  callback = function(args)
    local buf, ft = args.buf, args.match
    local lang = vim.treesitter.language.get_lang(ft)
    if not lang then return end

    local installed = require('nvim-treesitter').get_installed 'parsers'
    if vim.tbl_contains(installed, lang) then
      attach(buf, lang)
    elseif vim.tbl_contains(available, lang) then
      require('nvim-treesitter').install(lang):await(function() attach(buf, lang) end)
    else
      attach(buf, lang)
    end
  end,
})
