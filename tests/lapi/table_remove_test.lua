--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.5 – Table Manipulation,
https://www.lua.org/manual/5.1/manual.html#5.5

table.remove removes last element of a table when given an
out-of-bound index, https://www.lua.org/bugs.html#5.1.2-10

Synopsis: table.remove(list [, pos])
]]

local luzer = require("luzer")
local test_lib = require("lib")
local MAX_INT = test_lib.MAX_INT

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    local max_len = fdp:consume_integer(0, MAX_INT)
    local str = fdp:consume_string(max_len)
    local tbl = {}
    str:gsub(".", function(c)
        table.insert(tbl, c)
    end)
    for _ = 1, #tbl do
        assert(tbl[1] == table.remove(tbl, 1))
    end
    assert(#tbl == 0)
end

local args = {
    artifact_prefix = "table_remove_",
}
luzer.Fuzz(TestOneInput, nil, args)
