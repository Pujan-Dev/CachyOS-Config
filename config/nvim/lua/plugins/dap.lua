-- ============================================================
-- DAP  — debugging
-- Fully lazy: setup runs on first keypress / breakpoint set.
-- Supports: Go (delve) · Python (debugpy) · Rust (codelldb)
-- ============================================================

local gh = function(r) return 'https://github.com/' .. r end

vim.pack.add {
  gh 'mfussenegger/nvim-dap',
  gh 'rcarriga/nvim-dap-ui',
  gh 'nvim-neotest/nvim-nio',         -- required by nvim-dap-ui
  gh 'mason-org/mason.nvim',
  gh 'jay-babu/mason-nvim-dap.nvim',
  gh 'leoluz/nvim-dap-go',
  gh 'mfussenegger/nvim-dap-python',
}

-- ── One-time setup ───────────────────────────────────────────
local _loaded = false
local function setup()
  if _loaded then return end
  _loaded = true

  local dap    = require 'dap'
  local dapui  = require 'dapui'

  -- Mason-managed debug adapters
  require('mason-nvim-dap').setup {
    automatic_installation = true,
    ensure_installed = { 'delve', 'debugpy', 'codelldb' },
    handlers = {},  -- let mason-nvim-dap choose sane defaults
  }

  -- ── DAP UI ───────────────────────────────────────────────
  dapui.setup {
    icons = { expanded = '▾', collapsed = '▸', current_frame = '▸' },
    controls = {
      enabled = true,
      element = 'repl',
      icons = {
        pause       = '⏸',
        play        = '▶',
        step_into   = '⏎',
        step_over   = '⏭',
        step_out    = '⏮',
        step_back   = 'b',
        run_last    = '▶▶',
        terminate   = '⏹',
        disconnect  = '⏏',
      },
    },
    layouts = {
      {
        elements = {
          { id = 'scopes',      size = 0.4 },
          { id = 'breakpoints', size = 0.2 },
          { id = 'stacks',      size = 0.2 },
          { id = 'watches',     size = 0.2 },
        },
        size = 40,
        position = 'left',
      },
      {
        elements = { { id = 'repl', size = 0.5 }, { id = 'console', size = 0.5 } },
        size = 12,
        position = 'bottom',
      },
    },
  }

  -- Auto-open / close UI with the debug session
  dap.listeners.after.event_initialized['dapui']  = dapui.open
  dap.listeners.before.event_terminated['dapui'] = dapui.close
  dap.listeners.before.event_exited['dapui']     = dapui.close

  -- ── Go (delve) ───────────────────────────────────────────
  require('dap-go').setup {
    dap_configurations = {
      {
        type       = 'go',
        name       = 'Debug',
        request    = 'launch',
        program    = '${file}',
      },
      {
        type       = 'go',
        name       = 'Debug test',
        request    = 'launch',
        mode       = 'test',
        program    = '${file}',
      },
    },
    delve = {
      path            = 'dlv',
      initialize_timeout_sec = 20,
      port            = '${port}',
      args            = {},
      build_flags     = '',
      detached        = vim.fn.has 'win32' == 0,
      cwd             = nil,
    },
  }

  -- ── Python (debugpy) ─────────────────────────────────────
  -- Use Mason-installed debugpy when available, system python otherwise
  local ok, mason_reg = pcall(require, 'mason-registry')
  local python_path
  if ok and mason_reg.is_installed 'debugpy' then
    python_path = mason_reg.get_package('debugpy'):get_install_path() .. '/venv/bin/python'
  else
    python_path = vim.fn.exepath 'python3' or vim.fn.exepath 'python' or 'python'
  end
  require('dap-python').setup(python_path)
  require('dap-python').test_runner = 'pytest'

  -- ── Rust (codelldb) ──────────────────────────────────────
  if ok and mason_reg.is_installed 'codelldb' then
    local root         = mason_reg.get_package('codelldb'):get_install_path()
    local codelldb_bin = root .. '/extension/adapter/codelldb'
    -- liblldb path differs by OS
    local liblldb
    if vim.fn.has 'mac' == 1 then
      liblldb = root .. '/extension/lldb/lib/liblldb.dylib'
    else
      liblldb = root .. '/extension/lldb/lib/liblldb.so'
    end

    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = codelldb_bin,
        args    = { '--port', '${port}' },
      },
    }

    dap.configurations.rust = {
      {
        name    = 'Launch (debug)',
        type    = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
        end,
        cwd         = '${workspaceFolder}',
        stopOnEntry = false,
        args        = {},
      },
    }

    -- Also usable from C/C++
    dap.configurations.c   = dap.configurations.rust
    dap.configurations.cpp = dap.configurations.rust
  end

  -- ── Signs ────────────────────────────────────────────────
  vim.fn.sign_define('DapBreakpoint',          { text = '●',  texthl = 'DiagnosticError',   numhl = '' })
  vim.fn.sign_define('DapBreakpointCondition', { text = '⊜',  texthl = 'DiagnosticWarning', numhl = '' })
  vim.fn.sign_define('DapBreakpointRejected',  { text = '⊘',  texthl = 'DiagnosticError',   numhl = '' })
  vim.fn.sign_define('DapLogPoint',            { text = '◆',  texthl = 'DiagnosticInfo',    numhl = '' })
  vim.fn.sign_define('DapStopped',             { text = '→',  texthl = 'DiagnosticOk',      numhl = 'DiffAdd' })
end

-- ── Keymaps (trigger lazy setup on first use) ─────────────────
local function dap_call(method)
  return function()
    setup()
    require('dap')[method]()
  end
end

vim.keymap.set('n', '<F5>',        dap_call 'continue',          { desc = 'Debug: Start / Continue' })
vim.keymap.set('n', '<F10>',       dap_call 'step_over',         { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F11>',       dap_call 'step_into',         { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F12>',       dap_call 'step_out',          { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>db',  dap_call 'toggle_breakpoint', { desc = 'Debug: Toggle [B]reakpoint' })
vim.keymap.set('n', '<leader>dB', function()
  setup()
  require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
end, { desc = 'Debug: Conditional [B]reakpoint' })

vim.keymap.set('n', '<leader>du', function()
  setup()
  require('dapui').toggle()
end, { desc = 'Debug: Toggle [U]I' })

vim.keymap.set('n', '<leader>dr', function()
  setup()
  require('dap').repl.open()
end, { desc = 'Debug: Open [R]EPL' })

vim.keymap.set('n', '<leader>dl', function()
  setup()
  require('dap').run_last()
end, { desc = 'Debug: Run [L]ast' })

vim.keymap.set('n', '<leader>dx', function()
  setup()
  require('dap').terminate()
  require('dapui').close()
end, { desc = 'Debug: Terminate' })

-- Evaluate expression under cursor / selection in a floating window
vim.keymap.set({ 'n', 'v' }, '<leader>de', function()
  setup()
  require('dapui').eval()
end, { desc = 'Debug: [E]val expression' })
