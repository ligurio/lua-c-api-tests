set(CFLAGS ${CMAKE_C_FLAGS})
if (ENABLE_COV)
    set(CFLAGS "${CFLAGS} -fprofile-instr-generate -fprofile-arcs -fcoverage-mapping -ftest-coverage")
    set(LDFLAGS "${LDFLAGS} -fprofile-instr-generate -fprofile-arcs -fcoverage-mapping -ftest-coverage")
endif (ENABLE_COV)

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CFLAGS ${CFLAGS} ${CMAKE_C_FLAGS_DEBUG})
    set(LDFLAGS ${LDFLAGS} ${CMAKE_C_FLAGS_DEBUG})
endif (CMAKE_BUILD_TYPE STREQUAL "Debug")

add_library(lua_mutate STATIC mutate.c)
target_link_libraries(lua_mutate PRIVATE ${LUA_LIBRARIES} ${LDFLAGS})
target_include_directories(lua_mutate PRIVATE ${LUA_INCLUDE_DIR})
target_compile_options(lua_mutate PRIVATE ${CFLAGS} -Wall -Wextra -Wpedantic -Wno-unused-parameter)
add_dependencies(lua_mutate ${LUA_TARGET})

add_library(lua_crossover STATIC crossover.c)
target_link_libraries(lua_crossover PRIVATE ${LUA_LIBRARIES} ${LDFLAGS})
target_include_directories(lua_crossover PRIVATE ${LUA_INCLUDE_DIR})
target_compile_options(lua_crossover PRIVATE ${CFLAGS} -Wall -Wextra -Wpedantic -Wno-unused-parameter)
add_dependencies(lua_crossover ${LUA_TARGET})

add_subdirectory(tests)
