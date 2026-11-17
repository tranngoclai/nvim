-- Image/PDF viewer via Kitty Graphics Protocol (works in ghostty, kitty).
-- Needs ImageMagick (`magick`) for conversion and ghostscript (`gs`) for PDF.
-- Video formats are omitted: brew's ffmpeg has no libwebp encoder, which
-- ImageMagick's video:decode delegate requires.
return {
  "folke/snacks.nvim",
  opts = {
    -- LazyVim already enables bigfile; lower the threshold and cut more features.
    -- Big buffers get filetype=bigfile: no treesitter/LSP, plain syntax only.
    bigfile = {
      enabled = true,
      size = 512 * 1024, -- 512KB (default 1.5MB)
      line_length = 500, -- avg line length, catches minified/log files
      setup = function(ctx)
        vim.cmd("NoMatchParen")
        Snacks.util.wo(0, {
          foldmethod = "manual",
          statuscolumn = "",
          conceallevel = 0,
          cursorline = false,
          list = false,
          spell = false,
        })
        vim.b.completion = false
        vim.b.minianimate_disable = true
        vim.bo[ctx.buf].swapfile = false
        vim.bo[ctx.buf].undolevels = -1 -- no undo history for huge files
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ctx.buf) then
            vim.bo[ctx.buf].syntax = ctx.ft
          end
        end)
      end,
    },
    image = {
      enabled = true,
      formats = {
        "png", "jpg", "jpeg", "gif", "bmp", "webp",
        "tiff", "heic", "avif", "pdf", "icns",
      },
      doc = { inline = true, max_width = 80, max_height = 40 },
    },
  },
  -- snacks has no "center" option for image buffers (filetype=image), so wrap
  -- Snacks.image.buf.attach and recompute the placement position on every update:
  --   col: pos[2] -> virt_text_win_col offset (horizontal centering)
  --   row: pad the (non-modifiable) image buffer with blank lines, then pos[1] = pad + 1
  init = function()
    local function center(placement)
      local win = placement:wins()[1]
      if not win then
        return
      end
      local size = placement:state().loc
      local info = vim.fn.getwininfo(win)[1]
      local text_w = info.width - info.textoff
      local col = math.max(0, math.floor((text_w - size.width) / 2))
      local pad = math.max(0, math.floor((info.height - size.height) / 2))
      local buf = placement.buf
      if vim.api.nvim_buf_line_count(buf) ~= pad + 1 then
        local lines = {}
        for i = 1, pad + 1 do
          lines[i] = ""
        end
        vim.bo[buf].modifiable = true
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false
        vim.bo[buf].modified = false
      end
      placement.opts.pos = { pad + 1, col }
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      once = true,
      callback = function()
        local buf_mod = Snacks.image.buf
        local attach = buf_mod.attach
        buf_mod.attach = function(buf, opts)
          opts = opts or {}
          opts.on_update_pre = center
          return attach(buf, opts)
        end
      end,
    })
  end,
}
