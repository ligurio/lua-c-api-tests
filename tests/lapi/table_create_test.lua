--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.6 – Table Manipulation
https://www.lua.org/manual/5.1/manual.html#5.5

Synopsis:
]]

local luzer = require("luzer")
local test_lib = require("lib")
local MAX_INT = test_lib.MAX_INT

-- PUC Rio Lua only.
if test_lib.lua_version() == "LuaJIT" then
    print("Unsupported version.")
    os.exit(0)
end

local function TestOneInput(buf)
    -- New function 'table.create',
    -- https://github.com/lua/lua/commit/3e9dbe143d3338f5f13a5e421ea593adff482da0
    local fdp = luzer.FuzzedDataProvider(buf)
    local len = fdp:consume_integer(0, MAX_INT)
    local tbl = table.create(len) -- luacheck: no unused
    tbl = nil
    collectgarbage()
    collectgarbage()
end

local args = {
    artifact_prefix = "table_create_",
}
luzer.Fuzz(TestOneInput, nil, args)
