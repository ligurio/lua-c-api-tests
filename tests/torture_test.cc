/*
 * SPDX-License-Identifier: ISC
 *
 * Copyright 2023, Sergey Bronnikov.
 */

/**
 * Each Lua C API function has an indicator like this: [-o, +p, x],
 * see "4.6 – Functions and Types" in Lua Reference Manual.
 *
 * The test pushes random Lua objects to a Lua stack, runs random Lua C API
 * functions and checks that executed function conforms to its function
 * indicator.
 */

#include <assert.h>
#include <stdint.h>

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

#define ARRAY_SIZE(arr)     (sizeof(arr) / sizeof((arr)[0]))

int max_str_len = 1;

static int
cfunction(lua_State *L) {
	lua_gettop(L);
	return 0;
}

/* void lua_pushstring(lua_State *L, const char *s); */
/* [-0, +1, m] */
static void
__lua_pushstring(lua_State *L, FuzzedDataProvider *fdp)
{
	auto str = fdp->ConsumeRandomLengthString(max_str_len);
	int top = lua_gettop(L);
	lua_pushstring(L, str.c_str());
	assert(lua_gettop(L) == top + 1);
}

/* void lua_pushboolean(lua_State *L, int b); */
/* [-0, +1, -] */
static void
__lua_pushboolean(lua_State *L, FuzzedDataProvider *fdp)
{
	uint8_t n = fdp->ConsumeIntegral<uint8_t>();
	int top = lua_gettop(L);
	lua_pushboolean(L, n);
	assert(lua_gettop(L) == top + 1);
}

/* void lua_pop(lua_State *L, int n); */
/* [-n, +0, -] */
static void
__lua_pop(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t n = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	lua_pop(L, n);
	assert(lua_gettop(L) == top - n);
}

/* int lua_isnumber(lua_State *L, int index); */
/* [-0, +0, -] */
static void
__lua_isnumber(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t n = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	lua_isnumber(L, n);
	assert(lua_gettop(L) == top);
}

/* lua_Number lua_tonumber(lua_State *L, int index); */
/* [-0, +0, -] */
static void
__lua_tonumber(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t n = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	lua_tonumber(L, n);
	assert(lua_gettop(L) == top);
}

/* int lua_checkstack(lua_State *L, int extra); */
/* [-0, +0, m] */
static void
__lua_checkstack(lua_State *L, FuzzedDataProvider *fdp)
{
	uint8_t n = fdp->ConsumeIntegral<uint8_t>();
	int rc = lua_checkstack(L, n);
	assert(rc != 0);
}

/* void lua_concat(lua_State *L, int n); */
/* [-n, +1, e] */
static void
__lua_concat(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t n = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	for (int i = 1; i <= n; i++) {
		int t = lua_type(L, -i);
		if (t != LUA_TNUMBER &&
		    t != LUA_TSTRING)
			return;
	}
	lua_concat(L, n);
	assert(lua_gettop(L) == top - n + 1);
}

/* int lua_gettop(lua_State *L); */
/* [-0, +0, -] */
static void
__lua_gettop(lua_State *L, FuzzedDataProvider *fdp)
{
	int rc = lua_gettop(L);
	assert(rc >= 0);
}

/* void lua_insert(lua_State *L, int index); */
/* [-1, +1, -] */
static void
__lua_insert(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	lua_insert(L, index);
	assert(lua_gettop(L) == top - 1 + 1);
}

/* int lua_isboolean(lua_State *L, int index); */
/* [-0, +0, -] */
static void
__lua_isboolean(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	int rc = lua_isboolean(L, index);
	assert(rc == 0 || rc == 1);
}

/* int lua_iscfunction(lua_State *L, int index); */
/* [-0, +0, -] */
static void
__lua_iscfunction(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	int rc = lua_iscfunction(L, index);
	assert(rc == 0 || rc == 1);
}

/* int lua_isfunction(lua_State *L, int index); */
/* [-0, +0, -] */
static void
__lua_isfunction(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	int rc = lua_isfunction(L, index);
	assert(rc == 0 || rc == 1);
}

/* int lua_isnil(lua_State *L, int index); */
/* [-0, +0, -] */
static void
__lua_isnil(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	int rc = lua_isnil(L, index);
	assert(rc == 0 || rc == 1);
}

/* int lua_isnone(lua_State *L, int index); */
/* [-0, +0, -] */
static void
__lua_isnone(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	int rc = lua_isnone(L, index);
	assert(rc == 0 || rc == 1);
	assert(lua_gettop(L) == top);
}

/* int lua_isnoneornil(lua_State *L, int index); */
/* [-0, +0, -] */
static void
__lua_isnoneornil(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	lua_isnoneornil(L, index);
	assert(lua_gettop(L) == top);
}

/* int lua_isstring(lua_State *L, int index); */
/* [-0, +0, -] */
static void
__lua_isstring(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	int rc = lua_isstring(L, index);
	assert(rc == 0 || rc == 1);
}

/* int lua_istable(lua_State *L, int index); */
/* [-0, +0, -] */
static void
__lua_istable(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	int rc = lua_istable(L, index);
	assert(rc == 0 || rc == 1);
}

/* void lua_pushinteger(lua_State *L, lua_Integer n); */
/* [-0, +1, -] */
static void
__lua_pushinteger(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t n = fdp->ConsumeIntegral<uint8_t>();
	lua_pushinteger(L, n);
	assert(lua_gettop(L) == top + 1);
}

/* void lua_pushlstring(lua_State *L, const char *s, size_t len); */
/* [-0, +1, m] */
static void
__lua_pushlstring(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	auto str = fdp->ConsumeRandomLengthString(max_str_len);
	lua_pushlstring(L, str.c_str(), str.size());
	assert(lua_gettop(L) == top + 1);
}

/* void lua_pushnil(lua_State *L); */
/* [-0, +1, -] */
static void
__lua_pushnil(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	lua_pushnil(L);
	assert(lua_gettop(L) == top + 1);
}

/* void lua_pushnumber(lua_State *L, lua_Number n); */
/* [-0, +1, -] */
static void
__lua_pushnumber(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t n = fdp->ConsumeIntegral<uint8_t>();
	lua_pushnumber(L, n);
	assert(lua_gettop(L) == top + 1);
}

/* void lua_pushvalue(lua_State *L, int index); */
/* [-0, +1, -] */
static void
__lua_pushvalue(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	lua_pushvalue(L, index);
	assert(lua_gettop(L) == top + 1);
}

/* void lua_remove(lua_State *L, int index); */
/* [-1, +0, -] */
static void
__lua_remove(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	lua_remove(L, index);
	assert(lua_gettop(L) == top - 1);
}

/* void lua_replace(lua_State *L, int index); */
/* [-1, +0, -] */
static void
__lua_replace(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	lua_replace(L, index);
	assert(lua_gettop(L) == top - 1);
}

/* void lua_setglobal(lua_State *L, const char *name); */
/* [-1, +0, e] */
static void
__lua_setglobal(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	auto str = fdp->ConsumeRandomLengthString(max_str_len);
	lua_setglobal(L, str.c_str());
	assert(lua_gettop(L) == top - 1);
}

/* void lua_settop(lua_State *L, int index); */
/* [-?, +?, -] */
static void
__lua_settop(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	lua_settop(L, index);
	assert(lua_gettop(L) == index);
}

/* int lua_status(lua_State *L); */
/* [-0, +0, -] */
static void
__lua_status(lua_State *L, FuzzedDataProvider *fdp)
{
	int rc = lua_status(L);
	assert(rc == 0 || rc == LUA_YIELD);
}

/* int lua_toboolean(lua_State *L, int index); */
/* [-0, +0, -] */
static void
__lua_toboolean(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	int rc = lua_toboolean(L, index);
	assert(rc == 0 || rc == 1);
}

/* lua_Integer lua_tointeger(lua_State *L, int index); */
/* [-0, +0, -] */
static void
__lua_tointeger(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	lua_tointeger(L, index);
	assert(lua_gettop(L) == top);
}

/* const char *lua_tolstring(lua_State *L, int index, size_t *len); */
/* [-0, +0, m] */
static void
__lua_tolstring(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	lua_tolstring(L, index, NULL);
	assert(lua_gettop(L) == top);
}

/* const char *lua_tostring(lua_State *L, int index); */
/* [-0, +0, m] */
static void
__lua_tostring(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	lua_tostring(L, index);
	assert(lua_gettop(L) == top);
}

/* int lua_type(lua_State *L, int index); */
/* [-0, +0, -] */
static void
__lua_type(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	int type = lua_type(L, index);
	assert(type == LUA_TBOOLEAN       ||
	       type == LUA_TFUNCTION      ||
	       type == LUA_TLIGHTUSERDATA ||
	       type == LUA_TNIL           ||
	       type == LUA_TNONE          ||
	       type == LUA_TNUMBER        ||
	       type == LUA_TSTRING        ||
	       type == LUA_TTABLE         ||
	       type == LUA_TTHREAD        ||
	       type == LUA_TUSERDATA);
	assert(lua_gettop(L) == top);
}

/* void lua_getglobal(lua_State *L, const char *name); */
/* [-0, +1, e] */
static void
__lua_getglobal(lua_State *L, FuzzedDataProvider *fdp)
{
	auto name = fdp->ConsumeRandomLengthString(max_str_len);
	int top = lua_gettop(L);
	lua_getglobal(L, name.c_str());
	assert(lua_gettop(L) == top + 1);
}

/* const char *lua_setupvalue(lua_State *L, int funcindex, int n); */
/* [-(0|1), +0, –] */
static void
__lua_setupvalue(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	int funcindex = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	int n = fdp->ConsumeIntegral<uint8_t>();
	lua_setupvalue(L, funcindex, n);
	assert(lua_gettop(L) == top);
}

/* const char *lua_getupvalue(lua_State *L, int funcindex, int n); */
/* [-0, +(0|1), –] */
static void
__lua_getupvalue(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	int funcindex = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	int n = fdp->ConsumeIntegral<uint8_t>();
	lua_getupvalue(L, funcindex, n);
	assert(lua_gettop(L) == top || lua_gettop(L) == top + 1);
}

/* [-0, +0, -] */
/* void *lua_touserdata(lua_State *L, int index); */
static void
__lua_touserdata(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	lua_touserdata(L, index);
	assert(lua_gettop(L) == top);
}

/* int lua_islightuserdata(lua_State *L, int index); */
/* [-0, +0, -] */
static void
__lua_islightuserdata(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	int rc = lua_islightuserdata(L, index);
	assert(rc == 0 || rc == 1);
}

/* int lua_isuserdata(lua_State *L, int index); */
/* [-0, +0, -] */
static void
__lua_isuserdata(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	int rc = lua_isuserdata(L, index);
	assert(rc == 0 || rc == 1);
}

/* int lua_isthread(lua_State *L, int index); */
/* [-0, +0, -] */
static void
__lua_isthread(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	int rc = lua_isthread(L, index);
	assert(rc == 0 || rc == 1);
}

/* int lua_pushthread(lua_State *L); */
/* [-0, +1, -] */
static void
__lua_pushthread(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	int rc = lua_pushthread(L);
	assert(rc == 1);
	assert(lua_gettop(L) == top + 1);
}

/* int lua_next(lua_State *L, int index); */
/* [-1, +(2|0), e] */
static void
__lua_next(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	if (!lua_istable(L, index))
		return;
	lua_pushnil(L);  /* first key */
	lua_next(L, index);
	assert(lua_gettop(L) - top - 1 <= 2);
}

/* int lua_getinfo(lua_State *L, const char *what, lua_Debug *ar); */
/* [-(0|1), +(0|1|2), m] */
static void
__lua_getinfo(lua_State *L, FuzzedDataProvider *fdp)
{
	lua_Debug ar;
	lua_pushcfunction(L, cfunction);
	/* XXX: Choose 'what' mode randomly. */
	lua_getinfo(L, ">", &ar);
}

/* int lua_getstack(lua_State *L, int level, lua_Debug *ar); */
/* [-0, +0, –] */
static void
__lua_getstack(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	int max_stack_depth = 10;
	int level = fdp->ConsumeIntegralInRange<uint8_t>(1, max_stack_depth);
	lua_Debug ar;
	lua_getstack(L, level, &ar);
	assert(lua_gettop(L) == top);
}

/* void lua_pushcclosure(lua_State *L, lua_CFunction fn, int n); */
/* [-n, +1, m] */
static void
__lua_pushcclosure(lua_State *L, FuzzedDataProvider *fdp)
{
	/* Maximum n is 255 in lua_pushcclosure(3). */
	int n = fdp->ConsumeIntegralInRange<uint8_t>(1, 10);
	for (int i = 1; i < n; i++)
		lua_pushnumber(L, i);
	lua_pushcclosure(L, cfunction, n);
}

/* void lua_pushcfunction(lua_State *L, lua_CFunction f); */
/* [-0, +1, m] */
static void
__lua_pushcfunction(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	lua_pushcfunction(L, cfunction);
	assert(lua_gettop(L) == top + 1);
}

/* int lua_getmetatable(lua_State *L, int index); */
/* [-0, +(0|1), -] */
static void
__lua_getmetatable(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	lua_getmetatable(L, index);
	assert(lua_gettop(L) - top <= 1);
}

/* void lua_newtable(lua_State *L); */
/* [-0, +1, m] */
static void
__lua_newtable(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	lua_newtable(L);
	assert(lua_gettop(L) == top + 1);
}

/* lua_State *lua_newthread(lua_State *L); */
/* [-0, +1, m] */
static void
__lua_newthread(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	lua_newthread(L);
	assert(lua_gettop(L) == top + 1);
}

/* const char *lua_typename(lua_State *L, int tp); */
/* [-0, +0, -] */
static void
__lua_typename(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	const char* name = lua_typename(L, index);
	assert(name);
	assert(lua_gettop(L) == top);
}

int gc_mode[] = {
	LUA_GCCOLLECT,
	LUA_GCCOUNT,
	LUA_GCCOUNTB,
	LUA_GCRESTART,
	LUA_GCSETPAUSE,
	LUA_GCSETSTEPMUL,
	LUA_GCSTEP,
	LUA_GCSTOP,
};

/* int lua_gc(lua_State *L, int what, int data); */
/* [-0, +0, e] */
static void
__lua_gc(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t idx = fdp->ConsumeIntegralInRange<uint8_t>(0, ARRAY_SIZE(gc_mode) - 1);
	lua_gc(L, gc_mode[idx], 0);
	assert(lua_gettop(L) == top);
}

int hook_mode[] = {
	LUA_MASKCALL,
	LUA_MASKCOUNT,
	LUA_MASKLINE,
	LUA_MASKRET,
};

static void
Hook(lua_State *L, lua_Debug *ar)
{
	(void)L;
	(void)ar;
}

/* int lua_sethook(lua_State *L, lua_Hook f, int mask, int count); */
/* [-0, +0, -] */
static void
__lua_sethook(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t idx = fdp->ConsumeIntegralInRange<uint8_t>(0, ARRAY_SIZE(hook_mode) - 1);
	lua_sethook(L, Hook, hook_mode[idx], 1);
	assert(lua_gettop(L) == top);
}

/* lua_Hook lua_gethook(lua_State *L); */
/* [-0, +0, –] */
static void
__lua_gethook(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	lua_gethook(L);
	assert(lua_gettop(L) == top);
}

/* int lua_gethookcount(lua_State *L); */
/* [-0, +0, –] */
static void
__lua_gethookcount(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	int hook_count = lua_gethookcount(L);
	assert(hook_count >= 0);
	assert(lua_gettop(L) == top);
}

/* int lua_gethookmask(lua_State *L); */
/* [-0, +0, –] */
static void
__lua_gethookmask(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	int hook_mask = lua_gethookmask(L);
	assert(hook_mask >= 0);
	assert(lua_gettop(L) == top);
}

/* void lua_rawget(lua_State *L, int index); */
/* [-1, +1, -] */
static void
__lua_rawget(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	if (!lua_istable(L, index))
		return;
	uint8_t key = fdp->ConsumeIntegral<uint8_t>();
	lua_pushnumber(L, key);
	lua_rawget(L, index);
	/* XXX: Wrong number of elements. */
	/* assert(lua_gettop(L) == top); */
}

/* void lua_rawset(lua_State *L, int index); */
/* [-2, +0, m] */
static void
__lua_rawset(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	if (top == 0)
		return;
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	if (!lua_istable(L, index))
	/* if (lua_type(L, index) != LUA_TTABLE) */
		return;
	uint8_t key = fdp->ConsumeIntegral<uint8_t>();
	uint8_t value = fdp->ConsumeIntegral<uint8_t>();
	lua_pushnumber(L, value);
	lua_pushnumber(L, key);
	lua_rawset(L, index);
	/* XXX: Wrong number of elements. */
	/* assert(lua_gettop(L) == top - 2); */
}

/* void lua_rawseti(lua_State *L, int index, lua_Integer i); */
/* [-1, +0, m] */
static void
__lua_rawseti(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	if (!lua_istable(L, index))
		return;
	int n = fdp->ConsumeIntegral<uint8_t>();
	__lua_pushnumber(L, fdp);
	lua_rawseti(L, index, n);
	/* XXX: Wrong number of elements. */
	/* assert(lua_gettop(L) == top - 1); */
}

/* int lua_rawgeti(lua_State *L, int index, lua_Integer n); */
/* [-0, +1, –] */
static void
__lua_rawgeti(lua_State *L, FuzzedDataProvider *fdp)
{
	int top = lua_gettop(L);
	uint8_t index = fdp->ConsumeIntegralInRange<uint8_t>(1, top);
	if (!lua_istable(L, index))
		return;
	int i = fdp->ConsumeIntegral<uint8_t>();
	lua_rawgeti(L, index, i);
	assert(lua_gettop(L) == top + 1);
}

typedef void
(*lua_func)(lua_State *L, FuzzedDataProvider *fdp);

static lua_func push_func[] = {
	&__lua_newtable,
	&__lua_newthread,
	&__lua_pushboolean,
	&__lua_pushinteger,
	&__lua_pushlstring,
	&__lua_pushnil,
	&__lua_pushnumber,
	&__lua_pushstring,
};

static void
lua_pushrandom(lua_State *L, FuzzedDataProvider *fdp)
{
	uint8_t idx = fdp->ConsumeIntegralInRange(0, (int)ARRAY_SIZE(push_func) - 1);
	push_func[idx](L, fdp);
}

/* void lua_createtable(lua_State *L, int narr, int nrec); */
/* [-0, +1, m] */
static void
__lua_createtable(lua_State *L, FuzzedDataProvider *fdp)
{
	int nrows = fdp->ConsumeIntegral<uint8_t>();
	/* XXX: Lua associative arrays. */
	lua_createtable(L, nrows, 0);
	for (int i = 0; i < nrows; i++) {
		lua_pushnumber(L, i);
		lua_rawseti(L, -2, i + 1);
	}
	assert(lua_gettop(L) != 0);
}

lua_func func[] = {
	&__lua_checkstack,
	&__lua_concat,
	&__lua_createtable,
	&__lua_gc,
	&__lua_getglobal,
	&__lua_gethook,
	&__lua_gethookcount,
	&__lua_gethookmask,
	&__lua_getinfo,
	&__lua_getmetatable,
	&__lua_getstack,
	&__lua_gettop,
	&__lua_getupvalue,
	&__lua_insert,
	&__lua_isboolean,
	&__lua_iscfunction,
	&__lua_isfunction,
	&__lua_islightuserdata,
	&__lua_isnil,
	&__lua_isnone,
	&__lua_isnoneornil,
	&__lua_isnumber,
	&__lua_isstring,
	&__lua_istable,
	&__lua_isthread,
	&__lua_isuserdata,
	&__lua_newtable,
	&__lua_newthread,
	&__lua_next,
	&__lua_pop,
	&__lua_pushboolean,
	&__lua_pushcclosure,
	&__lua_pushcfunction,
	&__lua_pushinteger,
	&__lua_pushlstring,
	&__lua_pushnil,
	&__lua_pushnumber,
	&__lua_pushstring,
	&__lua_pushthread,
	&__lua_pushvalue,
	&__lua_rawget,
	&__lua_rawgeti,
	&__lua_rawset,
	&__lua_rawseti,
	&__lua_remove,
	&__lua_replace,
	&__lua_setglobal,
	&__lua_settop,
	&__lua_setupvalue,
	&__lua_status,
	&__lua_toboolean,
	&__lua_tointeger,
	&__lua_tolstring,
	&__lua_tonumber,
	&__lua_tostring,
	&__lua_touserdata,
	&__lua_type,
	&__lua_typename,
};

extern "C" int
LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
	lua_State *L = luaL_newstate();
	if (L == NULL)
		return 0;

	FuzzedDataProvider fdp(data, size);
	int start_slots = 2;
	for (int i = 1; i <= start_slots; i++)
		if (fdp.remaining_bytes() != 0)
			lua_pushrandom(L, &fdp);

	if (lua_gettop(L) != 0 &&
	    fdp.remaining_bytes() != 0) {
		__lua_gc(L, &fdp);
		__lua_sethook(L, &fdp);
		uint8_t idx = fdp.ConsumeIntegralInRange<uint8_t>(0, (int)ARRAY_SIZE(func) - 1);
		func[idx](L, &fdp);
	}

	lua_settop(L, 0);
	lua_close(L);

	return 0;
}
