--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.4 – String Manipulation
https://www.lua.org/manual/5.3/manual.html#6.4

Synopsis: string.pack(fmt, v1, v2, ...)
]]

local luzer = require("luzer")
local test_lib = require("lib")

-- PUC Rio Lua only.
if test_lib.lua_version() == "LuaJIT" then
    os.exit(0)
end

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    os.setlocale(test_lib.random_locale(fdp), "all")
    local fmt_str = fdp:consume_string(0, test_lib.MAX_INT)
    if fdp:remaining_bytes() == 0 then
        return -1
    end
    local n = fdp:consume_integer(1, test_lib.MAX_INT)
    local values = fdp:consume_strings(test_lib.MAX_INT,  n)
    string.pack(fmt_str, table.unpack(values))
end

local args = {
    artifact_prefix = "string_pack_",
}
luzer.Fuzz(TestOneInput, nil, args)
