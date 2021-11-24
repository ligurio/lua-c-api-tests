/*
 * SPDX-License-Identifier: ISC
 *
 * Copyright 2023, Sergey Bronnikov.
 */

#include <stdint.h>
#include <stdlib.h> /* malloc, free */
#include <string.h> /* memcpy */

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

/*
 * The main purpose of the test is testing Lua frontend (lexer, parser).
 * The test doesn't execute a loaded chunk to be quite fast.
 */

int
LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
	lua_State *L = luaL_newstate();
	if (L == NULL)
		return 0;

	/*
	 * The string "mode" controls whether the chunk can be text or binary
	 * (that is, a precompiled chunk). It may be the string "b" (only binary
	 * chunks), "t" (only text chunks), or "bt" (both binary and text). The
	 * default is "bt".
	 * Seed corpus is shared by different Lua runtimes (PUC Rio Lua and LuaJIT),
	 * enabling binary mode could lead false positive crashes in LuaJIT.
	 */
	const char *mode = "t";
	luaL_loadbufferx(L, (const char *)data, size, "fuzz", mode);

	lua_settop(L, 0);
	lua_close(L);

	return 0;
}
