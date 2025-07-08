--[=[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.6 – Table Manipulation
https://www.lua.org/manual/5.1/manual.html#5.5

Infinite loop on table lookup,
https://github.com/LuaJIT/LuaJIT/issues/494

Synopsis: table.concat(list [, sep [, i [, j]]])
--]=]

local luzer = require("luzer")

local function TestOneInput(buf, _size)
    local len = string.len(buf)
    local tbl = {}
    buf:gsub(".", function(c)
        local pos_end = table.getn(tbl)
        table.insert(tbl, pos_end + 1, c)
        assert(tbl[pos_end + 1] == c)
    end)
    assert(table.getn(tbl), len)
    assert(buf == table.concat(tbl))
end

local args = {
    artifact_prefix = "table_concat_",
}
luzer.Fuzz(TestOneInput, nil, args)
