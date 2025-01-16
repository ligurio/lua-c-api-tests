--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.6 – Table Manipulation
https://www.lua.org/manual/5.1/manual.html#5.5

'table.sort' does not work for partial orders,
https://github.com/lua/lua/commit/825ac8eca8e384d6ad2538b5670088c31e08a9d7

Synopsis: table.sort(list [, comp])
]]

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    local tbl = test_lib.random_table(fdp)
    -- qsort is used
    table.sort(tbl)
end

local args = {
    artifact_prefix = "table_sort_",
}
luzer.Fuzz(TestOneInput, nil, args)
