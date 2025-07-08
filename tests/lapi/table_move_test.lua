--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.6 – Table Manipulation
https://www.lua.org/manual/5.1/manual.html#5.5

Synopsis: table.move(a1, f, e, t [,a2])
]]

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    local tbl = test_lib.random_table(fdp)
    table.move(tbl, 1, #tbl, 1, {})
end

local args = {
    artifact_prefix = "table_move_",
}
luzer.Fuzz(TestOneInput, nil, args)
