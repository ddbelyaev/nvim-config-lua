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

g.completion_sorting = 'length'
g.completion_matching_strategy_list = {'exact', 'substring', 'fuzzy', 'all'}
g.completion_enable_snippet = 'UltiSnips'
g.completion_trigger_on_delete = 1
g.completion_trigger_keyword_length = 0

g.UltiSnipsExpandTrigger="<Nop>"
g.UltiSnipsListSnippets="<Nop>"
g.UltiSnipsJumpForwardTrigger="<c-j>"
g.UltiSnipsJumpBackwardTrigger="<c-k>"
g.UltiSnipsRemoveSelectModeMappings = 0

-------------------- PLUGINS -------------------------------
vim.cmd 'packadd paq-nvim' -- load the package manager
local paq = require'paq-nvim'.paq -- a convenient alias
paq {'savq/paq-nvim', opt = true}
paq {'neovim/nvim-lspconfig'}
paq {'tpope/vim-fugitive'}
paq {'kabouzeid/nvim-lspinstall'}
paq {'nvim-lua/completion-nvim'}
-- paq {'ghifarit53/tokyonight-vim'}
paq {'folke/tokyonight.nvim'}
paq {'fatih/vim-go'}
paq {'jiangmiao/auto-pairs'}
paq {'nvim-lua/popup.nvim'}
paq {'nvim-lua/plenary.nvim'}
paq {'nvim-telescope/telescope.nvim'}
paq {'SirVer/ultisnips'}
paq {'honza/vim-snippets'}
paq {'ojroques/nvim-hardline'}
paq {'mhinz/vim-startify'}
paq {'blackcauldron7/surround.nvim'}

vim.cmd 'colorscheme tokyonight'
require'hardline'.setup{theme='nord',}
require'surround'.setup{}

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
local function setup_servers()
  require'lspinstall'.setup()
  local servers = require'lspinstall'.installed_servers()
  local config = {}
  config.on_attach=require'completion'.on_attach
  config.root_dir=require'lspconfig'.util.root_pattern('.git')

  for _, server in pairs(servers) do
    if server == 'lua' then
      config.settings = lua_settings
      indent = 2
    end

    require'lspconfig'[server].setup(config)
  end
end

setup_servers()

-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
require'lspinstall'.post_install_hook = function ()
  setup_servers() -- reload installed servers
  vim.cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
end

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
map('n','<leader>ah','<cmd>lua vim.lsp.buf.hover()<CR>')
map('n','<leader>af','<cmd>lua vim.lsp.buf.code_action()<CR>')
map('n','<leader>ee','<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>')
map('n','<leader>ar','<cmd>lua vim.lsp.buf.rename()<CR>')
map('n','<leader>=', '<cmd>lua vim.lsp.buf.formatting()<CR>')
map('n','<leader>ai','<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
map('n','<leader>ao','<cmd>lua vim.lsp.buf.outgoing_calls()<CR>')
