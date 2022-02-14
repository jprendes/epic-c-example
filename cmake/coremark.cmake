include(FetchContent)

FetchContent_Declare(coremark-src
    URL https://github.com/eembc/coremark/archive/refs/heads/main.zip
)
FetchContent_MakeAvailable(coremark-src)
FetchContent_GetProperties(coremark-src SOURCE_DIR COREMARK_DIR)