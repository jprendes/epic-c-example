include(ExternalProject)
include(ProcessorCount)

if ( NOT SPIKE_DIR )

ProcessorCount(NPROC)
if(NPROC EQUAL 0)
    set(NPROC 1)
endif()

ExternalProject_Add(spike
    URL https://github.com/riscv-software-src/riscv-isa-sim/archive/refs/heads/master.zip
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/spike
    CONFIGURE_COMMAND ../spike/configure --prefix=${CMAKE_CURRENT_BINARY_DIR}/install
    BUILD_COMMAND make -j${NPROC}
    INSTALL_COMMAND make install
    USES_TERMINAL_CONFIGURE true
    USES_TERMINAL_BUILD true
    USES_TERMINAL_INSTALL true
)
set(SPIKE_DIR ${CMAKE_CURRENT_BINARY_DIR}/install)

else()

add_custom_target(spike)

endif()