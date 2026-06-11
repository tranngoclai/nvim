local function has_modified_file_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and vim.bo[buf].modified then
      return true
    end
  end
  return false
end

local function refresh_bufferline()
  local ok, bufferline_ui = pcall(require, "bufferline.ui")
  if ok then
    bufferline_ui.refresh()
  end
end

local function open_project_explorer()
  vim.schedule(function()
    Snacks.explorer({ cwd = vim.fn.getcwd() })
    refresh_bufferline()
  end)
end

local function is_in_projects_dir(path)
  local projects = vim.fs.normalize(vim.fn.expand("~/Projects"))
  local cwd = vim.fs.normalize(path or vim.fn.getcwd(-1, -1))

  return cwd == projects or vim.startswith(cwd, projects .. "/")
end

local function close_project_explorers()
  if not Snacks or not Snacks.picker then
    return
  end

  local ok, pickers = pcall(Snacks.picker.get, { source = "explorer", tab = false })
  if not ok then
    return
  end

  for _, picker in ipairs(pickers) do
    pcall(function()
      picker:close()
    end)
  end
end

local function toggle_project_explorer()
  if Snacks and Snacks.picker then
    local ok, pickers = pcall(Snacks.picker.get, { source = "explorer", tab = false })
    if ok and #pickers > 0 then
      close_project_explorers()
      refresh_bufferline()
      return
    end
  end

  open_project_explorer()
end

local function switch_project(picker, item)
  if not item then
    return
  end

  if has_modified_file_buffers() then
    Snacks.notify.warn("Save modified buffers before switching projects")
    return
  end

  picker:close()
  vim.fn.chdir(item.file)
end

return {
  {
    "folke/persistence.nvim",
    enabled = false,
  },
  {
    "tiagovla/scope.nvim",
    lazy = false,
    config = true,
  },
  {
    "rmagatti/auto-session",
    lazy = false,
    dependencies = { "tiagovla/scope.nvim" },
    init = function()
      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = vim.api.nvim_create_augroup("close_project_explorer_before_session_save", { clear = true }),
        callback = close_project_explorers,
      })
    end,
    keys = {
      { "<leader>qs", "<cmd>AutoSession restore<cr>", desc = "Restore Session" },
      { "<leader>qS", "<cmd>AutoSession search<cr>", desc = "Select Session" },
      { "<leader>qw", "<cmd>AutoSession save<cr>", desc = "Save Session" },
      { "<leader>qd", "<cmd>AutoSession toggle<cr>", desc = "Toggle Autosave" },
    },
    opts = {
      auto_save = true,
      auto_restore = true,
      auto_create = function()
        return is_in_projects_dir()
      end,
      cwd_change_handling = true,
      bypass_save_filetypes = { "snacks_dashboard" },
      close_filetypes_on_save = { "checkhealth", "snacks_picker" },
      close_unsupported_windows = false,
      session_lens = {
        picker = "snacks",
      },
      pre_save_cmds = {
        close_project_explorers,
        "ScopeSaveState",
      },
      post_restore_cmds = {
        "ScopeLoadState",
        open_project_explorer,
      },
      no_restore_cmds = {
        open_project_explorer,
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            win = {
              input = {
                keys = {
                  ["<Esc>"] = false,
                  ["<C-c>"] = false,
                  ["q"] = false,
                },
              },
              list = {
                keys = {
                  ["<Esc>"] = false,
                  ["q"] = false,
                },
              },
              preview = {
                keys = {
                  ["<Esc>"] = false,
                  ["q"] = false,
                },
              },
            },
          },
          projects = {
            dev = {
              "~/Projects",
            },
            confirm = switch_project,
            max_depth = 4,
          },
        },
      },
    },
    keys = {
      {
        "<leader>e",
        toggle_project_explorer,
        desc = "Toggle Explorer",
      },
      {
        "<leader>fp",
        function()
          Snacks.picker.projects()
        end,
        desc = "Find Project",
      },
      {
        "<leader>fP",
        function()
          Snacks.picker.recent()
        end,
        desc = "Find Recent File",
      },
    },
  },
}
