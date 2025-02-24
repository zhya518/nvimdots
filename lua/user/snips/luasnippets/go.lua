-- DOCS:
-- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#snippets
--
-- GLOBAL VARS:
-- https://github.com/L3MON4D3/LuaSnip/blob/69cb81cf7490666890545fef905d31a414edc15b/lua/luasnip/config.lua#L82-L104§

local session = require("luasnip.session")

local env = session.config.snip_env
local s = env["s"]
local t = env["t"]
local i = env["i"]
local parse = env["parse"]

-- local l = extras.l
local postfix = require("luasnip.extras.postfix").postfix
local matches = require("luasnip.extras.postfix").matches
local f = env["f"]
local l = env["l"]

local camelToSnake = function(str)
	return (str:gsub("%u", "_%1"):lower():gsub("^_", ""))
end

local lowerFirst = function(str)
	return (str:gsub("^%u", string.lower))
end
local snakeToCamel = function(str)
	if str == nil then
		return ""
	end
	return (str:gsub("_(.)", function(c)
		return c:upper()
	end))
end

-- Function to split a string by a delimiter and trim each resulting substring
local splitAndTrim = function(str, delimiter)
	local result = {}
	local pattern = "[^" .. delimiter .. "]+"
	for match in str:gmatch(pattern) do
		table.insert(result, match:match("^%s*(.-)%s*$")) -- Trim leading and trailing whitespace
	end
	return result
end

local util = require("luasnip.util.util")
local firstWord = function()
	-- local line = vim.api.nvim_get_current_line()
	local line = util.get_current_line_to_cursor()
	local result = splitAndTrim(line, " ")
	return result[1]
end
-- -- Example usage:
-- local str = "  hello  world  "
-- local delimiter = " "
-- local substrings = splitAndTrim(str, delimiter)
--
-- for i, substring in ipairs(substrings) do
--     print(substring)
-- end
-- Example usage:
-- local snakeCaseString = "lua_下划线_转驼峰"
-- local camelCaseString = snakeToCamel(snakeCaseString)
-- print(camelCaseString)
-- Example usage:
-- local camelCaseString = "lua驼峰转下划线"
-- local snakeCaseString = camelToSnake(camelCaseString)
-- print(snakeCaseString)

return {
	postfix(".jso", {
		f(function(_, parent)
			return parent.snippet.env.POSTFIX_MATCH .. " "
		end, {}),
		i(1, "Type"),
		f(function(_, parent)
			return ' `json:"' .. lowerFirst(snakeToCamel(parent.snippet.env.POSTFIX_MATCH)) .. ',omitempty"`'
		end, {}),
	}),
	postfix(".jsg", {
		f(function(_, parent)
			return parent.snippet.env.POSTFIX_MATCH .. " "
		end, {}),
		i(1, "Type"),
		f(function(_, parent)
			return ' `json:"'
				.. lowerFirst(snakeToCamel(parent.snippet.env.POSTFIX_MATCH))
				.. ',omitempty"'
				.. ', gorm:"column:'
				.. lowerFirst(snakeToCamel(parent.snippet.env.POSTFIX_MATCH))
				.. '"`'
		end, {}),
	}),
	s({ trig = "jso", name = "Constant", dscr = "Insert a constant" }, {
		t(' `json:"' .. lowerFirst(snakeToCamel(firstWord())) .. ',omitempty"`'),
	}),
	s({ trig = "co", name = "Constant", dscr = "Insert a constant" }, {
		t("const "),
		i(1, "name"),
		t(" = "),
		i(2, "value"),
	}),
	s({ trig = "pf", name = "Formatted Print", dscr = "Insert a formatted print statement" }, {
		t('fmt.Printf("%#v\\n", '),
		i(1, "value"),
		t(")"),
	}),

	parse(
		{ trig = "ife", name = "If Err", dscr = "Insert a basic if err not nil statement" },
		[[
  if err != nil {
    return err
  }
  ]]
	),

	parse(
		{ trig = "ifel", name = "If Err Log Fatal", dscr = "Insert a basic if err not nil statement with log.Fatal" },
		[[
  if err != nil {
    log.Fatal(err)
  }
  ]]
	),

	s({ trig = "ifew", name = "If Err Wrapped", dscr = "Insert a if err not nil statement with wrapped error" }, {
		t("if err != nil {"),
		t({ "", '  return fmt.Errorf("failed to ' }),
		i(1, "message"),
		t(': %w", err)'),
		t({ "", "}" }),
	}),

	parse(
		{ trig = "ma", name = "Main Package", dscr = "Basic main package structure" },
		[[
  package main

  import "fmt"

  func main() {
    fmt.Printf("%+v\n", "...")
  }
  ]]
	),
}
