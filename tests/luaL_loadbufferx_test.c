#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>


int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
	lua_State *L = luaL_newstate();
	if (L == NULL)
		return 0;

	luaL_openlibs(L);

#ifdef LUAJIT
	/* See https://luajit.org/running.html. */
	luaL_dostring(L, "jit.opt.start('hotloop=1')");
	luaL_dostring(L, "jit.opt.start('hotexit=1')");
	luaL_dostring(L, "jit.opt.start('recunroll=1')");
	luaL_dostring(L, "jit.opt.start('callunroll=1')");
#endif /* LUAJIT */

	const char *mode = "t";
	int res = luaL_loadbufferx(L, (const char *)data, size, "fuzz", mode);
	if (res == LUA_OK) {
		lua_pcall(L, 0, 0, 0);
	}

	lua_settop(L, 0);
	lua_close(L);

	return 0;
}
