return {
  "mg979/vim-visual-multi",
  branch = "master",
  event = "VeryLazy",
  init = function()
    -- Use default mappings; <C-n> to select word/next occurrence
    vim.g.VM_maps = {
      ["Find Under"] = "<C-n>",
      ["Find Subword Under"] = "<C-n>",
      ["Select All"] = "<C-S-n>",
      ["Add Cursor Down"] = "<C-A-j>",
      ["Add Cursor Up"] = "<C-A-k>",
    }
  end,
}
