set(test_name luaL_loadbuffer_proto_test)

add_executable(${test_name}
               luaL_loadbuffer_proto_test.cc
               serializer.cc)

add_library(lua_grammar-proto)

foreach(lib ${LPM_LIBRARIES})
    find_library(${lib} REQUIRED_FILES)
endforeach(lib)

protobuf_generate(LANGUAGE cpp
                  TARGET lua_grammar-proto
                  PROTOS lua_grammar.proto)

target_link_libraries(lua_grammar-proto
                      ${PROTOBUF_LIBRARIES})

target_include_directories(${test_name} PUBLIC ${CMAKE_CURRENT_BINARY_DIR} ${LUA_INCLUDE_DIR})

target_link_libraries(${test_name}
                      PUBLIC
                      lua_grammar-proto
                      ${LPM_LIBRARIES}
                      ${LUA_LIBRARIES}
                      fuzzer_config)

add_dependencies(${test_name}
                 ${LUA_TARGET}
                 ${LPM_LIBRARIES}
                 lua_grammar-proto)

string(REPLACE "_test" "" test_prefix ${test_name})
add_test(NAME ${test_name}
         COMMAND ${CMAKE_CURRENT_BINARY_DIR}/${test_name}
                 -use_value_profile=1
                 -report_slow_units=5
                 -reload=1
                 -reduce_inputs=1
                 -print_pcs=1
                 -print_final_stats=1
                 -mutate_depth=20
                 -runs=5
                 -artifact_prefix=${test_name}_
                 -dict=${PROJECT_SOURCE_DIR}/corpus/${test_prefix}.dict
                 ${PROJECT_SOURCE_DIR}/corpus/${test_prefix}
)
