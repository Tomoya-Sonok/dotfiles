-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.mapleader = " "

vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.number = true -- Enable line numbers
vim.opt.mouse = "a" -- Enable mouse mode
vim.opt.autoindent = true -- Auto-indent new lines

vim.opt.title = true
vim.opt.smartindent = true -- Smart indentation
vim.opt.hlsearch = true
vim.opt.backup = false -- Don't create a backup file
vim.opt.showcmd = true
vim.opt.cmdheight = 1 -- Command line height
vim.opt.laststatus = 2 -- Show status bar
vim.opt.scrolloff = 8 -- Keep 8 lines above/below cursor
vim.opt.sidescrolloff = 8 -- Keep 8 columns to the left/right of cursor
vim.opt.inccommand = "split"
vim.opt.ignorecase = true -- Case-insensitive searching unless \C or capital in search
vim.opt.smarttab = true
vim.opt.breakindent = true -- Enable break indent
vim.opt.shiftwidth = 2 -- Spaces per indentation
vim.opt.tabstop = 2 -- Spaces for tab
vim.opt.wrap = false -- Display long lines as one line
vim.opt.backspace = { "start", "eol", "indent" } -- Configurable backspace behavior
vim.opt.path:append({ "**" })
vim.opt.wildignore:append({ "*/node_modules/*" })
vim.opt.splitbelow = true -- Horizontal splits below current window
vim.opt.splitright = true -- Vertical splits to the right
vim.opt.splitkeep = "cursor"
vim.opt.spelllang = { "en", "cjk" }
