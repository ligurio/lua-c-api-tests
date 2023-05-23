macro(build_luajit LJ_VERSION)
    set(LJ_SOURCE_DIR ${PROJECT_BINARY_DIR}/luajit-${LJ_VERSION}/source)
    set(LJ_BINARY_DIR ${PROJECT_BINARY_DIR}/luajit-${LJ_VERSION}/work)

    set(CFLAGS "-DLUAI_ASSERT=1 -DLUA_USE_APICHECK=1 -fsanitize=fuzzer-no-link")
    set(LDFLAGS "-fsanitize=fuzzer-no-link")

    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(CFLAGS "${CFLAGS} ${CMAKE_C_FLAGS_DEBUG}")
        set(LDFLAGS "${LDFLAGS} ${CMAKE_C_FLAGS_DEBUG}")
    endif (CMAKE_BUILD_TYPE STREQUAL "Debug")

    if (ENABLE_ASAN)
        set(CFLAGS "${CFLAGS} -fsanitize=address")
        set(LDFLAGS "${LDFLAGS} -fsanitize=address")
    endif (ENABLE_ASAN)

    if (ENABLE_UBSAN)
        set(CFLAGS "${CFLAGS} -fsanitize=undefined")
        set(LDFLAGS "${LDFLAGS} -fsanitize=undefined")
    endif (ENABLE_UBSAN)

    if (ENABLE_COV)
        set(CFLAGS "${CFLAGS} -fprofile-instr-generate -fcoverage-mapping")
        set(LDFLAGS "${LDFLAGS} -fprofile-instr-generate -fcoverage-mapping")
    endif (ENABLE_COV)


    include(ExternalProject)

    ExternalProject_Add(patched-luajit-${LJ_VERSION}
        GIT_REPOSITORY https://github.com/LuaJIT/LuaJIT
        GIT_TAG ${LJ_VERSION}
        GIT_PROGRESS TRUE
        GIT_SHALLOW FALSE

        SOURCE_DIR ${LJ_SOURCE_DIR}
        BINARY_DIR ${LJ_BINARY_DIR}/luajit-${LJ_VERSION}
        DOWNLOAD_DIR ${LJ_BINARY_DIR}
        TMP_DIR ${LJ_BINARY_DIR}/tmp
        STAMP_DIR ${LJ_BINARY_DIR}/stamp

        CONFIGURE_COMMAND ""
        BUILD_COMMAND cd <SOURCE_DIR> && make -j CC=${CMAKE_C_COMPILER} CFLAGS=${CFLAGS} LDFLAGS=${LDFLAGS}
        INSTALL_COMMAND ""
        UPDATE_DISCONNECTED ON

        BUILD_BYPRODUCTS ${LJ_SOURCE_DIR}/src/libluajit.a
    )

    set(LUA_INCLUDE_DIR ${LJ_SOURCE_DIR}/src/)
    set(LUA_LIBRARIES ${LJ_SOURCE_DIR}/src/libluajit.a)
    set(LUA_VERSION_STRING "LuaJIT ${LJ_VERSION}")
    set(LUA_TARGET patched-luajit-${LJ_VERSION})

    unset(LJ_SOURCE_DIR)
    unset(LJ_BINARY_DIR)
endmacro(build_luajit)
