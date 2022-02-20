include(ExternalProject)

if ( NOT RUST_DIR )

ExternalProject_Add(epic-rust
    GIT_REPOSITORY https://github.com/jprendes/rust.git
    GIT_TAG master
    GIT_SHALLOW true
    GIT_PROGRESS true
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/rust
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND rm -f ./config.toml && ../epic-rust/x.py setup codegen
    BUILD_COMMAND ../epic-rust/x.py build
    INSTALL_COMMAND ${RUSTUP} rustup toolchain link epic build/x86_64-unknown-linux-gnu/stage1
    # USES_TERMINAL_CONFIGURE true # Setting this to true will result in x.py prompting if we want to install the git hooks
    USES_TERMINAL_BUILD true
    USES_TERMINAL_INSTALL true
    DEPENDS rustup
)

set(RUST_DIR ${CMAKE_CURRENT_BINARY_DIR}/install)
set(RUSTUP ${RUSTUP} RUSTUP_TOOLCHAIN=epic)

else()

add_custom_target(epic-rust)

endif()