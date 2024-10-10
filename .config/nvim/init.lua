-- Initialize packer.nvim
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
  -- Add Packer itself
  use 'wbthomason/packer.nvim'

  -- Install onedarkpro.nvim (Visual Studio Code theme)
  use {
    'olimorris/onedarkpro.nvim',
    config = function()
      require("onedarkpro").load()
    end
  }

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} } -- required dependency
  }

  -- NERDTree
  use 'preservim/nerdtree'

  -- LSP config for setting up rust-analyzer
  use 'neovim/nvim-lspconfig'

  -- Optional: Rust tools to handle linting and formatting
  use 'simrat39/rust-tools.nvim'

end)


-- Set up rust-tools for additional features like inlay hints and formatting
require('rust-tools').setup({
  tools = {
      inlay_hints = {
            auto = false,  -- Disable automatic inlay hints
            show_parameter_hints = false,  -- Disable parameter hints
            show_variable_name = false,    -- Disable variable name hints
        },
  },
  server = {
    on_attach = function(_, bufnr)
      -- Key mappings for Rust-specific functionality
      local opts = { noremap=true, silent=true }
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    end
  }
})

require('onedarkpro').setup({
  -- Optional: Configure specific highlights if necessary
  highlights = {
    LspDiagnosticsDefaultError = { fg = "#ff6c6b" },
    LspDiagnosticsDefaultWarning = { fg = "#ECBE7B" },
    LspDiagnosticsDefaultInformation = { fg = "#51afef" },
    LspDiagnosticsDefaultHint = { fg = "#98be65" },
  }
})
vim.cmd('set termguicolors')  -- Ensure 24-bit RGB color support
require("onedarkpro").load()

-- Enable syntax highlighting
vim.cmd [[syntax on]]

-- Enable true color support
vim.o.termguicolors = true

-- Use spaces instead of tabs
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Enable line numbers
vim.wo.number = true

-- General settings
vim.o.wrap = false
vim.o.cursorline = true
vim.o.clipboard = 'unnamedplus'

-- nerd tree
vim.api.nvim_set_keymap('n', '<C-n>', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-b>', ':NERDTreeFocus<CR>', { noremap = true, silent = true })

vim.fn.sign_define("DiagnosticSignError", {text = "✗", numhl = "DiagnosticError", texthl = "DiagnosticSignError"})
vim.fn.sign_define("DiagnosticSignWarn", {text = "⚠", numhl = "DiagnosticWarn", texthl = "DiagnosticSignWarn"})
vim.fn.sign_define("DiagnosticSignInfo", {text = "ℹ", numhl = "DiagnosticInfo", texthl = "DiagnosticSignInfo"})
vim.fn.sign_define("DiagnosticSignHint", {text = "💡", numhl = "DiagnosticHint", texthl = "DiagnosticSignHint"})
vim.api.nvim_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",  -- Adds a rounded border to the hover window
})


-- Remap HJKL to move between splits in normal mode
vim.api.nvim_set_keymap('n', 'H', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'J', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'L', '<C-w>l', { noremap = true, silent = true })

-- Use HJKL for resize
vim.api.nvim_set_keymap('n', '<C-H>', ':vertical resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-J>', ':resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-K>', ':resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-L>', ':vertical resize +2<CR>', { noremap = true, silent = true })

-- Remap Esc to go to normal mode in terminal
vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })


-- Function to initialize environment
local function init_environment()
  -- Open NERDTree
  vim.cmd('NERDTreeToggle')

  -- Make the tree a little smaller
  vim.cmd('wincmd h')
  vim.cmd('vertical resize 20')

  -- Move focus to the right window (the file window)
  vim.cmd('wincmd l')

  -- Open a horizontal split below the file window
  vim.cmd('split')

  -- Move to the bottom split (down arrow)
  vim.cmd('wincmd j')

  -- Open terminal in the bottom split
  vim.cmd('terminal')

  -- Resize the terminal split to height 10
  vim.cmd('resize 8')

  -- Go back to the top split
  vim.cmd('wincmd k')
end

-- Create a command to run the environment initialization
vim.api.nvim_create_user_command('Init', init_environment, {})
vim.api.nvim_set_keymap('n', '<C-i>', ':Init<CR>', { noremap = true, silent = true })

-- Custom Quit that closes all terminals properly and then exits Neovim
-- Custom Quit that closes all terminals gracefully and then exits Neovim
vim.api.nvim_create_user_command('Bye', function()
  -- Iterate over all buffers and close terminal buffers gracefully
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == 'terminal' then
      -- Stop the terminal job gracefully
      local job_id = vim.b[buf].terminal_job_id
      if job_id ~= nil then
        -- Send signal to terminate the job, but avoid freezing if it hangs
        vim.fn.jobstop(job_id)
      end
      -- Close the terminal buffer
      vim.cmd('bdelete! ' .. buf)
    end
  end

  -- Write and quit all other buffers
  vim.cmd('wqa')
end, {})

-- call my init command on start
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    vim.cmd('Init')
  end,
})

-- formatter
require('lspconfig').rust_analyzer.setup({
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      checkOnSave = {
        command = "clippy",  -- Optionally run clippy on save
      },
    }
  },
  -- This on_attach will set up formatting on save
  on_attach = function(_, bufnr)
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Auto format on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end
    })
  end
})
