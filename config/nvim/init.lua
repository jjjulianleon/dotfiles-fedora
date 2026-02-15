--[[
  KICKSTART.NVIM (CUSTOMIZED FOR VIBECODING) - MODERN LSP CONFIG
  Based on the famous kickstart.nvim but tailored for visuals and manual coding mastery.
]]

-- Disable netrw (default file explorer) to allow alpha-nvim dashboard to show up
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager (lazy.nvim)
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', 
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'tpope/vim-sleuth',

  -- LSP Configuration & Plugins
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },
      'folke/neodev.nvim',
    },
    config = function()
        require('mason').setup()
        
        -- Server list (dartls is handled separately because it is system-wide)
        local servers_config = {
            lua_ls = {
                Lua = {
                    workspace = { checkThirdParty = false },
                    telemetry = { enable = false },
                },
            },
            pyright = {},
        }
        
        local mason_ensures = {}
        for server, _ in pairs(servers_config) do
            table.insert(mason_ensures, server)
        end

        require('neodev').setup()

        local on_attach = function(_, bufnr)
            local nmap = function(keys, func, desc)
                if desc then desc = 'LSP: ' .. desc end
                vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
            end
            nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
            nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
            nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
            nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
            nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
            vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
                vim.lsp.buf.format()
            end, { desc = 'Format current buffer with LSP' })
        end

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

        -- Using the new modern API for nvim-lspconfig (0.11+)
        -- Ensure lspconfig is loaded for defaults
        require('lspconfig')

        require('mason-lspconfig').setup({
            ensure_installed = mason_ensures,
            handlers = {
                function(server_name)
                    local config = {
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = servers_config[server_name],
                        filetypes = (servers_config[server_name] or {}).filetypes,
                    }
                    vim.lsp.config(server_name, config)
                    vim.lsp.enable(server_name)
                end,
                -- Handle dartls manually within mason-lspconfig handlers
                ["dartls"] = function()
                    local config = {
                        capabilities = capabilities,
                        on_attach = on_attach,
                    }
                    vim.lsp.config("dartls", config)
                    vim.lsp.enable("dartls")
                end,
            }
        })
        
        -- Fallback setup for dartls if not handled by mason-lspconfig
        if not vim.tbl_contains(mason_ensures, "dartls") then
            local config = {
                capabilities = capabilities,
                on_attach = on_attach,
            }
            vim.lsp.config("dartls", config)
            vim.lsp.enable("dartls")
        end
    end
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'rafamadriz/friendly-snippets',
    },
    config = function()
        local cmp = require 'cmp'
        local luasnip = require 'luasnip'
        require('luasnip.loaders.from_vscode').lazy_load()
        luasnip.config.setup {}

        cmp.setup {
            snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
            mapping = cmp.mapping.preset.insert {
                ['<C-n>'] = cmp.mapping.select_next_item(),
                ['<C-p>'] = cmp.mapping.select_prev_item(),
                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete {},
                ['<CR>'] = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true },
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then cmp.select_next_item()
                    elseif luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump()
                    else fallback() end
                end, { 'i', 's' }),
            },
            sources = {
                { name = 'copilot' },
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
            },
        }
    end
  },

  -- Key helper
  { 'folke/which-key.nvim', opts = {} },

  -- Copilot & AI Agent
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function ()
      require("copilot_cmp").setup()
    end
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken",
    opts = {
      show_help = "yes",
      window = {
        layout = 'vertical', -- 'vertical', 'horizontal', 'float', 'replace'
        width = 0.3, -- fractional width of parent, or absolute width in columns when > 1
        height = 0.3, -- fractional height of parent, or absolute height in rows when > 1
        -- Options below only apply to floating windows
        relative = 'editor', -- 'editor', 'win', 'cursor', 'mouse'
        border = 'single', -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
        row = nil, -- row position of the window, default is centered
        col = nil, -- column position of the window, default is centered
        title = 'Copilot Chat', -- title of the window
        footer = nil, -- footer of the window
        zindex = 1, -- height in z-index of the window
      },
    },
    keys = {
      { "<leader>cc", ":CopilotChatToggle<cr>", desc = "Copilot Chat" },
      { "<leader>ce", ":CopilotChatExplain<cr>", desc = "Copilot Explain" },
      { "<leader>cf", ":CopilotChatFix<cr>", desc = "Copilot Fix" },
    },
  },

  -- Theme (TRANSPARENT CONFIG)
  {
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
        require('onedark').setup {
            style = 'dark',
            transparent = true 
        }
        vim.cmd.colorscheme 'onedark'
    end,
  },

  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = true,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  -- Comments
  { 'numToStr/Comment.nvim', opts = {} },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
    },
    config = function()
        require('telescope').setup {
            defaults = { mappings = { i = { ['<C-u>'] = false, ['<C-d>'] = false } } },
        }
        pcall(require('telescope').load_extension, 'fzf')
        
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
        vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
        vim.keymap.set('n', '<leader>/', function()
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 10, previewer = false,
            })
        end, { desc = '[/] Fuzzily search in current buffer' })
        vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
        vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
        vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    end
  },

  -- Treesitter (SAFE MODE)
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
        local status_ok, configs = pcall(require, 'nvim-treesitter.configs')
        if not status_ok then
            return
        end

        configs.setup {
          ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },
          auto_install = false,
          highlight = { enable = true },
          indent = { enable = true },
        }
    end
  },
  
  -- Autopairs (Auto close brackets)
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
  },

  -- Rainbow Delimiters (Colored brackets)
  {
    'HiPhish/rainbow-delimiters.nvim',
  },

  -- Formatting (Prettier / Black equivalent)
  {
    'stevearc/conform.nvim',
    opts = {
      notify_on_error = false,
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        javascript = { { "prettierd", "prettier" } },
        typescript = { { "prettierd", "prettier" } },
        javascriptreact = { { "prettierd", "prettier" } },
        typescriptreact = { { "prettierd", "prettier" } },
        json = { { "prettierd", "prettier" } },
        html = { { "prettierd", "prettier" } },
        css = { { "prettierd", "prettier" } },
        markdown = { { "prettierd", "prettier" } },
      },
    },
  },

  -- Markdown Preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },

  -- Icons
  'nvim-tree/nvim-web-devicons',

  -- Session Management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" } },
  },

  -- File Explorer (Nvim Tree)
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      -- Disable automatic opening
      local function on_attach(bufnr)
        local api = require('nvim-tree.api')
        local function opts(desc)
          return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        api.config.mappings.default_on_attach(bufnr)
      end

      require("nvim-tree").setup({
        on_attach = on_attach,
        sort_by = "case_sensitive",
        hijack_netrw = true,
        -- Disable auto-open on directory open (fixes 'nvim .' hijacking dashboard)
        hijack_directories = {
          enable = false,
        },
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
      })
      -- Keymap to toggle tree (Changed to 't' as requested)
      vim.keymap.set('n', 't', ':NvimTreeToggle<CR>', { desc = 'Toggle File Explorer' })
    end,
  },

  -- DASHBOARD
  {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false, -- Ensure it loads immediately
    config = function ()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        dashboard.section.header.val = {
            [[                                                                        ]],
            [[  |-|-|-|-|-|-|-|-|-|__________________________________________________/ ]],
            [[  | | | | | | | | | |                                                 /  ]],
            [[  '-'-'-'-'-'-'-'-'-'------------------------------------------------'   ]],
            [[                                                                        ]],
        }

        dashboard.section.buttons.val = {
            dashboard.button("f", "  Find File", ":Telescope find_files<CR>"),
            dashboard.button("n", "  New File", ":ene <BAR> startinsert <CR>"),
            dashboard.button("r", "  Recent Files", ":Telescope oldfiles<CR>"),
            dashboard.button("g", "  Find Text", ":Telescope live_grep<CR>"),
            dashboard.button("c", "  Config", ":e $MYVIMRC <CR>"),
            dashboard.button("s", "  Restore Session", [[<cmd>lua require("persistence").load()<cr>]]),
            dashboard.button("l", "璉 Lazy", ":Lazy<CR>"),
            dashboard.button("q", "  Quit", ":qa<CR>"),
        }
        
        local function footer() return "" end
        dashboard.section.footer.val = footer()
        alpha.setup(dashboard.config)
        
        -- Logic to force Dashboard even when opening a directory (nvim .)
        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                local should_skip = false
                if vim.fn.argc() > 0 or vim.fn.line2byte('$') ~= -1 or not vim.o.modifiable then
                    should_skip = true
                    -- Special case: If it's a directory, we WANT the dashboard
                    if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
                        should_skip = false
                    end
                end
                
                if not should_skip then
                    return
                end

                -- If it's a directory, clear the buffer and show Alpha
                if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
                    -- Change to the directory explicitly (just in case)
                    vim.cmd.cd(vim.fn.argv(0))
                    -- Start alpha
                    require("alpha").start(true)
                end
            end,
        })
    end
  },

}, {})

-- Options
vim.o.hlsearch = false
vim.o.number = true
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true

-- Basic Mappings
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank() end,
  group = highlight_group,
  pattern = '*',
})

-- Force Alpha Dashboard when opening a directory (nvim .)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      local dir = vim.fn.argv(0)
      vim.cmd('cd ' .. dir)
      
      -- Delay slightly to ensure UI is ready, then wipe and show dashboard
      vim.defer_fn(function()
        vim.cmd('bwipeout') -- Kill the directory buffer
        vim.cmd.enew()      -- Create a fresh empty buffer
        require("alpha").start(true)
      end, 20)
    end
  end,
})

-- RUN CODE SHORTCUT (<space>r)
vim.keymap.set("n", "<leader>r", function()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%")
  local cmd = ""

  if filetype == "python" then
    cmd = "python3 " .. filename
  elseif filetype == "javascript" or filetype == "typescript" then
    cmd = "node " .. filename
  elseif filetype == "sh" then
    cmd = "bash " .. filename
  elseif filetype == "go" then
    cmd = "go run " .. filename
  elseif filetype == "rust" then
    cmd = "cargo run"
  elseif filetype == "lua" then
    cmd = "lua " .. filename
  else
    print("Filetype not supported for auto-run: " .. filetype)
    return
  end

  -- Run in a split terminal
  vim.cmd("sp | term " .. cmd)
  -- Optional: Enter insert mode in terminal
  vim.cmd("startinsert")
end, { desc = "[R]un Code" })