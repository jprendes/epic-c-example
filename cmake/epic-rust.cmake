include(ExternalProject)

if ( NOT RUST_DIR )

file(GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/epic-rust.config.toml
CONTENT 
"
[install]
prefix=\"${CMAKE_CURRENT_BINARY_DIR}/install\"
sysconfdir=\"etc\"

[llvm]
ninja=true
targets=\"RISCV;X86\"
experimental-targets=\"\"

[target.x86_64-unknown-linux-gnu]
cc=\"clang\"
cxx=\"clang++\"
"
)

ExternalProject_Add(epic-rust
    URL https://github.com/jprendes/rust/releases/download/epic-rust/epic-rust-with-submodules.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/rust
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND rm -f ./config.toml
        && ../epic-rust/x.py setup codegen
        && cat ${CMAKE_CURRENT_BINARY_DIR}/epic-rust.config.toml >> ./config.toml
    BUILD_COMMAND ../epic-rust/x.py build
    INSTALL_COMMAND ../epic-rust/x.py install
        && ../epic-rust/x.py install src
        && ${RUSTUP} rustup toolchain link epic ${CMAKE_CURRENT_BINARY_DIR}/install
    # USES_TERMINAL_CONFIGURE true # Setting this to true will result in x.py prompting if we want to install the git hooks
    USES_TERMINAL_BUILD true
    USES_TERMINAL_INSTALL true
    DEPENDS rustup
)

set(RUST_DIR ${CMAKE_CURRENT_BINARY_DIR}/install)
set(RUSTUP ${RUSTUP} RUSTUP_TOOLCHAIN=epic)

else()

add_custom_command(OUTPUT ${RUSTUP_HOME}/toolchains/epic
    COMMAND ${RUSTUP} rustup toolchain link epic ${RUST_DIR}
)
add_custom_target(epic-rust DEPENDS ${RUSTUP_HOME}/toolchains/epic)
add_dependencies(epic-rust rustup)
set(RUSTUP ${RUSTUP} RUSTUP_TOOLCHAIN=epic)

endif()