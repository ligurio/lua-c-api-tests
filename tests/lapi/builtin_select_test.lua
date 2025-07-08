--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html

Synopsis: select(index, ...)
]]

local luzer = require("luzer")
local test_lib = require("lib")

local unpack = unpack or table.unpack
local MAX_INT = test_lib.MAX_INT
local MIN_INT = test_lib.MIN_INT
local MAX_STR_LEN = test_lib.MAX_STR_LEN

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)

    local items = fdp:consume_integer(1, 100)
    local items_type = fdp:oneof({"number", "integer", "boolean", "string"})
    local items_table
    if items_type == "string" then
        items_table = fdp:consume_strings(MAX_STR_LEN, items)
    elseif items_type == "boolean" then
        items_table = fdp:consume_booleans(items)
    elseif items_type == "integer" then
        items_table = fdp:consume_integers(MIN_INT, MAX_INT, items)
    elseif items_type == "number" then
        items_table = fdp:consume_numbers(MIN_INT, MAX_INT, items)
    else
        assert("Unsupported type")
    end

    local index = fdp:consume_boolean() and "#" or
                  fdp:consume_integer(0, MAX_INT)
    if index == "#" then
        assert(select(index, unpack(items_table)) == items)
    end
    pcall(select, index, items_table)
end

local args = {
    artifact_prefix = "builtin_select_",
}
luzer.Fuzz(TestOneInput, nil, args)
