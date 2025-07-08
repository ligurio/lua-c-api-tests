--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

lua_getupvalue and lua_setupvalue do not check for index too small,
https://www.lua.org/bugs.html#5.0.2-2

Synopsis: debug.getupvalue (f, up)
]]

local luzer = require("luzer")

local function debug_hook()
    -- TODO: getupvalue
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
    artifact_prefix = "debug_getupvalue_",
}
luzer.Fuzz(TestOneInput, nil, args)
