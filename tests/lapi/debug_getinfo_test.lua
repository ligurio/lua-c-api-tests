--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

Parameter 'what' of 'debug.getinfo' cannot start with '>',
https://www.lua.org/bugs.html#5.4.2-2

Access to debug information in line hook of stripped function,
https://github.com/lua/lua/commit/ae5b5ba529753c7a653901ffc29b5ea24c3fdf3a

Return hook may not see correct values for active local variables when function returns,
https://www.lua.org/bugs.html#5.3.0-4

The PC out-of-range in lj_debug_frameline(),
https://github.com/LuaJIT/LuaJIT/issues/1369

LuaJIT segfault in debug.getinfo(),
https://github.com/LuaJIT/LuaJIT/issues/509

Synopsis: debug.getinfo([thread,] function [, what])
]]

local luzer = require("luzer")

local what = {
    "n", -- fills in the field name and namewhat.
    "S", -- fills in the fields source, short_src, linedefined,
         -- lastlinedefined, and what.
    "l", -- fills in the field currentline.
    "u", -- fills in the field nups.
    "f", -- pushes onto the stack the function that is running at
         -- the given level.
    "L", -- pushes onto the stack a table whose indices are the
         -- numbers of the lines that are valid on the function.
}

local what_modes

local hook_mask = {
    "c", -- the hook is called every time Lua calls a function.
    "r", -- the hook is called every time Lua returns from a function.
    "l", -- the hook is called every time Lua enters a new line of code.
}

local loadstring = type(loadstring) == "function" and loadstring or load

local function debug_hook()
    debug.getinfo(1, table.concat(what_modes))
end

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)

    -- Generate a random 'what'.
    what_modes = {}
    local n_modes = fdp:consume_integer(0, #what)
    for _ = 0, n_modes do
        table.insert(what_modes, fdp:oneof(what))
    end

    -- Generate a random hook mask.
    local n_hook_mask = fdp:consume_integer(0, #hook_mask)
    local mask = {}
    for _ = 0, n_hook_mask do
        table.insert(mask, fdp:oneof(hook_mask))
    end

    debug.sethook(debug_hook, table.concat(mask))
    assert(loadstring(buf))()
    debug.sethook() -- Turn off the hook.
end

local args = {
    artifact_prefix = "debug_getinfo_",
}
luzer.Fuzz(TestOneInput, nil, args)
