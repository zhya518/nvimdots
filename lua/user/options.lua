-- local options = {
-- 	-- Example
-- 	autoindent = true,
-- }

local options = {
	-- Example
	autoindent = true,
	-- 禁止相对行号
	number = true,
	relativenumber = false,
	-- 不记录回退文件
	undofile = false,
	-- 右侧参考线，超过表示代码太长了，考虑换行
	colorcolumn = "100",
	-- 行结尾可以跳到下一行
	whichwrap = "<,>,[,],~",
	-- 搜索大小写不敏感，除非包含大写
	ignorecase = true,
	smartcase = true,
	-- 搜索高亮
	hlsearch = true,
	-- 边输入边搜索
	incsearch = true,
	-- jk移动时光标下上方保留8行
	scrolloff = 8,
	sidescrolloff = 8,
	-- 补全最多显示10行
	pumheight = 10,
	-- 设置 timeoutlen 为等待键盘快捷键连击时间500毫秒，可根据需要设置
	-- 遇到问题详见：https://github.com/nshen/learn-neovim-lua/issues/1
	timeoutlen = 300,
	-- 禁止折行
	wrap = false,
	-- 是否显示不可见字符
	list = true,
	listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←",
}

local leader_map = function()
	vim.g.mapleader = ","
	vim.api.nvim_set_keymap("n", " ", "", { noremap = true })
	vim.api.nvim_set_keymap("x", " ", "", { noremap = true })
	-- local snippet_path = vim.fn.stdpath("config") .. "/snips/"
	-- require("luasnip.loaders.from_lua").lazy_load({ paths = snippet_path })
end
leader_map()

-- 在设置 clipboard 之后添加
-- clipboard = "unnamedplus" 会导致列粘贴失效
vim.api.nvim_create_autocmd("ModeChanged", {
	pattern = "*",
	callback = function()
		local mode = vim.fn.mode()
		-- 如果是可视块模式，禁用剪贴板同步
		if mode == "v" or mode == "V" or mode == "\22" then
			vim.opt.clipboard = ""
		else
			-- 其他模式恢复系统剪贴板
			vim.opt.clipboard = "unnamedplus"
		end
	end,
})

-- 确保列粘贴时正确设置
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		-- 如果是可视块模式复制的，恢复剪贴板设置
		if vim.v.event.regtype == "\22" then -- 可视块模式
			vim.opt.clipboard = "unnamedplus"
		end
	end,
})

-- 启动打开目录树
-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Open-At-Startup
local function open_nvim_tree(data)
	-- buffer is a directory
	local directory = vim.fn.isdirectory(data.file) == 1

	if not directory then
		return
	end
	-- create a new, empty buffer
	vim.cmd.enew()
	-- wipe the directory buffer
	vim.cmd.bw(data.buf)
	-- change to the directory
	vim.cmd.cd(data.file)
	-- open the tree
	require("nvim-tree.api").tree.open()
end
-- vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

return options
