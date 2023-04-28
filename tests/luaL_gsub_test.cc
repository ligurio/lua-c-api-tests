#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>

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

	size_t max_length = fdp.ConsumeIntegralInRange<size_t>(1, INT8_MAX);
	auto str1 = fdp.ConsumeRandomLengthString(max_length);
	auto str2 = fdp.ConsumeRandomLengthString(max_length);
	auto str3 = fdp.ConsumeRandomLengthString(max_length);
	const char *c_str1 = str1.c_str();
	const char *c_str2 = str2.c_str();
	const char *c_str3 = str3.c_str();
	if (strlen(c_str1) == 0 ||
	    strlen(c_str2) == 0 ||
	    strlen(c_str3) == 0)
		return -1;
	luaL_gsub(L, c_str1, c_str2, c_str3);

	lua_settop(L, 0);
	lua_close(L);

	return 0;
}
