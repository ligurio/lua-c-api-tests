set(test_name luaL_loadbuffer_proto_test)

add_library(lua_grammar-proto)

foreach(lib ${LPM_LIBRARIES})
    find_library(${lib} REQUIRED_FILES)
endforeach(lib)

protobuf_generate(LANGUAGE cpp
                  TARGET lua_grammar-proto
                  PROTOS lua_grammar.proto)

target_link_libraries(lua_grammar-proto
                      ${PROTOBUF_LIBRARIES})

create_test(FILENAME ${test_name}
            SOURCES luaL_loadbuffer_proto_test.cc serializer.cc
            LIBRARIES lua_grammar-proto ${LPM_LIBRARIES})

target_include_directories(${test_name} PUBLIC ${CMAKE_CURRENT_BINARY_DIR} ${LUA_INCLUDE_DIR})
add_dependencies(${test_name} ${LPM_LIBRARIES} lua_grammar-proto)
