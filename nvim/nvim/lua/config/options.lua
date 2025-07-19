-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- General settings
vim.opt.number = true
vim.opt.cursorline = true
-- vim.opt.cursorcolumn = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
-- vim.opt.scrolloff = 10
-- vim.opt.wrap = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showcmd = true
vim.opt.showmode = true
vim.opt.showmatch = true
vim.opt.hlsearch = true
vim.opt.history = 1000
vim.opt.wildmenu = true
vim.opt.wildmode = { "longest:full", "full" }

-- Persistent undo
vim.opt.undodir = vim.fn.expand("~/.vim/backup")
vim.opt.undofile = true
vim.opt.undoreload = 10000

-- Folding for Vim files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "vim",
  callback = function()
    vim.opt_local.foldmethod = "marker"
  end,
})

-- HTML file indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = "html",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- Show cursorline only in active window
vim.api.nvim_create_augroup("cursor_off", { clear = true })
vim.api.nvim_create_autocmd("WinLeave", {
  group = "cursor_off",
  callback = function()
    vim.opt_local.cursorline = false
    vim.opt_local.cursorcolumn = false
  end,
})
vim.api.nvim_create_autocmd("WinEnter", {
  group = "cursor_off",
  callback = function()
    vim.opt_local.cursorline = true
    vim.opt_local.cursorcolumn = true
  end,
})

-- Statusline
vim.opt.statusline = " %F %M %Y %R %= ascii: %b hex: 0x%B row: %l col: %c percent: %p%%"
vim.opt.laststatus = 2
