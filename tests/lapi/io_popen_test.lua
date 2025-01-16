--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.7 – Input and Output Facilities
https://www.lua.org/manual/5.1/manual.html#5.7

'popen' can crash if called with an invalid mode,
https://github.com/lua/lua/commit/1ecfbfa1a1debd2258decdf7c1954ac6f9761699

On some machines, closing a "piped file" (created with io.popen) may crash Lua,
https://www.lua.org/bugs.html#5.0.2-8

Synopsis: io.popen(prog [, mode])
]]

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local str = fdp:consume_string(test_lib.MAX_STR_LEN)
    local lua_chunk = ("io.write([[%s]])"):format(str)
    local lua_cmd = ("%s -e '%s'"):format(test_lib.luabin(arg), lua_chunk)
    local fh = assert(io.popen(lua_cmd, "r"))
    fh:lines("*all")
    fh:flush()
    fh:close()
end

local args = {
    artifact_prefix = "io_popen_",
}
luzer.Fuzz(TestOneInput, nil, args)
