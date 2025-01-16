--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2024, Sergey Bronnikov.

6.6 – Table Manipulation
https://www.lua.org/manual/5.1/manual.html#5.5

Synopsis: table.insert (list, [pos,] value)
]]

local luzer = require("luzer")

local function TestOneInput(buf, _size)
    local len = string.len(buf)
    local tbl = {}
    buf:gsub(".", function(c)
        local pos_end = table.getn(tbl)
        table.insert(tbl, pos_end, c)
        -- FIXME
        -- assert(tbl[pos_end + 1] == c)
    end)
    assert(table.getn(tbl), len)
    -- FIXME
    -- assert(buf == table.concat(tbl))
end

local args = {
    artifact_prefix = "table_insert_",
}
luzer.Fuzz(TestOneInput, nil, args)
