set(RUSTFLAGS "-C relocation-model=epic -C link-args=-Bstatic -C link-args=--emit-relocs -C link-args=-T -C link-args=${CMAKE_CURRENT_SOURCE_DIR}/../app/app.lds")

cmake_policy(SET CMP0116 NEW)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/riscv32imc-unknown-none-elf/release/app-rs
    COMMAND ${RUSTUP}
        CARGO_TARGET_DIR=${CMAKE_CURRENT_BINARY_DIR}
        CARGO_BUILD_TARGET=riscv32imc-unknown-none-elf
        CARGO_TARGET_RISCV32IMC_UNKNOWN_NONE_ELF_LINKER=${LLVM_DIR}/bin/ld.lld
        RUSTFLAGS=${RUSTFLAGS}
        cargo -v build --release -Zbuild-std=core
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/Cargo.toml epic-llvm epic-rust rustup
    DEPFILE ${CMAKE_CURRENT_BINARY_DIR}/riscv32imc-unknown-none-elf/release/app-rs.d
    USES_TERMINAL
)
add_custom_target(app-rs DEPENDS riscv32imc-unknown-none-elf/release/app-rs)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/app.h
    COMMAND rm -f app
    COMMAND cp app-rs app
    COMMAND xxd -i app app.h
    COMMAND mv app.h ${CMAKE_CURRENT_BINARY_DIR}/
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/riscv32imc-unknown-none-elf/release/
    MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/riscv32imc-unknown-none-elf/release/app-rs
)
add_custom_target(app-rs_h DEPENDS app.h)