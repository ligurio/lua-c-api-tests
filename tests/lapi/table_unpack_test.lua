--[=[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.6 – Table Manipulation
https://www.lua.org/manual/5.1/manual.html#5.5

Compiler can optimize away overflow check in table.unpack,
https://www.lua.org/bugs.html#5.2.3-1

Synopsis: table.unpack(list [, i [, j]])
--]]=]

local luzer = require("luzer")
local test_lib = require("lib")
local MAX_INT = test_lib.MAX_INT

-- Lua only.
if test_lib.lua_version() == "LuaJIT" then
    print("Unsupported version.")
    os.exit(0)
end

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    local tbl = test_lib.random_table(fdp)
    local i = fdp:consume_integer(0, MAX_INT)
    local j = fdp:consume_integer(0, MAX_INT)
    table.unpack(tbl, i, j)
end

local args = {
    artifact_prefix = "table_unpack_",
}
luzer.Fuzz(TestOneInput, nil, args)
