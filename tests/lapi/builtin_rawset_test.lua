--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html

Memory-allocation error when resizing a table can leave it in an inconsistent state,
https://www.lua.org/bugs.html#5.3.4-7

rawset and rawget do not ignore extra arguments,
https://www.lua.org/bugs.html#5.0.2-4

Synopsis: rawset(table, index, value)
]]

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local items = fdp:consume_integer(0, test_lib.MAX_INT)
    local tbl = fdp:consume_integers(test_lib.MIN_INT, test_lib.MAX_INT, items)
    rawset(tbl, "a", 1)
end

local args = {
    artifact_prefix = "builtin_rawset_",
}
luzer.Fuzz(TestOneInput, nil, args)
