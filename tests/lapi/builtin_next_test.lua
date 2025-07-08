--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html

recff_next does not take into account the situation when all next results are consumed,
https://github.com/LuaJIT/LuaJIT/issues/753

Key removed from a table during traversal may not be accepted by 'next',
https://github.com/lua/lua/commit/52c86797608f1bf927be5bab1e9b97b7d35bdf2c

Synopsis: next(table [, index])
]]

local luzer = require("luzer")
local test_lib = require("lib")
local MAX_INT = test_lib.MAX_INT

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local items = fdp:consume_integer(0, test_lib.MAX_INT)
    local tbl = fdp:consume_integers(test_lib.MIN_INT, test_lib.MAX_INT, items)
    local index = fdp:consume_integer(0, MAX_INT)
    pcall(next, tbl, index)
end

local args = {
    artifact_prefix = "builtin_next_",
}
luzer.Fuzz(TestOneInput, nil, args)
