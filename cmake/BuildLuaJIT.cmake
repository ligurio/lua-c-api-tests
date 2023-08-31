macro(build_luajit LJ_VERSION)
    set(LJ_SOURCE_DIR ${PROJECT_BINARY_DIR}/luajit-${LJ_VERSION}/source)
    set(LJ_BINARY_DIR ${PROJECT_BINARY_DIR}/luajit-${LJ_VERSION}/work)

    set(CFLAGS ${CMAKE_C_FLAGS})
    if (ENABLE_LUA_ASSERT)
        set(CFLAGS "${CFLAGS} -DLUA_USE_ASSERT")
    endif (ENABLE_LUA_ASSERT)
    if (ENABLE_LUA_APICHECK)
        set(CFLAGS "${CFLAGS} -DLUA_USE_APICHECK")
    endif (ENABLE_LUA_APICHECK)

    set(CFLAGS "${CFLAGS} -fsanitize=fuzzer-no-link")
    set(LDFLAGS "-fsanitize=fuzzer-no-link")

    set(LUAJIT_PATCH_PATH ${PROJECT_SOURCE_DIR}/patches/luajit-v2.1.patch)

    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(CFLAGS "${CFLAGS} ${CMAKE_C_FLAGS_DEBUG}")
        set(LDFLAGS "${LDFLAGS} ${CMAKE_C_FLAGS_DEBUG}")
    endif (CMAKE_BUILD_TYPE STREQUAL "Debug")

    if (ENABLE_LUAJIT_RANDOM_RA)
        set(CFLAGS "${CFLAGS} -DLUAJIT_RANDOM_RA")
    endif (ENABLE_LUAJIT_RANDOM_RA)

    if (ENABLE_ASAN)
        set(CFLAGS "${CFLAGS} -fsanitize=address")
        set(CFLAGS "${CFLAGS} -DLUAJIT_USE_ASAN")
        set(CFLAGS "${CFLAGS} -DLUAJIT_USE_SYSMALLOC=1")
        set(LDFLAGS "${LDFLAGS} -fsanitize=address")
    endif (ENABLE_ASAN)

    if (ENABLE_UBSAN)
        string(JOIN "," NO_SANITIZE_FLAGS
            # lj_str.c
            implicit-integer-sign-change
            # lj_opt_fold.c
            implicit-unsigned-integer-truncation
            # lj_parse.c
            alignment
            # lj_tab.c
            float-cast-overflow
            # lj_gc.c
            function
            # lj_buf.c
            shift
            # lj_obj.h
            unsigned-integer-overflow
            # lj_prng.c
            unsigned-shift-base
            # lj_parse.c
            pointer-overflow
            # The object size sanitizer has no effect at -O0.
            object-size
            # lj_parse.c
            null
            # lj_vmmath.c
            float-divide-by-zero
            integer-divide-by-zero
        )
        set(UBSAN_FLAGS "-fsanitize=undefined")
        set(UBSAN_FLAGS "-fno-sanitize-recover=undefined")
        set(UBSAN_FLAGS "-fno-sanitize=${NO_SANITIZE_FLAGS}")
        set(CFLAGS "${CFLAGS} ${UBSAN_FLAGS}")
        set(LDFLAGS "${LDFLAGS} ${UBSAN_FLAGS}")
    endif (ENABLE_UBSAN)

    if (ENABLE_COV)
        set(CFLAGS "${CFLAGS} -fprofile-instr-generate -fprofile-arcs -fcoverage-mapping -ftest-coverage")
        set(LDFLAGS "${LDFLAGS} -fprofile-instr-generate -fprofile-arcs -fcoverage-mapping -ftest-coverage")
    endif (ENABLE_COV)


    include(ExternalProject)

    set(LUA_LIBRARIES ${LJ_SOURCE_DIR}/src/libluajit.a)
    set(LUA_EXECUTABLE ${LJ_SOURCE_DIR}/src/luajit)

    ExternalProject_Add(patched-luajit-${LJ_VERSION}
        GIT_REPOSITORY https://github.com/LuaJIT/LuaJIT
        GIT_TAG ${LJ_VERSION}
        GIT_PROGRESS TRUE
        GIT_SHALLOW FALSE
        GIT_REMOTE_UPDATE_STRATEGY REBASE

        SOURCE_DIR ${LJ_SOURCE_DIR}
        BINARY_DIR ${LJ_BINARY_DIR}/luajit-${LJ_VERSION}
        DOWNLOAD_DIR ${LJ_BINARY_DIR}
        TMP_DIR ${LJ_BINARY_DIR}/tmp
        STAMP_DIR ${LJ_BINARY_DIR}/stamp

        PATCH_COMMAND cd <SOURCE_DIR> && patch -p1 -i ${LUAJIT_PATCH_PATH}
        CONFIGURE_COMMAND ""
        BUILD_COMMAND cd <SOURCE_DIR> && make -j CC=${CMAKE_C_COMPILER}
                                                 CFLAGS=${CFLAGS}
                                                 LDFLAGS=${LDFLAGS}
                                                 HOST_CFLAGS=-fno-sanitize=undefined
                                                 -C src
        INSTALL_COMMAND ""

        BUILD_BYPRODUCTS ${LUA_LIBRARIES} ${LUA_EXECUTABLE}
    )

    set(LUA_SOURCE_DIR ${LJ_SOURCE_DIR})
    set(LUA_INCLUDE_DIR ${LJ_SOURCE_DIR}/src/)
    set(LUA_VERSION_STRING "LuaJIT ${LJ_VERSION}")
    set(LUA_TARGET patched-luajit-${LJ_VERSION})

    unset(LJ_SOURCE_DIR)
    unset(LJ_BINARY_DIR)
endmacro(build_luajit)
