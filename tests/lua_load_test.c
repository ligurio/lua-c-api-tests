#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

typedef struct {
	FILE *fd;
	size_t sz;
} dt;

static const char *
Reader(lua_State *L, void *data, size_t *size)
{
	dt *test_data = (dt *)data;
	static char *buf = NULL;

	free(buf);

	buf = malloc(test_data->sz);
	fread(buf, test_data->sz, 1, test_data->fd);

	return buf;
}

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
	lua_State *L = luaL_newstate();
	if (L == NULL)
		return 0;

	luaL_openlibs(L);

	FILE *fd = fmemopen((void *)data, size, "r");
	if (fd == NULL)
		return 0;

	dt test_data;
	test_data.fd = fd;
	test_data.sz = 1;

	const char *mode = "bt";
	int res = lua_load(L, Reader, &test_data, "libFuzzer", mode);
	if (res != LUA_OK)
		return 0;
	lua_pcall(L, 0, 0, 0);

	if (test_data.fd != NULL)
		fclose(test_data.fd);
	lua_settop(L, 0);
	lua_close(L);

	return 0;
}
