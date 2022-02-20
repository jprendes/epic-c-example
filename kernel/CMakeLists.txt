add_executable(kernel)

target_sources(kernel PRIVATE
    init.S
    kernel.c
    htif.c
    elf.c
    tock.c
    util.c
)

add_dependencies(kernel epic-llvm app_h)

target_include_directories(kernel PRIVATE
    kernel
    ${CMAKE_CURRENT_BINARY_DIR}/../app
)
target_compile_definitions(kernel PRIVATE KERNEL)

target_link_options(kernel PRIVATE "-Wl,--emit-relocs,-T,${CMAKE_CURRENT_SOURCE_DIR}/kernel.lds")
set_property(TARGET kernel APPEND PROPERTY LINK_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/kernel.lds)


add_executable(kernel-rs)

target_sources(kernel-rs PRIVATE
    init.S
    kernel.c
    htif.c
    elf.c
    tock.c
    util.c
)

add_dependencies(kernel-rs epic-llvm app-rs_h)

target_include_directories(kernel-rs PRIVATE
    kernel
    ${CMAKE_CURRENT_BINARY_DIR}/../app-rs
)
target_compile_definitions(kernel-rs PRIVATE KERNEL)

target_link_options(kernel-rs PRIVATE "-Wl,--emit-relocs,-T,${CMAKE_CURRENT_SOURCE_DIR}/kernel.lds")
set_property(TARGET kernel-rs APPEND PROPERTY LINK_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/kernel.lds)