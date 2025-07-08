--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html

Incorrect recording of getmetatable() for IO handlers,
https://github.com/LuaJIT/LuaJIT/issues/1279

Synopsis: getmetatable(object)
]]

local luzer = require("luzer")

local function TestOneInput(_buf)
    local tbl = {}
    getmetatable(tbl)
end

local args = {
    artifact_prefix = "builtin_getmetatable_",
}
luzer.Fuzz(TestOneInput, nil, args)
