-- cursor_recorder/init.lua
-- =====================================
-- A minimal, buffer‑aware jump/rewind plugin
-- -------------------------------------
--   * Records every cursor move / buffer switch in “normal” buffers
--   * Skips explorers, terminals, prompts, quickfix, etc.
--   * Provides jump_back / jump_forward helpers
--   * Avoids self‑recording via an `in_jump` guard
--   * Emits simple notify messages that show (index / size)
--
-- Public API
-- ~~~~~~~~~~
--   require("custom.cursor_recorder").setup({                             -- opts optional
--     ignore_ft    = { "neo-tree", "fzf", "TelescopePrompt" },         -- extra filetypes to skip
--     max_entries  = 500,                                                  -- ring‑buffer cap
--   })
--   vim.keymap.set("n", "<C-b>", require("custom.cursor_recorder").jump_back)
--   vim.keymap.set("n", "<C-f>", require("custom.cursor_recorder").jump_forward)
--
-----------------------------------------------------------------------------
local M = {}

-- state --------------------------------------------------------------------
local history     = {}       ---@type {buf:integer, lnum:integer, col:integer}[]
local idx         = 0        ---current position (1‑based)
local in_jump     = false    ---guard to avoid self‑recording
local opts        = {
  ignore_buftype = {             -- buftypes we never record
    "nofile", "help", "quickfix", "terminal", "prompt",
  },
  ignore_ft      = {},           -- extra filetypes, user‑extendable
  max_entries    = 500,
}

local function list_to_set(list)
  local set = {}
  for _, v in ipairs(list) do set[v] = true end
  return set
end

local function should_skip(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return true end
  local bt = vim.bo[buf].buftype
  if opts._buftype_set[bt] then return true end
  local ft = vim.bo[buf].filetype
  if opts._ft_set[ft] then return true end
  return false
end

-- core: push current position into history -------------------------------
local function push()
  if in_jump then return end               -- do not record programmatic jumps

  local buf = vim.api.nvim_get_current_buf()
  if should_skip(buf) then return end

  local pos = vim.api.nvim_win_get_cursor(0) -- {lnum, col}
  local entry = { buf = buf, lnum = pos[1], col = pos[2] }

  -- deduplicate (skip if identical to last)
  local last = history[#history]
  if last and last.buf == entry.buf and last.lnum == entry.lnum and last.col == entry.col then
    return
  end

  -- truncate forward branch if we’re not at the end
  if idx < #history then
    for i = #history, idx + 1, -1 do
      history[i] = nil
    end
  end

  -- cap size (ring‑buffer behaviour)
  if #history >= opts.max_entries then
    table.remove(history, 1)
    if idx > 0 then idx = idx - 1 end
  end

  table.insert(history, entry)
  idx = #history
end

-- jump helpers ------------------------------------------------------------
local function goto_entry(i)
  local ent = history[i]
  if not ent or not vim.api.nvim_buf_is_valid(ent.buf) then return end
  in_jump = true
  if vim.api.nvim_get_current_buf() ~= ent.buf then
    vim.api.nvim_set_current_buf(ent.buf)
  end
  vim.api.nvim_win_set_cursor(0, { ent.lnum, ent.col })
  vim.schedule(function() in_jump = false end)    -- release guard after event flush
end

function M.jump_back()
  if idx <= 1 then return end
  idx = idx - 1
  goto_entry(idx)
  --vim.notify(string.format("[cursor_recorder] ← %d / %d", idx, #history), vim.log.levels.INFO)
end

function M.jump_forward()
  if idx >= #history then return end
  idx = idx + 1
  goto_entry(idx)
  --vim.notify(string.format("[cursor_recorder] → %d / %d", idx, #history), vim.log.levels.INFO)
end

-- setup / autocommands ----------------------------------------------------
function M.setup(user_opts)
  if user_opts then opts = vim.tbl_deep_extend("force", opts, user_opts) end
  opts._buftype_set = list_to_set(opts.ignore_buftype)
  opts._ft_set      = list_to_set(opts.ignore_ft)

  -- clear & create augroup
  local grp = vim.api.nvim_create_augroup("CursorRecorder", { clear = true })
  vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter" }, {
    group = grp,
    callback = push,
  })

  -- prime with initial location
  push()
end

return M

