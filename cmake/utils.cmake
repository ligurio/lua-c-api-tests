# SPDX-License-Identifier: BSD-2-Clause
# Copyright 2022, Tarantool AUTHORS, please see AUTHORS file.

# A helper function to compile *.lua source into *.lua.c sources.
function(lua_source varname filename symbolname)
    if (IS_ABSOLUTE "${filename}")
        string (REPLACE "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}"
            genname "${filename}")
        set (srcfile "${filename}")
        set (tmpfile "${genname}.new.c")
        set (dstfile "${genname}.c")
    else(IS_ABSOLUTE "${filename}")
        set (srcfile "${CMAKE_CURRENT_SOURCE_DIR}/${filename}")
        set (tmpfile "${CMAKE_CURRENT_BINARY_DIR}/${filename}.new.c")
        set (dstfile "${CMAKE_CURRENT_BINARY_DIR}/${filename}.c")
    endif(IS_ABSOLUTE "${filename}")
    get_filename_component(_name ${dstfile} NAME)
    string(REGEX REPLACE "${_name}$" "" dstdir ${dstfile})
    if (IS_DIRECTORY ${dstdir})
    else()
        file(MAKE_DIRECTORY ${dstdir})
    endif()

    add_custom_command(OUTPUT ${dstfile}
        COMMAND ${ECHO} 'const char ${symbolname}[] =' > ${tmpfile}
        COMMAND ${PROJECT_BINARY_DIR}/extra/txt2c ${srcfile} >> ${tmpfile}
        COMMAND ${ECHO} '\;' >> ${tmpfile}
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${tmpfile} ${dstfile}
        COMMAND ${CMAKE_COMMAND} -E remove ${tmpfile}
        DEPENDS ${srcfile} txt2c ${LUA_LIBRARIES})

    set(var ${${varname}})
    set(${varname} ${var} ${dstfile} PARENT_SCOPE)
endfunction()
