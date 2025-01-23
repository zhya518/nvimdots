-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/jdtls.lua
-- https://github.com/mfussenegger/nvim-jdtls

local util = require("lspconfig.util")
local handlers = require("vim.lsp.handlers")

local env = {
	HOME = vim.loop.os_homedir(),
	XDG_CACHE_HOME = os.getenv("XDG_CACHE_HOME"),
	JDTLS_JVM_ARGS = os.getenv("JDTLS_JVM_ARGS"),
}

local function get_cache_dir()
	return env.XDG_CACHE_HOME and env.XDG_CACHE_HOME or env.HOME .. "/.cache"
end

local function get_jdtls_cache_dir()
	return get_cache_dir() .. "/jdtls"
end

local function get_jdtls_config_dir()
	return get_jdtls_cache_dir() .. "/config"
end

local function get_jdtls_workspace_dir()
	return get_jdtls_cache_dir() .. "/workspace"
end

-- jdtls requires at least Java 17
local function get_jdtls_java_executable()
	return string.format("--java-executable=%s", env.HOME .. "/opt/jdk21/bin/java")
end

local function get_jdtls_jvm_args()
	-- export JDTLS_JVM_ARGS="-javaagent:$HOME/.local/share/nvim/mason/packages/jdtls/lombok.jar"
	if env.JDTLS_JVM_ARGS then
		local args = {}
		for a in string.gmatch((env.JDTLS_JVM_ARGS or ""), "%S+") do
			local arg = string.format("--jvm-arg=%s", a)
			table.insert(args, arg)
		end
		return unpack(args)
	end
	return string.format(
		"--jvm-arg=%s",
		"-javaagent:" .. env.HOME .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar"
	)
end

-- TextDocument version is reported as 0, override with nil so that
-- the client doesn't think the document is newer and refuses to update
-- See: https://github.com/eclipse/eclipse.jdt.ls/issues/1695
local function fix_zero_version(workspace_edit)
	if workspace_edit and workspace_edit.documentChanges then
		for _, change in pairs(workspace_edit.documentChanges) do
			local text_document = change.textDocument
			if text_document and text_document.version and text_document.version == 0 then
				text_document.version = nil
			end
		end
	end
	return workspace_edit
end

local function on_textdocument_codeaction(err, actions, ctx)
	for _, action in ipairs(actions) do
		-- TODO: (steelsojka) Handle more than one edit?
		if action.command == "java.apply.workspaceEdit" then -- 'action' is Command in java format
			action.edit = fix_zero_version(action.edit or action.arguments[1])
		elseif type(action.command) == "table" and action.command.command == "java.apply.workspaceEdit" then -- 'action' is CodeAction in java format
			action.edit = fix_zero_version(action.edit or action.command.arguments[1])
		end
	end

	handlers[ctx.method](err, actions, ctx)
end

local function on_textdocument_rename(err, workspace_edit, ctx)
	handlers[ctx.method](err, fix_zero_version(workspace_edit), ctx)
end

local function on_workspace_applyedit(err, workspace_edit, ctx)
	handlers[ctx.method](err, fix_zero_version(workspace_edit), ctx)
end

-- Non-standard notification that can be used to display progress
local function on_language_status(_, result)
	local command = vim.api.nvim_command
	command("echohl ModeMsg")
	command(string.format('echo "%s"', result.message))
	command("echohl None")
end

-- Here you can configure eclipse.jdt.ls specific settings
-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
-- for a list of options
local function get_init_options_settings()
	return {
		-- REFERENCE https://sookocheff.com/post/vim/neovim-java-ide/
		java = {
			-- "home": "/usr/local/jdk-9.0.1",
			autobuild = { enabled = false },
			-- format = {
			-- 	settings = {
			-- 		-- Use Google Java style guidelines for formatting
			-- 		-- To use, make sure to download the file from https://github.com/google/styleguide/blob/gh-pages/eclipse-java-google-style.xml
			-- 		-- and place it in the ~/.local/share/eclipse directory
			-- 		url = "~/.local/share/eclipse/eclipse-java-google-style.xml",
			-- 		profile = "GoogleStyle",
			-- 	},
			-- },
			eclipse = { downloadSources = true },
			inlayhints = {
				parameterNames = {
					enabled = "all", -- none, literals, all
					exclusions = {},
				},
			},
			import = {
				gradle = { enabled = true },
				maven = { enabled = true },
				exclusions = {
					"**/node_modules/**",
					"**/.metadata/**",
					"**/archetype-resources/**",
					"**/META-INF/maven/**",
					"/**/test/**",
				},
			},
			maven = { downloadSources = true },
			implementationsCodeLens = { enabled = true },
			referencesCodeLens = { enabled = true },
			references = {
				includeAccessors = true,
				includeDecompiledSources = true,
			},
			signatureHelp = { enabled = true },
			contentProvider = { preferred = "fernflower" }, -- Use fernflower to decompile library code
			-- Specify any completion options
			completion = {
				favoriteStaticMembers = {
					"org.hamcrest.MatcherAssert.assertThat",
					"org.hamcrest.Matchers.*",
					"org.hamcrest.CoreMatchers.*",
					"org.junit.jupiter.api.Assertions.*",
					"java.util.Objects.requireNonNull",
					"java.util.Objects.requireNonNullElse",
					"org.mockito.Mockito.*",
					"org.junit.Assert.*",
					"org.junit.Assume.*",
					"org.junit.jupiter.api.Assertions.*",
					"org.junit.jupiter.api.Assumptions.*",
					"org.junit.jupiter.api.DynamicContainer.*",
					"org.junit.jupiter.api.DynamicTest.*",
				},
				filteredTypes = {
					"com.sun.*",
					"io.micrometer.shaded.*",
					"java.awt.*",
					"jdk.*",
					"sun.*",
				},
				importOrder = {
					"java",
					"javax",
					"com",
					"org",
				},
			},
			-- Specify any options for organizing imports
			sources = {
				organizeImports = {
					starThreshold = 9999,
					staticStarThreshold = 9999,
				},
			},
			-- How code generation should act
			codeGeneration = {
				toString = {
					template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
				},
				hashCodeEquals = {
					useJava7Objects = true,
				},
				useBlocks = true,
			},
			-- If you are developing in projects with different Java versions, you need
			-- to tell eclipse.jdt.ls to use the location of the JDK for your Java version
			-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
			-- And search for `interface RuntimeOption`
			-- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
			configuration = {
				-- Specifies how modifications on build files update the Java classpath/configuration default is 'interactive'
				updateBuildConfiguration = "interactive",
				maven = {
					-- Absolute path to Maven's settings.xml
					userSettings = env.HOME .. "/.m2/settings.xml",
					-- globalSettings = ""
					-- notCoveredPluginExecutionSeverity = ""
				},
				runtimes = {
					-- JavaSE-1.8
					{
						name = "JavaSE-11",
						path = env.HOME .. "/opt/jdk11",
						default = true,
					},
					{
						name = "JavaSE-17",
						path = env.HOME .. "/opt/jdk17",
					},
					{
						name = "JavaSE-21",
						path = env.HOME .. "/opt/jdk21",
					},
				},
			},
		},
	}
end

-- Language server `initializationOptions`
-- You need to extend the `bundles` with paths to jar files
-- if you want to use additional eclipse.jdt.ls plugins.
--
-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
--
-- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
local function get_init_options_bundles()
	local bundles = {}
	-- java-debug-adapter
	table.insert(
		bundles,
		vim.fn.glob(
			env.HOME
				.. "/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
			true
		)
	)
	-- java-test installation
	-- vim.list_extend(
	-- 	bundles,
	-- 	vim.split(
	-- 		vim.fn.glob(env.HOME .. "/.local/share/nvim/mason/packages/java-test/extension/server/*.jar", true),
	-- 		"\n"
	-- 	)
	-- )
	-- vscode-java-test installation
	-- https://github.com/microsoft/vscode-java-test
	-- https://github.com/mfussenegger/nvim-jdtls?tab=readme-ov-file#vscode-java-test-installation
	-- vim.list_extend(
	-- 	bundles,
	-- 	vim.split(vim.fn.glob(env.HOME .. "/opt/java/microsoft/vscode-java-test/server/*.jar", true), "\n")
	-- )

	-- java-debug installation
	-- https://github.com/microsoft/java-debug
	-- https://github.com/mfussenegger/nvim-jdtls?tab=readme-ov-file#java-debug-installation
	-- table.insert(
	-- 	bundles,
	-- 	vim.fn.glob(
	-- 		env.HOME
	-- 			.. "/opt/java/microsoft/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar",
	-- 		true
	-- 	)
	-- )
	return bundles
end

return {
	-- default_config = {
	cmd = {
		"jdtls",
		"-configuration",
		get_jdtls_config_dir(),
		"-data",
		get_jdtls_workspace_dir(),
		get_jdtls_java_executable(),
		get_jdtls_jvm_args(),
	},
	filetypes = { "java" },
	root_dir = function(fname)
		local root_files = {
			-- Multi-module projects
			{ ".git", "build.gradle", "build.gradle.kts" },
			-- Single-module projects
			{
				"build.xml", -- Ant
				"pom.xml", -- Maven
				"settings.gradle", -- Gradle
				"settings.gradle.kts", -- Gradle
			},
		}
		for _, patterns in ipairs(root_files) do
			local root = util.root_pattern(unpack(patterns))(fname)
			if root then
				return root
			end
		end
	end,
	single_file_support = true,
	init_options = {
		workspace = get_jdtls_workspace_dir(),
		jvm_args = {},
		os_config = nil,
		settings = get_init_options_settings(),
		bundles = get_init_options_bundles(),
	},
	handlers = {
		-- Due to an invalid protocol implementation in the jdtls we have to conform these to be spec compliant.
		-- https://github.com/eclipse/eclipse.jdt.ls/issues/376
		["textDocument/codeAction"] = on_textdocument_codeaction,
		["textDocument/rename"] = on_textdocument_rename,
		["workspace/applyEdit"] = on_workspace_applyedit,
		["language/status"] = vim.schedule_wrap(on_language_status),
	},
	-- },
	docs = {
		description = [[
https://projects.eclipse.org/projects/eclipse.jdt.ls

Language server for Java.

IMPORTANT: If you want all the features jdtls has to offer, [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)
is highly recommended. If all you need is diagnostics, completion, imports, gotos and formatting and some code actions
you can keep reading here.

For manual installation you can download precompiled binaries from the
[official downloads site](http://download.eclipse.org/jdtls/snapshots/?d)
and ensure that the `PATH` variable contains the `bin` directory of the extracted archive.

```lua
  -- init.lua
  require'lspconfig'.jdtls.setup{}
```

You can also pass extra custom jvm arguments with the JDTLS_JVM_ARGS environment variable as a space separated list of arguments,
that will be converted to multiple --jvm-arg=<param> args when passed to the jdtls script. This will allow for example tweaking
the jvm arguments or integration with external tools like lombok:

```sh
export JDTLS_JVM_ARGS="-javaagent:$HOME/.local/share/java/lombok.jar"
```

For automatic installation you can use the following unofficial installers/launchers under your own risk:
  - [jdtls-launcher](https://github.com/eruizc-dev/jdtls-launcher) (Includes lombok support by default)
    ```lua
      -- init.lua
      require'lspconfig'.jdtls.setup{ cmd = { 'jdtls' } }
    ```
    ]],
	},
}
