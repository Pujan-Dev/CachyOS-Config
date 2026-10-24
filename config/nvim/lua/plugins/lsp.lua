-- ============================================================
-- LSP  — mason · lspconfig · keymaps · server configs
-- NOTE: rust_analyzer is managed by rustaceanvim (plugins/rust.lua).
--       Do NOT call vim.lsp.enable('rust_analyzer') here.
-- ============================================================

local gh = function(r) return 'https://github.com/' .. r end

vim.pack.add {
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
}

-- ── Mason ────────────────────────────────────────────────────
require('mason').setup {
  ui = {
    border = 'rounded',
    icons = {
      package_installed = '✓',
      package_pending = '➜',
      package_uninstalled = '✗',
    },
  },
}

-- ── Tools / servers to auto-install ─────────────────────────
require('mason-tool-installer').setup {
  ensure_installed = {
    -- LSP servers
    'lua-language-server',
    'pyright',
    'gopls',
    'rust-analyzer',        -- used by rustaceanvim
    -- Formatters
    'stylua',
    'black',
    'ruff',
    'gofumpt',
    'goimports',
    -- Linters
    'golangci-lint',
    -- DAP adapters
    'delve',
    'debugpy',
    'codelldb',
  },
  auto_update = false,
  run_on_start = true,
}

-- ── LSP on-attach: keymaps + document highlights ─────────────
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or 'n', keys, func, { buffer = buf, desc = 'LSP: ' .. desc })
    end

    -- Rename (both the gr* standard and the user-spec leader binding)
    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

    -- Code actions
    map('gra', vim.lsp.buf.code_action, 'Code [A]ction', { 'n', 'x' })
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

    -- Declaration (NOT definition — telescope.lua handles definition)
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- Hover
    map('K', vim.lsp.buf.hover, 'Hover Documentation')

    -- Signature help in insert mode
    vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, { buffer = buf, desc = 'LSP: Signature Help' })

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    -- Inlay hints toggle
    if client and client:supports_method('textDocument/inlayHint', buf) then
      -- Enable by default
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
      map('<leader>uh', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buf })
      end, 'Toggle Inlay [H]ints')
    end

    -- Document highlight on cursor hold
    if client and client:supports_method('textDocument/documentHighlight', buf) then
      local hl = vim.api.nvim_create_augroup('user-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = buf, group = hl, callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = buf, group = hl, callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('user-lsp-detach', { clear = true }),
        callback = function(ev)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'user-lsp-highlight', buffer = ev.buf }
        end,
      })
    end
  end,
})

-- ── Server configurations ────────────────────────────────────

-- Lua
vim.lsp.config('lua_ls', {
  on_init = function(client)
    -- Don't override project-local .luarc.json
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if path ~= vim.fn.stdpath 'config'
        and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
      then
        return
      end
    end
    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua or {}, {
      runtime = { version = 'LuaJIT', path = { 'lua/?.lua', 'lua/?/init.lua' } },
      workspace = {
        checkThirdParty = false,
        library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
          '${3rd}/luv/library',
          '${3rd}/busted/library',
        }),
      },
    })
  end,
  settings = {
    Lua = {
      -- stylua handles formatting
      format = { enable = false },
      hint = { enable = true },
    },
  },
})

-- Python
vim.lsp.config('pyright', {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = 'openFilesOnly',
        useLibraryCodeForTypes = true,
        typeCheckingMode = 'basic',
      },
    },
  },
})

-- Go
vim.lsp.config('gopls', {
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
        fieldalignment = true,
        nilness = true,
        unusedwrite = true,
      },
      staticcheck = true,
      gofumpt = true,
      usePlaceholders = true,
      completeUnimported = true,
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

-- Enable all configured servers
-- (rust_analyzer intentionally excluded — rustaceanvim manages it)
local servers = { 'lua_ls', 'pyright', 'gopls' }
for _, name in ipairs(servers) do
  vim.lsp.enable(name)
end
