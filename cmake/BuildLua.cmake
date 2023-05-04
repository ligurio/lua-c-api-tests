macro(build_lua LUA_VERSION)
    set(LUA_SOURCE_DIR ${PROJECT_BINARY_DIR}/lua-${LUA_VERSION}/source)
    set(LUA_BINARY_DIR ${PROJECT_BINARY_DIR}/lua-${LUA_VERSION}/work)

    set(LUA_PATCH_PATH ${PROJECT_SOURCE_DIR}/patches/puc-rio-lua.patch)

    set(CFLAGS "-DLUAI_ASSERT=1 -DLUA_USE_APICHECK=1 -fsanitize=fuzzer-no-link")
    set(LDFLAGS "-fsanitize=fuzzer-no-link")

    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(CFLAGS "${CFLAGS} -g")
        set(LDFLAGS "${LDFLAGS} -g")
    endif (CMAKE_BUILD_TYPE)

    if (ENABLE_ASAN)
        set(CFLAGS "${CFLAGS} -fsanitize=address -fsanitize=pointer-subtract -fsanitize=pointer-compare")
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

    ExternalProject_Add(patched-lua-${LUA_VERSION}
        GIT_REPOSITORY https://github.com/lua/lua
        GIT_TAG ${LUA_VERSION}
        GIT_PROGRESS TRUE
        GIT_SHALLOW TRUE

        SOURCE_DIR ${LUA_SOURCE_DIR}
        BINARY_DIR ${LUA_BINARY_DIR}
        DOWNLOAD_DIR ${LUA_BINARY_DIR}
        TMP_DIR ${LUA_BINARY_DIR}/tmp
        STAMP_DIR ${LUA_BINARY_DIR}/stamp

        PATCH_COMMAND cd <SOURCE_DIR> && patch -p1 -i ${LUA_PATCH_PATH}
        CONFIGURE_COMMAND ""
        BUILD_COMMAND cd <SOURCE_DIR> && make -j CC=${CMAKE_C_COMPILER} CFLAGS=${CFLAGS} LDFLAGS=${LDFLAGS}
        INSTALL_COMMAND ""
        UPDATE_DISCONNECTED ON

        BUILD_BYPRODUCTS ${PROJECT_BINARY_DIR}/lua-${LUA_VERSION}/source/liblua.a
    )

    set(LUA_INCLUDE_DIR ${PROJECT_BINARY_DIR}/lua-${LUA_VERSION}/source/)
    set(LUA_LIBRARIES ${PROJECT_BINARY_DIR}/lua-${LUA_VERSION}/source/liblua.a)
    set(LUA_VERSION_STRING "PUC Rio Lua ${LUA_VERSION}")
    set(LUA_TARGET patched-lua-${LUA_VERSION})

    unset(LUA_SOURCE_DIR)
    unset(LUA_BINARY_DIR)
    unset(LUA_PATCH_PATH)
endmacro(build_lua)
