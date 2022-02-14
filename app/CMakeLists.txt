add_executable(app)

add_dependencies(app epic-llvm coremark-src)

set(COREMARK_SOURCES
    ${COREMARK_DIR}/core_list_join.c
    ${COREMARK_DIR}/core_main.c
    ${COREMARK_DIR}/core_matrix.c
    ${COREMARK_DIR}/core_state.c
    ${COREMARK_DIR}/core_util.c
)

target_compile_options(app PRIVATE "-fepic")
target_include_directories(app PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../kernel
    coremark-port
    ${COREMARK_DIR}
)
target_compile_definitions(app PRIVATE
    COMPILER_FLAGS="${CMAKE_C_FLAGS}"
    ITERATIONS=100
)
set_source_files_properties(${COREMARK_SOURCES} PROPERTIES GENERATED TRUE)
target_sources(app PRIVATE
    ../kernel/htif.c
    coremark-port/core_portme.c
    coremark-port/cvt.c
    coremark-port/ee_printf.c
    ${COREMARK_SOURCES}
)

target_link_options(app PRIVATE "-Wl,--emit-relocs,-T,${CMAKE_CURRENT_SOURCE_DIR}/app.lds")
set_property(TARGET app APPEND PROPERTY LINK_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/app.lds)

add_custom_command(TARGET app POST_BUILD
    COMMAND cd ${CMAKE_CURRENT_BINARY_DIR} && xxd -i app app.h
)
