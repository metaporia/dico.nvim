---
--- *dico.nvim* Neovim wrapper for dico DICT client
---
--- MIT License Copyright (c) 2024 Keane Yahn-Krafft
---
--- ==============================================================================
---
--- Overview:
--- dico.nvim wraps the dico  DICT client. Its repository is located at
--- https://github.com/metaporia/dico.nvim and the (preferred) containerized
--- DICT server at https://gitlab.com/metaporia/dicod-docker.
---
--- Dependencies:
---
--- - dico (>2.4), and is best used with a local installation of a DICT server
---  (see above).
---
--- What it does:
--- - dico.nvim provides functions, keybindings, and commands to define and list
---   synonyms of words.
---
--- Setup:
--- - This module needs a `require('dico').setup({})`, where `{}` contains any
---   non-default config with which to override the default configuration.
---
---@toc
local M = {}

--- Module config
---
--- Default config:
---
---@class DicoOptions
---@field default_split string Whether to open definitions in vertical or
--- horizontal split. One of 'h' or 'v'. Defaults to 'h'.
---@field enable_nofile boolean Defaults to false.
---@field prefix string Prefix for mappings, defaults to <leader>
---
--- Initialize opts used to default. User set opts will be merged in `M.setup`.
--- @tag DicoOptions
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
--minidoc_replace_start opts = {
local default_opts = {
	--minidoc_replace_end
	default_split = "h", -- window split orientation
	enable_nofile = false, -- by default disable creating `Nofile` command
	map_prefix = "<leader>", -- default prefix for keymappings
}
--minidoc_afterlines_end

local opts = default_opts

---@private
local function merge_defaults(options)
	return vim.tbl_deep_extend("force", default_opts, options)
end

--- Toggle split orientation
---@private
local function toggle_orientation(o)
	if o == "h" then
		return "v"
	else
		return "h"
	end
end

--- Open scratch buf for definition
---@param orientation orientation
---@private
local function dead_buf(orientation)
	orientation = orientation or opts.default_split
	local vertical = false
	if orientation == "v" then
		vertical = true
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("ft", "dico", { buf = buf })
	vim.api.nvim_open_win(buf, true, { vertical = vertical })
	return buf
end

--- Open scratch buffer with synonyms of `word`. Takes optional `orientation`.
---@param word string Word to define
---@param orientation string? orientation. If nil, uses default or 'opts.default_split'
local function list_synonyms(word, orientation)
	orientation = orientation or opts.default_split
	local sedFilter =
		" | sed 's/,/\\n/g' | sed 's/\\s//g' | sed -e '/^[[:space:]]*$/d'"
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

--- Open definition of 'word' in a split (according to 'orientation', or, if
--- it's nil, 'opts.default_split'). Optionally pass a dico search strategy
--- with 'search_strategy'.
---
---@param word string
---@param orientation orientation
---@param search_strategy? string
---
local function define(word, orientation, search_strategy)
	orientation = orientation or opts.default_split
	-- handle optional param
	if search_strategy then
		search_strategy = "-s " .. search_strategy
	else
		search_strategy = ""
	end
	local query = "dico "
		.. search_strategy
		.. " '"
		.. word
		.. "'"
		.. " | fold"
	-- get definitions
	local definitions = vim.fn.systemlist(query)
	-- open scratch buffer
	local def_buf = dead_buf(orientation)
	-- write definitions to buffer
	vim.api.nvim_buf_set_lines(def_buf, 0, -1, false, definitions)
end

--- *Orientation*
---@alias orientation
---| '"h"' - horizontal split
---| '"v"' - vertical split

--list_synonyms("h", "hello")
--define("h", "pernicious")


---@text 
--- Commands ~
---                                                                          *:Def*
--- :Def {headword}
---            Define {headword} in split. Uses `opts.default_split` to determine 
---            whether split is horizontal or vertical.
--- 
---                                                                         *:DefA*
--- :DefA {headword}
---            Define {headword} in alternate split. 
---            If `opts.default_split = "h"`, then `:DefA` would open a vertical 
---            split.
--- 
---                                                                         *:Defs*
--- :LsSyn {headword}
---            List synonyms of {headword} (from moby-thesaurus by default) 
---            in horizontal split

-- TODO:
--
--                                                                         *:Defp*
-- :Defp {prefix}
--            List words with the specified {prefix}.
-- 


-- User commands
local function bind_nofile()
	vim.api.nvim_create_user_command("Nofile", function(_)
		dead_buf(opts.default_split)
	end, { nargs = 0 }) -- allow exactly zero arguments
end

local function bind_define()

	vim.api.nvim_create_user_command("Def", function(options)
		define(options.fargs[1], opts.default_split)
	end, { nargs = 1 }) -- allow exactly zero arguments

	vim.api.nvim_create_user_command("DefA", function(options)
		define(options.fargs[1], toggle_orientation(opts.default_split))
	end, { nargs = 1 }) -- allow exactly zero arguments


end

local function bind_list_synonyms()
	vim.api.nvim_create_user_command("LsSyn", function(options)
		list_synonyms(options.fargs[1], opts.default_split)
	end, { nargs = 1 }) -- allow exactly zero arguments
end

-- keymaps
local function set_keymaps(prefix)
	vim.keymap.set("n", prefix .. "dd", function()
		--vim.print(vim.fn.expand("<cWORD>"))
		define(vim.fn.expand("<cWORD>"), opts.default_split, nil)
	end, { desc = "Define <cWORD> (dico)" })

	vim.keymap.set("v", prefix .. "dd", function()
		define(get_selected_text(), opts.default_split)
	end, { desc = "Define visual selection" })

	vim.keymap.set("n", prefix .. "da", function()
		define(
			vim.fn.expand("<cWORD>"),
			toggle_orientation(opts.default_split)
		)
	end, { desc = "Define <cWORD> in alternate split (dico)" })

	vim.keymap.set("v", prefix .. "da", function()
		define(get_selected_text(), toggle_orientation(opts.default_split))
	end, { desc = "Define visual selection in alternate split (dico)" })

	vim.keymap.set("n", prefix .. "ds", function()
		list_synonyms(vim.fn.expand("<cWORD>"), opts.default_split)
	end, { desc = "List synonyms (dico)" })

	vim.keymap.set("v", prefix .. "ds", function()
		list_synonyms(get_selected_text(), opts.default_split)
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
  bind_list_synonyms()
	-- keymaps
	set_keymaps(opts.map_prefix)
end

--M.setup(default_opts)
M.define = define
M.list_synonyms = list_synonyms

return M
