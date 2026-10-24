-- ============================================================
-- RUST  — rustaceanvim
--
-- rustaceanvim replaces the normal vim.lsp.enable('rust_analyzer')
-- flow entirely. It is configured via vim.g.rustaceanvim (a table
-- that must be set BEFORE any .rs file is opened).
--
-- Do NOT call vim.lsp.enable('rust_analyzer') in lsp.lua.
-- Mason still installs rust-analyzer; rustaceanvim uses it.
-- ============================================================

local gh = function(r) return 'https://github.com/' .. r end

vim.pack.add { gh 'mrcjkb/rustaceanvim' }

vim.g.rustaceanvim = {
  -- ── Tools layer ────────────────────────────────────────────
  tools = {
    float_win_config = {
      border = 'rounded',
      auto_focus = true,
    },
    -- 'termopen' is the default executor; explicit here for clarity.
    -- Wrapped in a function so it resolves after the plugin is on rtp.
    executor = (function()
      local ok, ex = pcall(require, 'rustaceanvim.executors')
      return ok and ex.termopen or nil
    end)(),
  },

  -- ── rust-analyzer LSP config ───────────────────────────────
  server = {
    on_attach = function(_, bufnr)
      local map = function(key, cmd, desc)
        vim.keymap.set('n', key, function() vim.cmd.RustLsp(cmd) end, { buffer = bufnr, desc = 'Rust: ' .. desc })
      end
      -- Rust-specific extras on top of the generic LSP keymaps (lsp.lua)
      map('<leader>rh', 'hover actions',       '[R]ust [H]over Actions')
      map('<leader>re', 'explainError',         '[R]ust [E]xplain Error')
      map('<leader>rd', 'renderDiagnostic',     '[R]ust [D]iagnostic')
      map('<leader>rc', 'openCargo',            '[R]ust [C]argo.toml')
      map('<leader>rr', 'runnables',            '[R]ust [R]unnables')
      map('<leader>rt', 'testables',            '[R]ust [T]estables')
      map('<leader>rm', 'expandMacro',          '[R]ust Expand [M]acro')
      map('<leader>rp', { 'rebuildProcMacros' }, '[R]ust rebuild [P]roc macros')
    end,

    default_settings = {
      ['rust-analyzer'] = {
        cargo = {
          allFeatures = true,
          loadOutDirsFromCheck = true,
          buildScripts = { enable = true },
        },
        checkOnSave = {
          allFeatures = true,
          command = 'clippy',
          extraArgs = {
            '--no-deps',
            '--',
            '-W', 'clippy::pedantic',
            '-A', 'clippy::module_name_repetitions',
          },
        },
        procMacro = {
          enable = true,
          ignored = {
            ['async-trait']     = { 'async_trait' },
            ['napi-derive']     = { 'napi' },
            ['async-recursion'] = { 'async_recursion' },
          },
        },
        inlayHints = {
          bindingModeHints           = { enable = false },
          closingBraceHints          = { minLines = 25 },
          closureReturnTypeHints     = { enable = 'never' },
          discriminantHints          = { enable = 'never' },
          lifetimeElisionHints       = { enable = 'never' },
          maxLength                  = 25,
          parameterHints             = { enable = true },
          typeHints                  = { enable = true },
          chainingHints              = { enable = true },
        },
        diagnostics = {
          enable = true,
          experimental = { enable = true },
        },
        lens = {
          enable = true,
          run    = { enable = true },
          test   = { enable = true },
          debug  = { enable = true },
        },
      },
    },
  },

  -- ── DAP integration ────────────────────────────────────────
  -- The DAP adapter is set up in plugins/dap.lua (codelldb).
  dap = {
    adapter = function()
      local ok, mason_registry = pcall(require, 'mason-registry')
      if not ok or not mason_registry.is_installed 'codelldb' then
        return {
          type = 'executable',
          command = 'lldb-vscode',
          name = 'lldb',
        }
      end
      local pkg = mason_registry.get_package 'codelldb'
      local root = pkg:get_install_path()
      return {
        type    = 'server',
        port    = '${port}',
        executable = {
          command = root .. '/extension/adapter/codelldb',
          args    = { '--port', '${port}' },
        },
      }
    end,
  },
}
