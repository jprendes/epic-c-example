cmake_minimum_required (VERSION 3.10.2)

include(cmake/epic-llvm.cmake)
include(cmake/spike.cmake)
include(cmake/coremark.cmake)
include(cmake/rustup.cmake)
include(cmake/epic-rust.cmake)

project(epic-c-example C ASM)

enable_testing()

set(CMAKE_C_COMPILER ${LLVM_DIR}/bin/clang)
set(CMAKE_ASM_COMPILER ${LLVM_DIR}/bin/clang)
set(ISA "rv32imc")

set(CMAKE_C_FLAGS "--target=riscv32 -march=${ISA} -O3 -mno-relax")
set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "--target=riscv32 -fuse-ld=${LLVM_DIR}/bin/ld.lld -nostdlib -static -mno-relax")

add_subdirectory(app)
add_subdirectory(app-rs)
add_subdirectory(kernel)

add_test(NAME run_kernel
    COMMAND ${SPIKE_DIR}/bin/spike --isa=${ISA} -m0x00002000:0xFFFE000,0x10000000:0x70000000,0x80000000:0x80000000 ${CMAKE_CURRENT_BINARY_DIR}/kernel/kernel
)

add_test(NAME run_kernel-rs
    COMMAND ${SPIKE_DIR}/bin/spike --isa=${ISA} -m0x00002000:0xFFFE000,0x10000000:0x70000000,0x80000000:0x80000000 ${CMAKE_CURRENT_BINARY_DIR}/kernel/kernel-rs
)
