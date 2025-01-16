--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

Synopsis:
]]

local luzer = require("luzer")
local test_lib = require("lib")

-- LuaJIT only.
if test_lib.lua_version() ~= "LuaJIT" then
    print("Unsupported version.")
    os.exit(0)
end

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local tbl = test_lib.random_table(fdp)
    table.maxn(tbl)
end

local args = {
    artifact_prefix = "table_maxn_",
}
luzer.Fuzz(TestOneInput, nil, args)
