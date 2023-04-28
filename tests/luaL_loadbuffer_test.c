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

	int res = luaL_loadbuffer(L, (const char *)data, size, "fuzz");
	if (res != LUA_OK)
		return 0;
	lua_pcall(L, 0, 0, 0);

	lua_settop(L, 0);
	lua_close(L);

	return 0;
}
