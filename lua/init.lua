local M = {}

---@class DicoOptions
---@field default_split string

-- Open unwritable buffer in horizontal or vertical split according to the 
-- orientation:
--   * "v" sets vertical
--   * otherwise defaults to horizontal
--
---@alias orientation
---| '"h"' # horizontal split
---| '"v"' # vertical split
---@param split_orientation orientation
local function read_only_buffer(split_orientation) 
  local cmd = "new"
  if split_orientation == 'h' then
    cmd = "rightbelow vnew"
  end
  -- create 'nofile', ie, unwriteable, ephemeral buffer
  vim.api.nvim_command(cmd .. "| setlocal buftype=nofile | setlocal noswapfile")
end

local function bind_nofile()
  vim.api.nvim_create_user_command("Nofile", function(_)
    read_only_buffer("h")
  end, { nargs = 0 }) -- allow exactly zero arguments
end

---@param opts DicoOptions
function M.setup(_) 
  bind_nofile()
end


return M
