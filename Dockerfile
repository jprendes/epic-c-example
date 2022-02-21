# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Set up a development environment for the ePIC C example.
#
# Typical workflow for building the image and starting container:
#
#   sudo docker build -t epic-c-example .
#   sudo docker run --rm -it epic-c-example /bin/bash
#
# Once inside container simply run make. This will take signficant time,
# memory and disk space because LLVM is built as part of the example.
#
#   make

FROM ubuntu:22.04 as base

# Install dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        clang \
        cmake \
        curl \
        device-tree-compiler \
        git \
        gnupg \
        lld \
        ninja-build \
        python-is-python3 \
        python2 \
        python3 \
        subversion \
        unzip \
        wget \
        xxd \
        zlib1g \
        zlib1g-dev

ENV LLVM_DIR="/riscv-tools/llvm"
ENV SPIKE_DIR="/riscv-tools/spike"
ENV RUSTUP_DIR="/riscv-tools/rustup"
ENV RUST_DIR="/riscv-tools/rust"

ENV COREMARK_DIR="/src/coremark"
ENV EXAMPLE_DIR="/src/epic-c-example"

# Copy across the repository and set it as the working directory.
ADD . "${EXAMPLE_DIR}"
WORKDIR "${EXAMPLE_DIR}"

# Build epic-llvm. This will take some time.
FROM base as epic-llvm
RUN cmake -B /tmp/epic-llvm -S . \
    && cmake --build /tmp/epic-llvm --target epic-llvm --parallel $(nproc) \
    && mkdir -p $(dirname ${LLVM_DIR}) \
    && mv -f "/tmp/epic-llvm/install" "${LLVM_DIR}"

# Build spike
FROM base as spike
RUN cmake -B /tmp/spike -S . \
    && cmake --build /tmp/spike --target spike --parallel $(nproc) \
    && mkdir -p $(dirname ${SPIKE_DIR}) \
    && mv -f "/tmp/spike/install" "${SPIKE_DIR}"

# Install rustup
FROM base as rustup
RUN cmake -B /tmp/rustup -S . \
    && cmake --build /tmp/rustup --target rustup --parallel $(nproc) \
    && mkdir -p $(dirname ${RUSTUP_DIR}) \
    && mv -f "/tmp/rustup/install" "${RUSTUP_DIR}"

# Install rust
FROM base as epic-rust
RUN cmake -B /tmp/epic-rust -S . \
    && cmake --build /tmp/epic-rust --target epic-rust --parallel $(nproc) \
    && mkdir -p $(dirname ${RUST_DIR}) \
    && mv -f "/tmp/epic-rust/install" "${RUST_DIR}"

# Pre-download coremark's source.
FROM base as coremark-src
RUN cmake -B /tmp/coremark-src -S . \
    && cmake --build /tmp/coremark-src --target coremark-src --parallel $(nproc) \
    && mkdir -p $(dirname ${COREMARK_DIR}) \
    && mv -f "/tmp/coremark-src/coremark-src/src" "${COREMARK_DIR}"

# Set up the example's build environment.
FROM base as demo

COPY --from=epic-llvm "${LLVM_DIR}" "${LLVM_DIR}"
COPY --from=spike "${SPIKE_DIR}" "${SPIKE_DIR}"
COPY --from=rustup "${RUSTUP_DIR}" "${RUSTUP_DIR}"
COPY --from=epic-rust "${RUST_DIR}" "${RUST_DIR}"
COPY --from=coremark-src "${COREMARK_DIR}" "${COREMARK_DIR}"

# Pre-build the example and execute the test
RUN cmake -B ./build \
        -DLLVM_DIR="${LLVM_DIR}" \
        -DSPIKE_DIR="${SPIKE_DIR}" \
        -DRUSTUP_DIR="${RUSTUP_DIR}" \
        -DRUST_DIR="${RUST_DIR}" \
        -DCOREMARK_DIR="${COREMARK_DIR}" \
    && cmake --build ./build --parallel $(nproc) \
    && ctest --test-dir ./build
