return function()
	local vim_path = require("core.global").vim_path
	local snippet_path = vim_path .. "/snips/"
	local user_snippet_path = vim_path .. "/lua/user/snips/"
	local settings = require("core.settings")
	local snippets = settings.snippets

	require("modules.utils").load_plugin("luasnip", {
		history = true,
		update_events = "TextChanged,TextChangedI",
		delete_check_events = "TextChanged,InsertLeave",
	}, false, require("luasnip").config.set_config)

	local user_vscode_paths = { snippet_path, user_snippet_path }
	if snippets["vscode"] then
		table.insert(user_vscode_paths, snippets["vscode"])
	end
	require("luasnip.loaders.from_vscode").lazy_load({
		paths = user_vscode_paths,
	})

	local user_snipmate_paths = { vim_path .. "/lua/user/snips/snippets" }
	if snippets["snipmate"] then
		table.insert(user_snipmate_paths, snippets["snipmate"])
	end
	require("luasnip.loaders.from_snipmate").lazy_load({
		paths = user_snipmate_paths,
	})

	local user_luasnippets_paths = { vim_path .. "/lua/user/snips/luasnippets" }
	if snippets["luasnippets"] then
		table.insert(user_luasnippets_paths, snippets["luasnippets"])
	end
	require("luasnip.loaders.from_lua").lazy_load({
		paths = user_luasnippets_paths,
	})
end
