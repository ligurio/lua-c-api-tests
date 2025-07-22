--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.7 – Input and Output Facilities
https://www.lua.org/manual/5.1/manual.html#5.7
https://www.lua.org/pil/21.1.html

Does io.lines() stream or slurp the file?
https://stackoverflow.com/questions/43005068/does-io-lines-stream-or-slurp-the-file

io.lines does not check maximum number of options,
https://www.lua.org/bugs.html#5.3.1-1

Synopsis: io.lines([filename, ...])
]]

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local str = fdp:consume_string(test_lib.MAX_STR_LEN)
    local lua_chunk = ("io.write('%s')"):format(str)
    local lua_cmd = ("%s -e '%s'"):format(test_lib.luabin(arg), lua_chunk)
    local fh = assert(io.popen(lua_cmd))
    fh:lines("*all")
    fh:flush()
    fh:close()
end

local args = {
    artifact_prefix = "io_lines_",
    only_ascii = 1,
}
luzer.Fuzz(TestOneInput, nil, args)
