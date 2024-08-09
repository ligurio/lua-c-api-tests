/*
 * SPDX-License-Identifier: ISC
 *
 * Copyright 2022-2024, Sergey Bronnikov
 */

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

static const char *script_default = "./libfuzzer_lua_script.lua";

static size_t
luaL_custom_crossover(lua_State* L, const char *path, const char *func_name,
	                  const uint8_t *data1, size_t size1,
	                  const uint8_t *data2, size_t size2,
	                  size_t max_out_size, unsigned int seed)
{
	luaL_dofile(L, path);
	lua_getglobal(L, func_name);
	if (!lua_isfunction(L, -1)) {
		luaL_error(L, "'%s' is not a function", func_name);
	}
	lua_pushlstring(L, (const char*)data1, size1);
	lua_pushlstring(L, (const char*)data2, size2);
	lua_pushinteger(L, max_out_size);
	lua_pushinteger(L, seed);
	const int num_args = 4;
	const int num_return_values = 2;
	lua_pcall(L, num_args, num_return_values, 0);

	if (!lua_isnumber(L, -1)) {
		luaL_error(L, "'%s' must return an integer value", func_name);
	}
	size_t ret_size = lua_tointeger(L, -1);
	lua_pop(L, 1);

	if (!lua_isstring(L, -1)) {
		luaL_error(L, "'%s' must return a string value", func_name);
	}
	lua_pop(L, 1);

	return ret_size;
}

/*
 * The libFuzzer can specify a "Custom Crossover" function for combining two
 * inputs from the corpus. This function is sometimes called by libFuzzer
 * when mutating inputs.
 *
 * data1: location of first input
 * size1: length of first input
 * data1: location of second input
 * size1: length of second input
 * out: where to place the resulting, mutated input
 * max_out_size: the maximum length of the input that can be placed in out
 * seed: the seed that should be used to make mutations deterministic, when
 *       needed
 *
 * See libfuzzer's LLVMFuzzerCustomCrossOver API for more info.
 *
 * Can be NULL.
 */
size_t
LLVMFuzzerCustomCrossOver(const uint8_t *Data1, size_t Size1,
	                      const uint8_t *Data2, size_t Size2,
	                      uint8_t *Out, size_t MaxOutSize,
	                      unsigned int Seed)
{
	const char *script_env = "LIBFUZZER_LUA_SCRIPT";
	const char *script_func = "LLVMFuzzerCustomCrossOver";
	const char *script_path = getenv(script_env) ? getenv(script_env) : script_default;

	if (access(script_path, F_OK) != 0) {
		fprintf(stderr, "Script (%s) is not accessible.\n", script_path);
		_exit(1);
	}

	lua_State* L = luaL_newstate();
	if (!L) {
		fprintf(stderr, "Unable to create Lua state.\n");
		abort();
	}
	luaL_openlibs(L);
	size_t size = luaL_custom_crossover(L, script_path, script_func,
	                                    Data1, Size1, Data2, Size2,
	                                    MaxOutSize, Seed);
	lua_close(L);

	return size;
}
