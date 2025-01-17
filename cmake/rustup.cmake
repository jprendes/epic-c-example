include(ExternalProject)

if ( NOT RUSTUP_DIR )

set(RUSTUP_HOME ${CMAKE_CURRENT_BINARY_DIR}/install/.rustup)
set(CARGO_HOME ${CMAKE_CURRENT_BINARY_DIR}/install/.cargo)
set(RUSTUP env RUSTUP_HOME=${RUSTUP_HOME} CARGO_HOME=${CARGO_HOME} PATH=${CARGO_HOME}/bin:$ENV{PATH})

ExternalProject_Add(rustup
    URL https://sh.rustup.rs
    DOWNLOAD_NO_EXTRACT true
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/rustup
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ${RUSTUP} sh ../sh.rustup.rs -y --no-modify-path --default-toolchain nightly
    INSTALL_COMMAND ""
    USES_TERMINAL_CONFIGURE true
    USES_TERMINAL_BUILD true
    USES_TERMINAL_INSTALL true
)

else()

add_custom_target(rustup)

set(RUSTUP_HOME ${RUSTUP_DIR}/.rustup)
set(CARGO_HOME ${RUSTUP_DIR}/.cargo)
set(RUSTUP env RUSTUP_HOME=${RUSTUP_HOME} CARGO_HOME=${CARGO_HOME} PATH=${CARGO_HOME}/bin:$ENV{PATH})

endif()