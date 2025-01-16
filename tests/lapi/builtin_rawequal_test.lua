--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html

Synopsis: rawequal(v1, v2)
]]

local luzer = require("luzer")
local test_lib = require("lib")

local MAX_INT = test_lib.MAX_INT
local MIN_INT = test_lib.MIN_INT
local MAX_STR_LEN = test_lib.MAX_STR_LEN

local function random_value(fdp)
    local item_type = fdp:oneof({"number", "integer", "boolean", "string"})
    local item
    if item_type == "string" then
        item = fdp:consume_string(MAX_STR_LEN)
    elseif item_type == "boolean" then
        item = fdp:consume_boolean()
    elseif item_type == "integer" then
        item = fdp:consume_integer(MIN_INT, MAX_INT)
    elseif item_type == "number" then
        item = fdp:consume_number(MIN_INT, MAX_INT)
    else
        assert("Unsupported type")
    end
    return item
end

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local v1 = random_value(fdp)
    local v2 = random_value(fdp)
    assert(type(rawequal(v1, v2)) == "boolean")
end

local args = {
    artifact_prefix = "builtin_rawequal_",
}
luzer.Fuzz(TestOneInput, nil, args)
