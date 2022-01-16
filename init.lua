-------------------- HELPERS -------------------------------
local api, cmd, fn, g = vim.api, vim.cmd, vim.fn, vim.g
local scopes = {o = vim.o, b = vim.bo, w = vim.wo, g = vim.g}
local opts = { noremap=true, silent=true }

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  api.nvim_set_keymap(mode, lhs, rhs, options)
end

local function opt(scope, key, value)
  scopes[scope][key] = value
  if scope ~= 'o' then scopes['o'][key] = value end
end

g.mapleader = ' '

-- g.completion_sorting = 'length'
-- g.completion_matching_strategy_list = {'exact', 'substring', 'fuzzy', 'all'}
-- g.completion_enable_snippet = 'UltiSnips'
-- g.completion_trigger_on_delete = 1
-- g.completion_trigger_keyword_length = 1
--
-- -------------------- ULTISNIPS -----------------------------
-- g.UltiSnipsExpandTrigger = '<Nop>'
-- g.UltiSnipsListSnippets = '<Nop>'
-- g.UltiSnipsJumpForwardTrigger = '<c-j>'
-- g.UltiSnipsJumpBackwardTrigger = '<c-k>'
-- g.UltiSnipsRemoveSelectModeMappings = 0


-------------------- GOLANG --------------------------------
g.go_def_mode = "gopls"
api.nvim_command([[
setlocal omnifunc=go#complete#Complete

autocmd FileType go nmap <leader>b  <Plug>(go-build)
autocmd FileType go nmap <leader>r  <Plug>(go-run)
autocmd FileType go nmap <leader>t  <Plug>(go-test)
]])

g.go_highlight_functions = 1
g.go_highlight_function_calls = 1
g.go_highlight_types = 1
g.go_highlight_operators = 1
g.go_highlight_fields = 1
--"let g:go_auto_sameids = 1

-------------------- PLUGINS -------------------------------
vim.cmd 'packadd packer.nvim' -- load the package manager
require('packer').startup(function()
  use {'wbthomason/packer.nvim'}
  use {'neovim/nvim-lspconfig'}
  use {'tpope/vim-fugitive'}
  --use {'kabouzeid/nvim-lspinstall'}
  use {'williamboman/nvim-lsp-installer'}
  use {'fatih/vim-go'}
  use {'jiangmiao/auto-pairs'}
  use {'nvim-lua/popup.nvim'}
  use {'nvim-lua/plenary.nvim'}
  use {'nvim-telescope/telescope.nvim'}
  use {'ojroques/nvim-hardline'}
  use {'mhinz/vim-startify'}
  use {'tpope/vim-surround'}
  use {'wadackel/vim-dogrun'}
  use {'mangeshrex/uwu.vim'}
  use {'ghifarit53/tokyonight-vim'}
  -- use {'folke/tokyonight.nvim'}
  use {'dracula/vim'}
  use {'hrsh7th/nvim-cmp'}
  use {'hrsh7th/cmp-nvim-lsp'}
  use {'honza/vim-snippets'}
  --use {'SirVer/ultisnips'}
  use {'dcampos/nvim-snippy'}
  use {'dcampos/cmp-snippy'}
end)

-- Lua LSP settings for Neovim development
local lua_settings = {
  Lua = {
    runtime = {
      version = 'LuaJIT', -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
      path = vim.split(package.path, ';') -- Setup your lua path
    },
    diagnostics = {
      globals = {'vim'} -- Get the language server to recognize the `vim` global
    },
    workspace = {
      library = { -- Make the server aware of Neovim runtime files
        [vim.fn.expand('$VIMRUNTIME/lua')] = true,
        [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
      }
    }
  }
}

local indent = 4

-- LSP settings
local lsp_installer = require("nvim-lsp-installer")

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
  local opts = {}

  -- (optional) Customize the options passed to the server
  -- if server.name == "tsserver" then
  --   opts.root_dir = function() ... end
  -- end

  -- This setup() function is exactly the same as lspconfig's setup function.
  -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
  server:setup(opts)
end)

require('snippy').setup({
    mappings = {
        is = {
            ['<Tab>'] = 'expand_or_advance',
            ['<S-Tab>'] = 'previous',
            ['<C-j>'] = 'next',
        },
        nx = {
            ['<leader>x'] = 'cut_text',
        },
    },
})

local cmp = require'cmp'

cmp.setup({
  snippet = {
-- REQUIRED - you must specify a snippet engine
    expand = function(args)
  -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
  -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      require('snippy').expand_snippet(args.body) -- For `snippy` users.
  -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), {"i", "s"}),
    ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), {"i", "s"}),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    -- { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
      { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- -- Setup lspconfig.
-- local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
--     require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
--     capabilities = capabilities
-- }

-- Environment options
opt('o', 'pumheight', 7)
opt('o', 'completeopt', 'menuone,noinsert,noselect')  -- Completion options
opt('o', 'termguicolors', true)                       -- True color support
opt('o', 'scrolloff', 4 )                             -- Lines of context
opt('o', 'splitbelow', true)                          -- Put new windows below current
opt('o', 'splitright', true)                          -- Put new windows right of current
opt('b', 'expandtab', true)                           -- Use spaces instead of tabs
opt('b', 'shiftwidth', indent)                        -- Size of an indent
opt('b', 'smartindent', true)                         -- Insert indents automatically
opt('b', 'tabstop', indent)
opt('b', 'undofile', true)                            -- Allows persistent undos
opt('w', 'cursorline', true)                          -- Highlight cursor line
opt('w', 'number', true)                              -- Show line numbers
opt('w', 'relativenumber', true)                      -- Relative line numbers
opt('w', 'signcolumn', 'yes')                         -- Show sign column
opt('w', 'wrap', false)                               -- Disable line wrap
opt('w', 'colorcolumn', '100')                        -- Show n-th column

-- Tab completions
map('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<S-Tab>"', {expr = true})
map('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})

-- Open/Close buffers
map('n', '<leader>q', '<cmd>bw<CR>')

-- Fugitive functions
map('n', '<leader>gs', '<cmd>G<CR>')
map('n', '<leader>gc', '<cmd>Git commit<CR>')
map('n', '<leader>gp', '<cmd>Git push<CR>')
map('n', '<leader>gh', '<cmd>diffget //3<CR>')
map('n', '<leader>gu', '<cmd>diffget //2<CR>')

-- Telescope functions
map('n', '<leader>ff', '<cmd>lua require("telescope.builtin").find_files()<cr>')
map('n', '<leader>fg', '<cmd>lua require("telescope.builtin").live_grep()<cr>')
map('n', '<leader>fb', '<cmd>lua require("telescope.builtin").buffers()<cr>')
map('n', '<leader>fh', '<cmd>lua require("telescope.builtin").help_tags()<cr>')

-- Jump b/w windows
map('n', '<leader>j', '<cmd>wincmd j<CR>')
map('n', '<leader>k', '<cmd>wincmd k<CR>')
map('n', '<C-l>', '<cmd>wincmd l<CR>')
map('n', '<C-h>', '<cmd>wincmd h<CR>')

-- Move lines around
map('n', '<C-k>', '<cmd>m .-2<CR>')
map('n', '<C-j>', '<cmd>m .+1<CR>')

-- LSP functions
map('n','gD','<cmd>lua vim.lsp.buf.declaration()<CR>')
map('n','gd','<cmd>lua vim.lsp.buf.definition()<CR>')
map('n','K','<cmd>lua vim.lsp.buf.hover()<CR>')
map('n','gr','<cmd>lua vim.lsp.buf.references()<CR>')
map('n','gs','<cmd>lua vim.lsp.buf.signature_help()<CR>')
map('n','gi','<cmd>lua vim.lsp.buf.implementation()<CR>')
map('n','gt','<cmd>lua vim.lsp.buf.type_definition()<CR>')
map('n','<leader>gw','<cmd>lua vim.lsp.buf.document_symbol()<CR>')
map('n','<leader>gW','<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
map('n','<leader>af','<cmd>lua vim.lsp.buf.code_action()<CR>')
map('n','<leader>ee','<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>')
map('n','<leader>ar','<cmd>lua vim.lsp.buf.rename()<CR>')
map('n','<leader>=', '<cmd>lua vim.lsp.buf.formatting()<CR>')
map('n','<leader>ai','<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
map('n','<leader>ao','<cmd>lua vim.lsp.buf.outgoing_calls()<CR>')

vim.cmd[[set t_Co=256]]

-- Tokyonight config
g.tokyonight_style = "night"
g.tokyonight_italic_functions = false
g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer" }
g.tokyonight_colors = { hint = "orange", error = "#ff0000" }

-- Dracula config
g.dracula_colorterm = 1

-- Load the colorscheme
vim.cmd[[colorscheme tokyonight]]

require'hardline'.setup{theme='nord',}
