--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.6 – Table Manipulation
https://www.lua.org/manual/5.1/manual.html#5.5

Synopsis: table.pack(...)
]]

local luzer = require("luzer")
local test_lib = require("lib")

-- PUC Rio Lua only.
if test_lib.lua_version() == "LuaJIT" then
    print("Unsupported version.")
    os.exit(0)
end

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    local tbl = test_lib.random_table(fdp)
    table.pack(unpack(tbl))
end

local args = {
    artifact_prefix = "table_pack_",
}
luzer.Fuzz(TestOneInput, nil, args)
