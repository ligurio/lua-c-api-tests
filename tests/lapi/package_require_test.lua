--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.3 – Modules
https://www.lua.org/manual/5.1/manual.html#5.3

PIL: 15 – Packages
https://www.lua.org/pil/15.html

Synopsis: require(modname)
]]

local luzer = require("luzer")
local test_lib = require("lib")
local MAX_PATH_NUM = 10

local function setenv(key, value)
    local env = ("export %s=%s"):format(key, value)
    os.execute(env)
end

local function build_path(fdp, max_path_num)
    local count = fdp:consume_integer(0, max_path_num)
    local paths = fdp:consume_strings(test_lib.MAX_STR_LEN, count)
    local path_str = table.concat(paths, ";")
    local def_path = fdp:consume_boolean()
    return def_path and path_str or path_str .. ";;"
end

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)

    local lua_path = build_path(fdp, MAX_PATH_NUM)
    setenv("LUA_PATH", lua_path)
    package.path = lua_path

    local lua_cpath = build_path(fdp, MAX_PATH_NUM)
    setenv("LUA_CPATH", lua_cpath)
    package.cpath = lua_cpath

    local module_name = fdp:consume_string(test_lib.MAX_STR_LEN)
    pcall(require, module_name)

    -- Teardown.
    setenv("LUA_PATH", "")
    setenv("LUA_CPATH", "")
end

local args = {
    artifact_prefix = "package_require_",
}
luzer.Fuzz(TestOneInput, nil, args)
