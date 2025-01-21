-- return {}
local bind = require("keymap.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
-- local map_callback = bind.map_callback

local ui_map = {
	-- Plugin: bufferline
	["n|<leader>k"] = map_cr("BufferLineCycleNext"):with_noremap():with_silent():with_desc("buffer: Switch to next"),
	["n|<leader>j"] = map_cr("BufferLineCyclePrev"):with_noremap():with_silent():with_desc("buffer: Switch to prev"),
	["n|<leader>be"] = map_cr("BufferLineSortByExtension"):with_noremap():with_desc("buffer: Sort by extension"),
	["n|<leader>bd"] = map_cr("BufferLineSortByDirectory"):with_noremap():with_desc("buffer: Sort by direrctory"),

	-- Telescope
	["n|<leader>bb"] = map_cu("Telescope buffers"):with_noremap():with_silent():with_desc("find: Buffer opened"),

	-- Plugin: nvim-bufdel
	["n|<leader>bc"] = map_cr("BufDel"):with_noremap():with_silent():with_desc("buffer: Close current"),
	["n|<leader>bo"] = map_cr("BufDelOthers"):with_noremap():with_silent():with_desc("buffer: Close others"),
	["n|<leader>ba"] = map_cr("BufDelAll"):with_noremap():with_silent():with_desc("buffer: Close all"),

	["n|<leader>,h"] = map_cmd("<C-w>h"):with_noremap():with_desc("window: Focus left"),
	["n|<leader>,l"] = map_cmd("<C-w>l"):with_noremap():with_desc("window: Focus right"),
	["n|<leader>,j"] = map_cmd("<C-w>j"):with_noremap():with_desc("window: Focus down"),
	["n|<leader>,k"] = map_cmd("<C-w>k"):with_noremap():with_desc("window: Focus up"),
}
bind.nvim_load_mapping(ui_map)
