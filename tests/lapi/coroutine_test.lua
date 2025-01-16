--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

2.6 – Coroutines
https://www.lua.org/manual/5.3/manual.html#2.6

Computation of stack limit when entering a coroutine is wrong,
https://github.com/lua/lua/commit/e1d8770f12542d34a3e32b825c95b93f8a341ee1

C-stack overflow with deep nesting of coroutine.close,
https://www.lua.org/bugs.html#5.4.4-9

C stack overflow (again),
https://github.com/lua/lua/commit/34affe7a63fc5d842580a9f23616d057e17dfe27

When a coroutine tries to resume a non-suspended coroutine,
it can do some mess (and break C assertions) before detecting the error,
https://www.lua.org/bugs.html#5.3.3-4

Suspended __le metamethod can give wrong result,
https://www.lua.org/bugs.html#5.3.0-3

Resuming the running coroutine makes it unyieldable,
https://www.lua.org/bugs.html#5.2.2-8

pcall may not restore previous error function when inside coroutines,
https://www.lua.org/bugs.html#5.2.1-2

Wrong handling of nCcalls in coroutines,
https://www.lua.org/bugs.html#5.2.0-4

coroutine.resume pushes element without ensuring stack size,
https://www.lua.org/bugs.html#5.1.3-2

Recursive coroutines may overflow C stack,
https://www.lua.org/bugs.html#5.1.2-4

Stand-alone interpreter shows incorrect error message when the
"message" is a coroutine,
https://www.lua.org/bugs.html#5.1.2-12

Debug hooks may get wrong when mixed with coroutines,
https://www.lua.org/bugs.html#5.1-7

Values held in open upvalues of suspended threads may be
incorrectly collected,
https://www.lua.org/bugs.html#5.0.2-3

Attempt to resume a running coroutine crashes Lua,
https://www.lua.org/bugs.html#5.0-2

Synopsis:

coroutine.close(co)
coroutine.create(f)
coroutine.isyieldable([co])
coroutine.resume(co [, val1, ...])
coroutine.running()
coroutine.status(co)
coroutine.wrap(f)
coroutine.yield(...)
]]

local luzer = require("luzer")

local C = {}

local STATUS_CREATE = "CREATE"
local STATUS_CLOSE = "CLOSE"
local STATUS_YIELD = "YIELD"
local STATUS_RESUME = "RESUME"
local STATUS_DEAD = "DEAD"

local CORO_MAX_NUMBER = 10^53

local CORO_STATE = {
    STATUS_CLOSE,
    STATUS_CREATE,
    STATUS_RESUME,
    STATUS_YIELD,
}

-- Forward declaration.
local coro_loop

local function random_coro(fdp)
    local coro, coro_n = fdp:one_of(C)
    local coro_status = coroutine.status(coro)
    if coro_status == STATUS_DEAD then
        table.remove(C, coro_n)
        coro = coroutine.create(coro_loop)
        table.insert(C, coro)
        coroutine.resume(coro, 1)
    end
    return fdp:one_of(C)
end

local function coro_step(fdp)
    local state = fdp:one_of(CORO_STATE)
    if state == STATUS_CREATE then
        local co = coroutine.create(coro_loop)
        table.insert(C, co)
        coroutine.resume(co, 1)
        return
    end

    state = fdp:one_of(CORO_STATE)
    local coro = random_coro(fdp)
    local status = coroutine.status(coro)
    if status == STATUS_DEAD then
        return
    end
    io.write(("[%0.6s] STATE: %s -> %s\n"):format(#C, status, state))
    if state == STATUS_CLOSE then
        coroutine.close(coro)
    elseif state == STATUS_YIELD and coroutine.isyieldable(coro) then
        coroutine.yield(coro)
    elseif state == STATUS_RESUME then
        coroutine.resume(coro)
    end

    return
end

coro_loop = function(fdp, max_n)
    local n = fdp:consume_integer(1, max_n)
    for _ = 1, n do
        coro_step(fdp)
    end
end

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    local co = coroutine.create(coro_loop)
    table.insert(C, co)
    -- The function `coroutine.resume` starts the execution of
    -- a coroutine, changing its state from suspended to running.
    coroutine.resume(co, fdp, CORO_MAX_NUMBER)
end

local args = {
    artifact_prefix = "coroutine_create_",
}
luzer.Fuzz(TestOneInput, nil, args)
