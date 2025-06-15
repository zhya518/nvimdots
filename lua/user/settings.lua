-- Please check `lua/core/settings.lua` to view the full list of configurable settings
local settings = {}

-- Examples
settings["use_ssh"] = true

-- Set it to false if you don't use copilot
---@type boolean
settings["use_copilot"] = false

-- custom snippets paths for luasnip.
---@type table<string, string>
settings["snippets"] = {
	snipmate = "~/.config/nvim/lua/user/snips/custom/snippets",
	vscode = "~/.config/nvim/lua/user/snips/custom/vscode",
	luasnippets = "~/.config/nvim/lua/user/snips/custom/luasnippets",
}

-- Set the colorscheme to use here.
-- Available values are: `catppuccin`, `catppuccin-latte`, `catppucin-mocha`, `catppuccin-frappe`, `catppuccin-macchiato`.
---@type string
settings["colorscheme"] = "catppuccin"

-- Filetypes in this list will skip lsp formatting if rhs is true.
---@type table<string, boolean>
settings["formatter_block_list"] = {
	lua = false, -- example
	yaml = true,
	sh = false,
	json = false,
	java = true,
}

-- Set the language servers that will be installed during bootstrap here.
-- check the below link for all the supported LSPs:
-- https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/server_configurations
---@type string[]
settings["lsp_deps"] = {
	-- "bashls",
	-- "clangd",
	-- "html",
	-- "jsonls",
	-- "lua_ls",
	-- "pylsp",
	"gopls",
	--"jdtls",
	--"java_language_server",
}

-- TODO: check env
-- supported python need to install python<version>-venv
-- For example, apt install python3.8-venv
-- apt install python3.8-venv

-- Set the general-purpose servers that will be installed during bootstrap here.
-- Check the below link for all supported sources.
-- in `code_actions`, `completion`, `diagnostics`, `formatting`, `hover` folders:
-- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins
---@type string[]
settings["null_ls_deps"] = {
	-- "clang_format",
	"gofumpt",
	"goimports",
	-- "prettier",
	"shfmt",
	"stylua",
	-- "vint",
	--"google_java_format.lua",
}

-- Set the Debug Adapter Protocol (DAP) clients that will be installed and configured during bootstrap here.
-- Check the below link for all supported DAPs:
-- https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
---@type string[]
settings["dap_deps"] = {
	-- "codelldb", -- C-Family
	"delve", -- Go
	"python", -- Python (debugpy)
	--"javadbg",
	--"javatest",
}

-- Set the Treesitter parsers that will be installed during bootstrap here.
-- Check the below link for all supported languages:
-- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
---@type string[]
-- unused, you can edit core.settings.treesitter_deps
-- recursively merge src into dst, cannot remove values
settings["treesitter_deps"] = {}

-- Set it to false if you want to turn off LSP Inlay Hints
---@type boolean
settings["lsp_inlayhints"] = true

-- Set it to false if diagnostics virtual text is annoying.
-- If disabled, you may browse lsp diagnostics using trouble.nvim (press `gt` to toggle it).
---@type boolean
settings["diagnostics_virtual_text"] = false

-- Set it to one of the values below if you want to change the visible severity level of lsp diagnostics.
-- Priority: `Error` > `Warning` > `Information` > `Hint`.
--  > e.g. if you set this option to `Warning`, only lsp warnings and errors will be shown.
-- NOTE: This entry only works when `diagnostics_virtual_text` is true.
settings["diagnostics_level"] = "HINT"

-- Set the plugins to disable here.
-- Example: "Some-User/A-Repo"
---@type string[]
settings["disabled_plugins"] = {}

return settings
