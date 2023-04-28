#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

#include <fuzzer/FuzzedDataProvider.h>

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#if defined(__cplusplus)
} /* extern "C" */
#endif /* defined(__cplusplus) */

extern "C" int
LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
	FuzzedDataProvider fdp(data, size);

	lua_State *L = luaL_newstate();
	if (L == NULL)
		return 0;

	luaL_Buffer buf;
	size_t buf_size = fdp.ConsumeIntegralInRange<int8_t>(0, INT8_MAX);
	char *s = luaL_buffinitsize(L, &buf, buf_size);
	auto str = fdp.ConsumeRandomLengthString(buf_size);
	memcpy(s, str.c_str(), buf_size);
	luaL_pushresultsize(&buf, buf_size);
	int8_t n = fdp.ConsumeIntegralInRange<int8_t>(0, buf_size);
	luaL_buffsub(&buf, n);

	assert(luaL_bufflen(&buf) == buf_size - n);
	lua_settop(L, 0);
	lua_close(L);

	return 0;
}
