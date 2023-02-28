#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
/* #include <llimits.h> */
/* #include <lobject.h> */

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
	/* if (size >= (MAX_SIZE - sizeof(TString))/sizeof(char)) */
	/* 	return -1; */

	lua_State *L = luaL_newstate();
	if (L == NULL)
		return 0;

	luaL_Buffer buf;
	luaL_buffinitsize(L, &buf, size);
	luaL_addlstring(&buf, (const char *)data, size);
	/* TODO: Use FDP. */
	luaL_buffsub(&buf, 1);

	/* assert(luaL_bufflen(&buf) != 0); */
	/* luaL_pushresultsize(&buf, size); */
	lua_settop(L, 0);
	lua_close(L);

	return 0;
}
