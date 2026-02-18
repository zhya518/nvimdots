-- return {}
local bind = require("keymap.bind")
local map_cr = bind.map_cr
-- local map_cu = bind.map_cu
-- local map_cmd = bind.map_cmd
-- local map_callback = bind.map_callback

local tool_map = {
	-- Plugin: trouble
	["n|gt"] = map_cr("Trouble diagnostics toggle"):with_noremap():with_silent():with_desc("lsp: Toggle trouble list"),
	["n|<leader>lw"] = map_cr("Trouble diagnostics toggle")
		:with_noremap()
		:with_silent()
		:with_desc("lsp: Show workspace diagnostics"),
	["n|<leader>lp"] = map_cr("Trouble project_diagnostics toggle")
		:with_noremap()
		:with_silent()
		:with_desc("lsp: Show project diagnostics"),
	["n|<leader>ld"] = map_cr("Trouble diagnostics toggle filter.buf=0")
		:with_noremap()
		:with_silent()
		:with_desc("lsp: Show document diagnostics"),
}
bind.nvim_load_mapping(tool_map)
