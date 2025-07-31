--[[
SPDX-License-Identifier: ISC
Copyright (c) 2025, Sergey Bronnikov.

LuaJIT platform profiler,
https://luajit.org/ext_profiler.html
https://www.tarantool.io/en/doc/latest/tooling/luajit_sysprof/
]]

local luzer = require("luzer")
local test_lib = require("lib")

if test_lib.lua_version() ~= "LuaJIT" then
    print("Unsupported version.")
    os.exit(0)
end

local MAX_INT = test_lib.MAX_INT
local MIN_INT = test_lib.MIN_INT

local has_tnt_sysprof, sysprof = pcall(require, "misc.sysprof")
if not has_tnt_sysprof then
    sysprof = require("jit.profile")
end

local SYSPROF_OPTIONS = {
    "f", -- Profile with precision down to the function level.
    "l", -- Profile with precision down to the line level.
    "i", -- Sampling interval in milliseconds (default 10ms).
}

local SYSPROF_DEFAULT_INTERVAL = 10 -- ms

local function sysprof_start(fdp)
    if has_tnt_sysprof then
        local mode = fdp:oneof({"D", "L", "C"})
        local _, err = misc.sysprof.start({
            interval = SYSPROF_DEFAULT_INTERVAL,
            mode = mode,
            path = "/dev/null",
        })
        assert(err)
    else
        local option = fdp:oneof(SYSPROF_OPTIONS)
        if option == "i" then
            option = ("i%d"):format(SYSPROF_DEFAULT_INTERVAL)
        end
        local cb = function(_thread, _samples, _vmstate)
            -- Nope.
        end
        sysprof.start(option, cb)
    end
end

local function sysprof_report()
    if has_tnt_sysprof then
        misc.sysprof.report()
    end
end

local DUMPSTACK_FMT = {
    "p", -- Preserve the full path for module names.
    "f", -- Dump the function name if it can be derived.
    "F", -- Ditto, but dump module:name.
    "l", -- Dump module:line.
    "Z", -- Zap the following characters for the last dumped frame.
}

local function sysprof_dumpstack(fdp)
    if not has_tnt_sysprof then
        local fmt = fdp:oneof(DUMPSTACK_FMT)
        local depth = fdp:consume_integer(MIN_INT, MAX_INT)
        local dump = sysprof.dumpstack(fmt, depth)
        assert(dump)
    end
end

local function sysprof_stop()
    sysprof.stop()
end

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local mode = fdp:oneof({"t", "b"})
    -- LuaJIT ASSERT lj_bcread.c:123: bcread_byte: buffer read
    -- overflow.
    if test_lib.lua_version() == "LuaJIT" then
        mode = "t"
    end
    local chunk = fdp:consume_string(test_lib.MAX_STR_LEN)
    local func = load(chunk, "luzer", mode)
    sysprof_start(fdp)
    pcall(func)
    sysprof_report()
    sysprof_dumpstack(fdp)
    sysprof_stop()
end

local args = {
    artifact_prefix = "misc_sysprof_",
}
luzer.Fuzz(TestOneInput, nil, args)
