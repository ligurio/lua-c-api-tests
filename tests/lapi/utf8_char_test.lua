--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.5 – UTF-8 Support
https://www.lua.org/manual/5.3/manual.html#6.5

'utf8.codes' does not raise an error on spurious continuation bytes,
https://github.com/lua/lua/commit/a1089b415a3f5c753aa1b40758ffdaf28d5701b0

Synopsis: utf8.char(...)
]]

local luzer = require("luzer")
local test_lib = require("lib")
local MAX_INT = test_lib.MAX_INT

if test_lib.lua_version() == "LuaJIT" then
    os.exit()
end

-- The function is introduced in Lua 5.3.
if test_lib.lua_current_version_lt_than(5, 3) then
    os.exit()
end

local unpack = unpack or table.unpack

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local n = fdp:consume_integer(1, MAX_INT)
    local ch = fdp:consume_integers(0, MAX_INT, n)
    os.setlocale(test_lib.random_locale(fdp), "all")
    utf8.char(unpack(ch))
end

local args = {
    artifact_prefix = "utf8_char_",
}
luzer.Fuzz(TestOneInput, nil, args)
