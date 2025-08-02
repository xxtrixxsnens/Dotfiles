return {
  "tpope/vim-fugitive",
  config = function()
    vim.keymap.set("n", "<leader>gg", function()
      vim.cmd("tabnew | G")
    end, { desc = "Fugitive Git Status (tab)" })

    vim.keymap.set("n", "<leader>gD", ":Gvdiffsplit<CR>", { desc = "Git Vertical Diff" })

    -- Commit
    vim.keymap.set("n", "<leader>gm", ":Git commit", { desc = "Commit" })
  end,
}
