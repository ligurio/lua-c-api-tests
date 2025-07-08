--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html

Synopsis: type(v)
]]

local luzer = require("luzer")

local function TestOneInput(buf)
    -- "nil", "number", "string", "boolean", "table", "function",
    -- "thread", and "userdata".
    type(buf)
end

local args = {
    artifact_prefix = "builtin_type_",
}
luzer.Fuzz(TestOneInput, nil, args)
