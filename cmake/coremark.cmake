include(ExternalProject)

if ( NOT COREMARK_DIR )

ExternalProject_Add(coremark-src
    URL https://github.com/eembc/coremark/archive/refs/heads/main.zip
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/coremark-src/data
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/coremark-src/src
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    USES_TERMINAL_CONFIGURE true
    USES_TERMINAL_BUILD true
    USES_TERMINAL_INSTALL true
)
set(COREMARK_DIR ${CMAKE_CURRENT_BINARY_DIR}/coremark-src/src)

else()

add_custom_target(coremark-src)

endif()