--[[
SPDX-License-Identifier: ISC
Copyright (c) 2025, Sergey Bronnikov.

Tarantool's platform profiler,
https://www.tarantool.io/en/doc/latest/tooling/luajit_sysprof/
]]

local luzer = require("luzer")
local test_lib = require("lib")

local has_sysprof, sysprof = pcall(require, "misc.sysprof")
if not has_sysprof then
    print("Unsupported version.")
    os.exit(0)
end

local SYSPROF_DEFAULT_INTERVAL = 1 -- ms

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local chunk = fdp:consume_string(test_lib.MAX_STR_LEN)
    -- LuaJIT ASSERT lj_bcread.c:123: bcread_byte: buffer read
    -- overflow.
    local func = load(chunk, "luzer", "t")
    local sysprof_mode = fdp:oneof({"D", "L", "C"})

    assert(sysprof.start({
        interval = SYSPROF_DEFAULT_INTERVAL,
        mode = sysprof_mode,
        path = "/dev/null",
    }))
    pcall(func)
    sysprof.report()
    sysprof.stop()
end

local args = {
    artifact_prefix = "misc_sysprof_",
}
luzer.Fuzz(TestOneInput, nil, args)
