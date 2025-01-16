--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2024, Sergey Bronnikov.

5.5 – Table Manipulation,
https://www.lua.org/manual/5.1/manual.html#5.5

Synopsis: table.insert(list, [pos,] value)
]]

local luzer = require("luzer")

local function TestOneInput(buf, _size)
    local len = string.len(buf)
    local tbl = {}
    local pos = 1
    buf:gsub(".", function(c)
        table.insert(tbl, pos, c)
        pos = pos + 1
    end)
    assert(pos, len)
end

local args = {
    artifact_prefix = "table_insert_",
}
luzer.Fuzz(TestOneInput, nil, args)
