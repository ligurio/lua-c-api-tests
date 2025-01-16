--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.4 – String Manipulation
https://www.lua.org/manual/5.3/manual.html#6.4

Synopsis: string.packsize(fmt)
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
    local max_len = fdp:consume_integer(0, test_lib.MAX_INT)
    local fmt_str = fdp:consume_string(max_len)
    -- Avoid errors like "invalid format option 'R'".
    local ok, _ = pcall(string.packsize, fmt_str)
    if not ok then
        return
    end
    local size = string.packsize(fmt_str)
    assert(type(size) == "number")
end

local args = {
    artifact_prefix = "string_packsize_",
}
luzer.Fuzz(TestOneInput, nil, args)
