--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

Bad loop initialization in table.foreach(),
https://github.com/LuaJIT/LuaJIT/issues/844

string.dump(table.foreach) will trigger an assert,
https://github.com/LuaJIT/LuaJIT/issues/1038

Synopsis:
]]

local luzer = require("luzer")
local test_lib = require("lib")

-- Function `table.foreach` is deprecated in Lua 5.1.
if test_lib.lua_current_version_ge_than(5, 1) then
    print("Unsupported version.")
    os.exit(0)
end

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    local tbl = test_lib.random_table(fdp)
    local fn = function() end
    table.foreach(tbl, fn)
end

local args = {
    artifact_prefix = "table_foreach_",
}
luzer.Fuzz(TestOneInput, nil, args)
