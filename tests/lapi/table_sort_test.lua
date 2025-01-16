--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.6 – Table Manipulation,
https://www.lua.org/manual/5.1/manual.html#5.5

'table.sort' does not work for partial orders,
https://github.com/lua/lua/commit/825ac8eca8e384d6ad2538b5670088c31e08a9d7

Synopsis: table.sort(list [, comp])
]]

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    local max = fdp:consume_integer(0, test_lib.MAX_INT64)
    local min = fdp:consume_integer(test_lib.MIN_INT64, 0)
    -- Huge length leads to slow units.
    local MAX_N = 1000
    local count = fdp:consume_integer(0, MAX_N)
    local tbl = fdp:consume_integers(min, max, count)
    local minimum = test_lib.MIN_INT64
    local maximum = test_lib.MAX_INT64
    table.insert(tbl, minimum)
    table.insert(tbl, maximum)
    table.sort(tbl)
    assert(tbl[1] == minimum)
    assert(tbl[#tbl] == maximum)
end

local args = {
    artifact_prefix = "table_sort_",
}
luzer.Fuzz(TestOneInput, nil, args)
