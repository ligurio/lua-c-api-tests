macro(build_lua LUA_VERSION)
    set(LUA_SOURCE_DIR ${PROJECT_BINARY_DIR}/lua-${LUA_VERSION}/source)
    set(LUA_BINARY_DIR ${PROJECT_BINARY_DIR}/lua-${LUA_VERSION}/work)

    set(LUA_PATCH_PATH ${PROJECT_SOURCE_DIR}/patches/puc-rio-lua.patch)

    set(CFLAGS "${CMAKE_C_FLAGS} -fno-omit-frame-pointer")
    if (ENABLE_LUA_ASSERT)
        set(CFLAGS "${CFLAGS} -DLUAI_ASSERT")
    endif (ENABLE_LUA_ASSERT)
    if (ENABLE_LUA_APICHECK)
        set(CFLAGS "${CFLAGS} -DLUA_USE_APICHECK")
    endif (ENABLE_LUA_APICHECK)
    set(CFLAGS "${CFLAGS} -fsanitize=fuzzer-no-link")
    set(LDFLAGS "-fsanitize=fuzzer-no-link")
    if (OSS_FUZZ)
        set(LDFLAGS "${CFLAGS} ${LDFLAGS}")
    endif (OSS_FUZZ)

    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(CFLAGS "${CFLAGS} ${CMAKE_C_FLAGS_DEBUG}")
        set(LDFLAGS "${LDFLAGS} ${CMAKE_C_FLAGS_DEBUG}")
    endif (CMAKE_BUILD_TYPE STREQUAL "Debug")

    if (ENABLE_ASAN)
        set(CFLAGS "${CFLAGS} -fsanitize=${ASAN_TYPE} -fsanitize=pointer-subtract -fsanitize=pointer-compare")
        set(LDFLAGS "${LDFLAGS} -fsanitize=${ASAN_TYPE}")
    endif (ENABLE_ASAN)

    if (ENABLE_UBSAN)
        string(JOIN "," NO_SANITIZE_FLAGS
            # lvm.c:luaV_execute()
            float-divide-by-zero
            # lgc.c:sweepstep()
            implicit-integer-sign-change
            # lvm.c:luaV_execute()
            integer-divide-by-zero
            # The object size sanitizer has no effect at -O0.
            object-size
            # lstring.c:luaS_hash()
            shift
            # lstring.c:luaS_hash()
            unsigned-integer-overflow
            # lstring.c:luaS_hash()
            unsigned-shift-base
        )
        set(UBSAN_FLAGS "-fsanitize=undefined")
        set(UBSAN_FLAGS "-fno-sanitize-recover=undefined")
        set(UBSAN_FLAGS "-fno-sanitize=${NO_SANITIZE_FLAGS}")
        set(CFLAGS "${CFLAGS} ${UBSAN_FLAGS}")
        set(LDFLAGS "${LDFLAGS} ${UBSAN_FLAGS}")
    endif (ENABLE_UBSAN)

    if (ENABLE_COV)
        set(CFLAGS "${CFLAGS} -fprofile-instr-generate  -fprofile-arcs -fcoverage-mapping -ftest-coverage")
        set(LDFLAGS "${LDFLAGS} -fprofile-instr-generate -fprofile-arcs -fcoverage-mapping -ftest-coverage")
    endif (ENABLE_COV)


    include(ExternalProject)

    ExternalProject_Add(patched-lua-${LUA_VERSION}
        GIT_REPOSITORY https://github.com/lua/lua
        GIT_TAG ${LUA_VERSION}
        GIT_PROGRESS TRUE
        GIT_SHALLOW FALSE

        SOURCE_DIR ${LUA_SOURCE_DIR}
        BINARY_DIR ${LUA_BINARY_DIR}
        DOWNLOAD_DIR ${LUA_BINARY_DIR}
        TMP_DIR ${LUA_BINARY_DIR}/tmp
        STAMP_DIR ${LUA_BINARY_DIR}/stamp

        PATCH_COMMAND cd <SOURCE_DIR> && patch -p1 -i ${LUA_PATCH_PATH}
        CONFIGURE_COMMAND ""
        BUILD_COMMAND cd <SOURCE_DIR> && make -j CC=${CMAKE_C_COMPILER}
                                                 CFLAGS=${CFLAGS}
                                                 LDFLAGS=${LDFLAGS}
                                                 a
        INSTALL_COMMAND ""
        UPDATE_DISCONNECTED ON

        BUILD_BYPRODUCTS ${PROJECT_BINARY_DIR}/lua-${LUA_VERSION}/source/liblua.a
    )

    set(LUA_INCLUDE_DIR ${PROJECT_BINARY_DIR}/lua-${LUA_VERSION}/source/)
    set(LUA_LIBRARIES ${PROJECT_BINARY_DIR}/lua-${LUA_VERSION}/source/liblua.a)
    set(LUA_VERSION_STRING "PUC Rio Lua ${LUA_VERSION}")
    set(LUA_TARGET patched-lua-${LUA_VERSION})

    unset(LUA_BINARY_DIR)
    unset(LUA_PATCH_PATH)
endmacro(build_lua)
