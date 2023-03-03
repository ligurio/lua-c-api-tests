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

	luaL_Buffer buf;
	luaL_buffinitsize(L, &buf, size);
	luaL_addlstring(&buf, (const char *)data, size);
	if (luaL_buffaddr(&buf) == NULL)
		return 0;
	luaL_pushresultsize(&buf, size);

	lua_settop(L, 0);
	lua_close(L);

	return 0;
}
