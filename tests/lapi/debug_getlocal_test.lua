--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

Negation overflow in getlocal/setlocal,
https://github.com/lua/lua/commit/a585eae6e7ada1ca9271607a4f48dfb17868ab7b

debug.getlocal on a coroutine suspended in a hook can crash the interpreter,
https://www.lua.org/bugs.html#5.3.0-2

Synopsis: debug.getlocal([thread,] level, local)
]]

local luzer = require("luzer")

local function debug_hook()
    -- TODO: getlocal
end

local loadstring = type(loadstring) == "function" and loadstring or load

local hook_mask = {
    "c", -- the hook is called every time Lua calls a function.
    "r", -- the hook is called every time Lua returns from a function.
    "l", -- the hook is called every time Lua enters a new line of code.
}

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)

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
    artifact_prefix = "debug_getlocal_",
}
luzer.Fuzz(TestOneInput, nil, args)
