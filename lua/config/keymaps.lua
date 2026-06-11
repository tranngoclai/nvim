-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function delete_file_buffer_without_closing_explorer()
  local current = vim.api.nvim_get_current_buf()
  local current_ft = vim.bo[current].filetype

  if not vim.startswith(current_ft, "snacks_picker") then
    Snacks.bufdelete(current)
    return
  end

  local file_buffers = vim.tbl_filter(function(buf)
    return vim.bo[buf].buflisted
      and vim.bo[buf].buftype == ""
      and not vim.startswith(vim.bo[buf].filetype, "snacks_picker")
  end, vim.api.nvim_list_bufs())

  table.sort(file_buffers, function(a, b)
    local a_info = vim.fn.getbufinfo(a)[1]
    local b_info = vim.fn.getbufinfo(b)[1]
    return (a_info and a_info.lastused or 0) > (b_info and b_info.lastused or 0)
  end)

  if file_buffers[1] then
    Snacks.bufdelete(file_buffers[1])
  end
end

vim.keymap.set("n", "W", delete_file_buffer_without_closing_explorer, { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New Buffer" })
vim.keymap.set("n", "N", "<cmd>enew<cr>", { desc = "New Buffer" })
