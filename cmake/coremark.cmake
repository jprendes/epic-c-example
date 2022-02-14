include(ExternalProject)
include(cmake/utils.cmake)

ExternalProject_Add(coremark-src
    URL https://github.com/eembc/coremark/archive/refs/heads/main.zip
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/coremark-src
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)
get_project_prop(coremark-src SOURCE_DIR COREMARK_DIR)
