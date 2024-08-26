local M = {}

---@class DicoOptions
---@field default_split string
---@field enable_nofile boolean
---@field prefix string prefix for mappings, defaults to <leader>

local default_opts = {
	default_split = "h",
	enable_nofile = false, -- by default disable creating `Nofile` command
	map_prefix = "<leader>",
}

local function merge_defaults(opts)
	return vim.tbl_deep_extend("force", default_opts, opts)
end

--- Initialize opts used to default. User set opts will be merged during
--- `M.setup`.
local opts = default_opts

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
	--vim.print("Opening read only buffer")
	local cmd = "new"
	if split_orientation == "v" then
		cmd = "rightbelow vnew"
	end
	vim.cmd(cmd)
	-- create 'nofile', ie, unwriteable, ephemeral buffer
	local buf = vim.api.nvim_get_current_buf()

	--vim.api.nvim_buf_set_name(buf, "dico")
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("swapfile", false, { buf = buf })

	return buf
end

local function dead_buf(orientation)
	local vertical = false
	if orientation == "v" then
		vertical = true
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("ft", "dico", { buf = buf })
	vim.api.nvim_open_win(buf, true, { vertical = vertical })
	return buf
end

--dead_buf("h")

---@param orientation orientation
---@param word string
---@param search_strategy string?
local function define(orientation, word, search_strategy)
	-- handle optional param
	if search_strategy then
		search_strategy = "-s " .. search_strategy
	else
		search_strategy = ""
	end
	local query = "dico " .. search_strategy .. " '" .. word .. "'" .. " | fold"
	-- get definitions
	local definitions = vim.fn.systemlist(query)
	-- open scratch buffer
	local def_buf = dead_buf(orientation)
	-- write definitions to buffer
	vim.api.nvim_buf_set_lines(def_buf, 0, -1, false, definitions)
end

local function list_synonyms(orientation, word)
	local sedFilter = " | sed 's/,/\\n/g' | sed 's/\\s//g' | sed -e '/^[[:space:]]*$/d'"
	print(sedFilter)
	local query = "dico " .. "-dmoby-thesaurus '" .. word .. "'" .. sedFilter
	local buf = dead_buf(orientation)
	local synonyms = vim.fn.systemlist(query)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, synonyms)
	vim.cmd.normal("gg4dj")
end

local function get_selected_text()
	local ss = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."))
	return table.concat(ss, "\n")
end

--list_synonyms("h", "hello")
--define("h", "pernicious")

-- User commands
local function bind_nofile()
	vim.api.nvim_create_user_command("Nofile", function(_)
		dead_buf("h")
	end, { nargs = 0 }) -- allow exactly zero arguments
end

local function bind_define()
	vim.api.nvim_create_user_command("Define", function(opts)
		define("h", opts.fargs[1])
	end, { nargs = 1 }) -- allow exactly zero arguments
end

-- keymaps
local function set_keymaps(prefix)
	vim.keymap.set("n", prefix .. prefix .. "dd", function()
		--vim.print(vim.fn.expand("<cWORD>"))
		define(opts.default_split, vim.fn.expand("<cWORD>"), nil)
	end, { desc = "Define <cWORD> (dico)" })

	vim.keymap.set("v", prefix .. prefix .. "dd", function()
    define(opts.default_split, get_selected_text())
	end, { desc = "Define visual selection" })

	vim.keymap.set("n", prefix .. prefix .. "dv", function()
		define("v", vim.fn.expand("<cWORD>"))
	end, { desc = "Define <cWORD> in vertical split (dico)" })

	vim.keymap.set("v", prefix .. prefix .. "dv", function()
		define("v", get_selected_text())
	end, { desc = "Define visual selection in vertical split (dico)" })

	vim.keymap.set("n", prefix .. prefix .. "ds", function()
		list_synonyms(opts.default_split, vim.fn.expand("<cWORD>"))
	end, { desc = "List synonyms (dico)" })

	vim.keymap.set("v", prefix .. prefix .. "ds", function()
		list_synonyms(opts.default_split, get_selected_text())
	end, { desc = "List synonyms of visual selection (dico)" })

end

--- Pass `DicoOptions` to `setup` in order to overrite default configuration.
---@param options DicoOptions
function M.setup(options)
	opts = merge_defaults(options or {})
	-- user commands
	if opts.enable_nofile then
		bind_nofile()
	end
	bind_define()
	-- keymaps
	set_keymaps(opts.map_prefix)
end

--M.setup(default_opts)
M.define = define
M.list_synonyms = list_synonyms

return M
