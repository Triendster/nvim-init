" This file lives online on my GitHub repository: https://github.com/Triendster/nvim-init.git
" Pushing this file to the repository is done by running the following git
" commands:
" git add init.vim
" git commit -m "Add init.vim"
" git push origin master
" Basic Settings
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set clipboard=unnamedplus
set hlsearch
set ignorecase
set smartcase
set wrap
set termguicolors

let mapleader = ' '

autocmd TermOpen * setlocal nonumber norelativenumber " Disable line numbers
autocmd TermOpen * setlocal nocursorline " Disable cursorline
autocmd TermOpen * startinsert " Automatically enter insert mode
autocmd TermOpen * setlocal laststatus=0 " Hide statusline in terminal
colorscheme night-owl

" Load packer.nvim
packadd packer.nvim

lua << EOF
require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Syntax highlighting
  use 'nvim-treesitter/nvim-treesitter'

  -- LSP (Language Server Protocol)
  use 'neovim/nvim-lspconfig'
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'

  -- Autocompletion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'L3MON4D3/LuaSnip'

  -- Colorscheme
  use 'haishanh/night-owl.vim'

  -- Fuzzy Finder
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Statusline
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }

  -- Git integration
  use 'tpope/vim-fugitive'

  -- File explorer
  use 'kyazdani42/nvim-tree.lua'
end)
EOF

lua << EOF
-- Lualine setup
require('lualine').setup {
  sections = {
    lualine_c = {
      { 'filename', path = 1 },
      { 'diagnostics', sources = {'nvim_diagnostic'}, symbols = {error = 'E', warn = 'W'} }
    },
  },
}

EOF

lua << EOF
-- vim-treesitter config
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "cpp", "python", "go", "lua", "bash", "html", "javascript", "json" },  -- List of languages you want parsers for
  highlight = {
    enable = true,              -- Enable syntax highlighting
  },
}
EOF

lua << EOF
-- nvim-tree config
require'nvim-tree'.setup {
  view = {
    width = 30,          -- Set the width of the tree window
    side = 'left',       -- Set the tree window to open on the left side
  },
}

-- Automatically open nvim-tree when starting Neovim without a file
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function()
    if #vim.fn.argv() == 0 then
      require("nvim-tree.api").tree.open()
    end
  end
})
EOF

lua << EOF
  -- Required for setting up clangd
 require('lspconfig').clangd.setup{}
 require('lspconfig').pyright.setup{}
EOF

lua << EOF
-- LSP and completion setup
require('mason').setup()
require('mason-lspconfig').setup({
  function(server_name)
    lspconfig[server_name].setup{}
  end,
})

-- nvim-cmp-setup

local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)  -- For Luasnip users.
    end,
  },
  mapping = {
    -- Navigate the completion menu
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()  -- Move to next item in the menu
      elseif require('luasnip').expand_or_jumpable() then
        require('luasnip').expand_or_jump()
      else
        fallback()  -- If no match, continue with regular <Tab>
      end
    end, { 'i', 's' }),  -- Apply mapping in insert and select modes

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()  -- Move to previous item in the menu
      elseif require('luasnip').jumpable(-1) then
        require('luasnip').jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),  -- Manually trigger completion

    ['<CR>'] = cmp.mapping.confirm({ select = true }),  -- Confirm the selection with Enter

    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),  -- Abort the completion menu
      c = cmp.mapping.close(),
    }),
  },
  sources = {
    { name = 'nvim_lsp' },  -- LSP suggestions
    { name = 'luasnip' },   -- Snippet suggestions
    { name = 'buffer' },    -- Buffer text suggestions
    { name = 'path' },      -- File path suggestions
  },
})
EOF

lua << EOF
-- LSP key mappings
local opts = { noremap=true, silent=true }

vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)  -- Hover documentation
vim.api.nvim_set_keymap('n', '<C-p>', ':tabnew<CR>:Telescope find_files<CR>', { noremap = true, silent = true })
-- Mapping Ctrl and PageUp to execute :tabnext +1
vim.api.nvim_set_keymap('n', '<C-PageUp>', ':tabnext-<CR>', { noremap = true, silent = true })
-- Mapping Ctrl and PageDown to execute :tabnext -1
vim.api.nvim_set_keymap('n', '<C-PageDown>', ':tabnext<CR>', { noremap = true, silent = true })
-- Mapping Ctrl K, Ctrl S to save all buffers
vim.api.nvim_set_keymap('n', '<C-K><C-S>', ':wa<CR>', { noremap = true, silent = true })
EOF
