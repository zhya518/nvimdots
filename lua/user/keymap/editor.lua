-- return {}

local bind = require("keymap.bind")
-- local map_cr = bind.map_cr
-- local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
-- local map_callback = bind.map_callback

local edit_map = {
	["i|jj"] = map_cmd("<Esc>"):with_desc("edit: Esc"),
	["i|<leader>i"] = map_cmd("<Esc>"):with_desc("edit: Esc"),
}
bind.nvim_load_mapping(edit_map)
