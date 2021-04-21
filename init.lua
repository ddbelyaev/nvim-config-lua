-- TODO: Refactor the file, so it is more comprehensible <18-04-21, ddbelyaev> --
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
g.UltiSnipsExpandTrigger="<Nop>"
g.UltiSnipsListSnippets="<Nop>"
g.UltiSnipsJumpForwardTrigger="<c-j>"
g.UltiSnipsJumpBackwardTrigger="<c-k>"
g.UltiSnipsRemoveSelectModeMappings = 0

-------------------- PLUGINS -------------------------------
vim.cmd 'packadd paq-nvim'               -- load the package manager
local paq = require'paq-nvim'.paq  -- a convenient alias
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
-- TODO: Set up dashboard-nvim properly <19-04-21, ddbelyaev> --
-- paq {'glepnir/dashboard-nvim'}

vim.cmd 'colorscheme tokyonight'
require('hardline').setup{theme='nord',}

local lua_settings = {
  Lua = {
    runtime = {
      -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
      version = 'LuaJIT',
      -- Setup your lua path
      path = vim.split(package.path, ';')
    },
    diagnostics = {
      -- Get the language server to recognize the `vim` global
      globals = {'vim'}
    },
    workspace = {
      -- Make the server aware of Neovim runtime files
      library = {[vim.fn.expand('$VIMRUNTIME/lua')] = true, [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true}
    }
  }
}

local indent = 4

local function setup_servers()
  require'lspinstall'.setup()
  local servers = require'lspinstall'.installed_servers()
  local config = {}
  for _, server in pairs(servers) do
    if server == 'lua' then
      config.settings = lua_settings
      indent = 2
    end

    config.on_attach=require'completion'.on_attach,
    require'lspconfig'[server].setup(config)
  end
end

setup_servers()

-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
require'lspinstall'.post_install_hook = function ()
  setup_servers() -- reload installed servers
  vim.cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
end

opt('o', 'completeopt', 'menuone,noinsert,noselect')  -- Completion options
opt('o', 'termguicolors', true)           -- True color support
opt('b', 'expandtab', true)               -- Use spaces instead of tabs
opt('b', 'shiftwidth', indent)            -- Size of an indent
opt('b', 'smartindent', true)             -- Insert indents automatically
opt('b', 'tabstop', indent)
opt('w', 'cursorline', true)              -- Highlight cursor line
opt('w', 'number', true)                  -- Show line numbers
opt('w', 'relativenumber', true)          -- Relative line numbers
opt('w', 'signcolumn', 'yes')             -- Show sign column
opt('w', 'wrap', false)                   -- Disable line wrap
opt('o', 'scrolloff', 4 )                 -- Lines of context
opt('o', 'splitbelow', true)              -- Put new windows below current
opt('o', 'splitright', true)              -- Put new windows right of current
opt('b', 'undofile', true)

map('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<S-Tab>"', {expr = true})
map('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})
map('n', '<leader>h', '<cmd>lua vim.lsp.buf.hover()<CR>')
map('n', '<leader>q', '<cmd>bw<CR>')

map('n', '<leader>gs', '<cmd>G<CR>')
map('n', '<leader>gc', '<cmd>Git commit<CR>')
map('n', '<leader>gp', '<cmd>Git push<CR>')

map('n', '<leader>ff', '<cmd>lua require("telescope.builtin").find_files()<cr>')
map('n', '<leader>fg', '<cmd>lua require("telescope.builtin").live_grep()<cr>')
map('n', '<leader>fb', '<cmd>lua require("telescope.builtin").buffers()<cr>')
map('n', '<leader>fh', '<cmd>lua require("telescope.builtin").help_tags()<cr>')
-- nmap <leader>gh :diffget //3<CR>
-- nmap <leader>gu :diffget //2<CR>
-- nmap <leader>gs :G<CR>
-- nmap <leader>gc :Gcommit<CR>
-- nmap <leader>gp :Gpush<CR>

map('n', '<leader>j', '<cmd>wincmd j<CR>')
map('n', '<leader>k', '<cmd>wincmd k<CR>')
map('n', '<C-l>', '<cmd>wincmd l<CR>')
map('n', '<C-h>', '<cmd>wincmd h<CR>')

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
