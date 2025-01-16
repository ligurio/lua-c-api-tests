--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html

rawset and rawget do not ignore extra arguments,
https://www.lua.org/bugs.html#5.0.2-4

Synopsis: rawget(table, index)
]]

local luzer = require("luzer")
local test_lib = require("lib")
local MAX_INT = test_lib.MAX_INT

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local items = fdp:consume_integer(0, test_lib.MAX_INT)
    local tbl = fdp:consume_integers(test_lib.MIN_INT, test_lib.MAX_INT, items)
    local key_len = fdp:consume_integer(0, MAX_INT)
    local key = fdp:consume_string(key_len)
    rawget(tbl, key)
end

local args = {
    artifact_prefix = "builtin_rawget_",
}
luzer.Fuzz(TestOneInput, nil, args)
