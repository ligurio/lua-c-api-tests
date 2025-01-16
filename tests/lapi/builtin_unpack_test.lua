--[=[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html

Returns the type of its only argument, coded as a string.
The possible results of this function are "nil"
(a string, not the value nil), "number", "string",
"boolean", "table", "function", "thread", and "userdata".

lua_checkstack may have arithmetic overflow for large 'size',
https://www.lua.org/bugs.html#5.1.3-3

unpack with maximum indices may crash due to arithmetic overflow,
https://www.lua.org/bugs.html#5.1.3-4

Fix overflow check in unpack(),
https://github.com/LuaJIT/LuaJIT/pull/574

Synopsis: unpack(list [, i [, j]])
]]=]

local luzer = require("luzer")
local test_lib = require("lib")

local unpack = unpack or table.unpack
local MAX_INT = test_lib.MAX_INT

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)

    local str = fdp:consume_string(test_lib.MAX_STR_LEN)
    local str_chars = {}
    str:gsub(".", function(c) table.insert(str_chars, c) end)

    -- By default, `i` is 1 and `j` is #list.
    local default_indices = fdp:consume_boolean()
    if default_indices then
        unpack(str_chars)
    end

    -- `i` and `j` cannot be bigger than INT_MAX, otherwise an
    -- error "too many results to unpack" is raised.
    local i = fdp:consume_integer(0, MAX_INT)
    local j = fdp:consume_integer(0, MAX_INT)
    pcall(unpack, str_chars, i, j)
end

local args = {
    artifact_prefix = "builtin_unpack_",
}
luzer.Fuzz(TestOneInput, nil, args)
