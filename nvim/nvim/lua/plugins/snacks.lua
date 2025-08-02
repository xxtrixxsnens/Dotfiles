return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        hidden = true, -- for hidden files
        ignored = true, -- for .gitignore files
      },
      grep = {
        additional_args = function()
          return { "--hidden", "--glob", "!.git/*" }
        end,
      },
    },
  },
}
