#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>

#include <lua.h>
#include <lauxlib.h>

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
	lua_State *L = luaL_newstate();
	if (L == NULL)
		return 0;

	luaL_openlibs(L);

	size_t str_len = size + 1;
	char *str = calloc(str_len, sizeof(char));
	if (str == NULL)
		return 0;
	memcpy(str, data, size);
	str[size] = '\0';

	luaL_dostring(L, str);

	free(str);
	lua_settop(L, 0);
	lua_close(L);

	return 0;
}
