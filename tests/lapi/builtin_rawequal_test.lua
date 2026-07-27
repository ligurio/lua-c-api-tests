--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2026, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html

Synopsis: rawequal(v1, v2)
]]

local luzer = require("luzer")
local test_lib = require("lib")

local MAX_INT = test_lib.MAX_INT
local MIN_INT = test_lib.MIN_INT
local MAX_STR_LEN = test_lib.MAX_STR_LEN

local LUA_TYPES = {
    "boolean",
    "function",
    "integer",
    "nil",
    "number",
    "string",
    "table",
    "thread",
}

local function random_value(fdp, typ)
    if typ == "nil" then
        return nil
    elseif typ == "boolean" then
        return fdp:consume_boolean()
    elseif typ == "integer" then
        return fdp:consume_integer(MIN_INT, MAX_INT)
    elseif typ == "number" then
        return fdp:consume_number(MIN_INT, MAX_INT)
    elseif typ == "string" then
        return fdp:consume_string(MAX_STR_LEN)
    elseif typ == "table" then
        return fdp:consume_numbers(MIN_INT, MAX_INT, 10)
    elseif typ == "function" then
        return function() end
    elseif typ == "thread" then
        return coroutine.create(function() end)
    end
end

local function check_rawequal(v1, v2)
    local result = rawequal(v1, v2)
    assert(type(result) == "boolean")

    if type(v1) ~= type(v2) then
        assert(result == false)
    end
end

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    test_lib.random_misc_settings(fdp)

    local same = fdp:consume_boolean()
    local type_1 = fdp:oneof(LUA_TYPES)
    local type_2 = same and type_1 or fdp:oneof(LUA_TYPES)

    local v1 = random_value(fdp, type_1)
    local v2 = random_value(fdp, type_2)

    if (type_1 == "table" or
        type_1 == "function" or
        type_1 == "thread")
        and fdp:consume_boolean() then
        v2 = v1
    end

    check_rawequal(v1, v2)

    if type(v1) == "table" then
        local mt = {
            __eq = function()
                error("unreachable")
            end,
        }
        pcall(debug.setmetatable, v1, mt)
        if type(v2) == "table" then
            pcall(debug.setmetatable, v2, mt)
        end
        local after = rawequal(v1, v2)
        assert(type(after) == "boolean")
    end

    local nan = 0.0 / 0.0
    assert(rawequal(nan, nan) == false)
    assert(rawequal(nan, 0) == false)
    assert(rawequal(0, 0) == true)
    assert(rawequal(math.huge, math.huge) == true)
    assert(rawequal(-math.huge, -math.huge) == true)
end

local args = {
    artifact_prefix = "builtin_rawequal_",
}
luzer.Fuzz(TestOneInput, nil, args)
