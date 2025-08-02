-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ALREADY CONFIGURED
-- Space = :
-- map("n", "<space>", ":", { noremap = true })

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Back to last position
map("n", "<leader>\\", "``", opts)

-- Print file
map("n", "<leader>p", ":%w !lp<CR>", opts)

-- Exit insert with jk
map("i", "jk", "<Esc>", opts)

-- New line in normal mode without insert
map("n", "o", "o<esc>", opts)
map("n", "O", "O<esc>", opts)

-- Yank to end of line
map("n", "Y", "y$", opts)

-- Go to the end of line
map("n", "ß", "$")
map("v", "ß", "$")
map("o", "ß", "$")

-- Enable Ctrl+C to copy to system clipboard in visual mode
map("v", "<C-c>", '"+y', opts)

-- Run Python file
map("n", "<F5>", ":w<CR>:!clear<CR>:!python3 %<CR>", opts)

---- WINDOW MANAGEMENT
-- Map <C-ö> to vertical split
map("n", "<C-ö>", ":vsplit<CR>", { desc = "Vertical Split", noremap = true })

-- Map <C-ä> to horizontal split
map("n", "<C-ä>", ":split<CR>", { desc = "Horizontal Split", noremap = true })

-- Map <C-W> to close buffers
map("n", "<C-o>", ":bd<CR>", { desc = "Close Buffer" })
-- Map <C-i> to close windows
map("n", "<C-i>", ":close<CR>", { desc = "Close Window", noremap = true })

-- Create a new tab in the current dir with user input for filename
map("n", "<leader>t", [[:tabnew %:p:h/<C-R>=input('New file name: ')<CR><CR>]], opts)

-- Open the directory in a new tab
map("n", "<leader>p", ":tabnew | cd %:p:h | Ex<CR>", opts)

-- Window navigation
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Window resizing
map("n", "<C-Up>", "<C-w>+", opts)
map("n", "<C-Down>", "<C-w>-", opts)
map("n", "<C-Left>", "<C-w>>", opts)
map("n", "<C-Right>", "<C-w><", opts)

-- NOT USED ANYMORE
---- -- Center search result
-- map("n", "n", "nzz", opts)
-- map("n", "N", "Nzz", opts)

-- Conflict with visual block
-- -- Enable Ctrl+V to paste from system clipboard in normal and insert mode
-- map("n", "<C-v>", '"+p', opts)
-- map("i", "<C-v>", "<C-r>+", opts)
--
