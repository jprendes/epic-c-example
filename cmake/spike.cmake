include(ExternalProject)
include(ProcessorCount)
include(cmake/utils.cmake)

ProcessorCount(NPROC)
if(NPROC EQUAL 0)
  set(NPROC 1)
endif()

ExternalProject_Add(spike
    URL https://github.com/riscv-software-src/riscv-isa-sim/archive/refs/heads/master.zip
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/spike
    CONFIGURE_COMMAND ../spike/configure
    BUILD_COMMAND make -j${NPROC}
    INSTALL_COMMAND ""
)
get_project_prop(spike BINARY_DIR SPIKE_DIR)