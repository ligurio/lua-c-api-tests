--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2026, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html
]]

local luzer = require("luzer")
local test_lib = require("lib")
local MAX_INT = test_lib.MAX_INT

-- loadstring() is removed in Lua 5.2+; use load() with a string chunk.
local load_string = type(loadstring) == "function" and loadstring or load

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    test_lib.random_misc_settings(fdp)
    local max_len = fdp:consume_integer(0, MAX_INT)
    local str = fdp:consume_string(max_len)
    pcall(function()
        local fn, err = load_string(str)
        if fn ~= nil then
            -- The compiled chunk must be a function; execute it.
            assert(type(fn) == "function")
            pcall(fn)
        else
            -- On failure the compiler returns a string error message.
            assert(type(err) == "string")
        end
    end)
end

local args = {
    artifact_prefix = "builtin_dostring_",
}
-- lj_bcread.c:123: bcread_byte: buffer read overflow
if test_lib.lua_version() == "LuaJIT" then
    args.only_ascii = 1
end
luzer.Fuzz(TestOneInput, nil, args)
