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

FROM ubuntu:20.04 as base

# Install dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates gnupg build-essential python wget subversion unzip ninja-build cmake device-tree-compiler git clang lld python3 zlib1g zlib1g-dev xxd

ENV LLVM_DIR="/riscv-tools/llvm"
ENV SPIKE_DIR="/riscv-tools/spike"
ENV COREMARK_DIR="/src/coremark"
ENV EXAMPLE_DIR="/src/epic-c-example"

# Copy across the repository and set it as the working directory.
ADD . "${EXAMPLE_DIR}"
WORKDIR "${EXAMPLE_DIR}"

# Build epic-llvm. This will take some time.
FROM base as epic-llvm
RUN cmake -B /tmp/epic-llvm -S . && \
    cmake --build /tmp/epic-llvm --target epic-llvm --parallel $(nproc) && \
    mkdir -p $(dirname ${LLVM_DIR}) && \
    mv -f "/tmp/epic-llvm/install" "${LLVM_DIR}"

# Build spike
FROM base as spike
RUN cmake -B /tmp/spike -S . && \
    cmake --build /tmp/spike --target spike --parallel $(nproc) && \
    mkdir -p $(dirname ${SPIKE_DIR}) && \
    mv -f "/tmp/spike/install" "${SPIKE_DIR}"

# Pre-download coremark's source.
FROM base as coremark-src
RUN cmake -B /tmp/coremark-src -S . && \
    cmake --build /tmp/coremark-src --target coremark-src --parallel $(nproc) && \
    mkdir -p $(dirname ${COREMARK_DIR}) && \
    mv -f "/tmp/coremark-src/coremark-src/src" "${COREMARK_DIR}"

# Set up the example's build environment.
FROM base as demo

COPY --from=epic-llvm "${LLVM_DIR}" "${LLVM_DIR}"
COPY --from=spike "${SPIKE_DIR}" "${SPIKE_DIR}"
COPY --from=coremark-src "${COREMARK_DIR}" "${COREMARK_DIR}"

# Pre-build the example and execute the test
RUN cmake -B ./build -DLLVM_DIR="${LLVM_DIR}" -DSPIKE_DIR="${SPIKE_DIR}" -DCOREMARK_DIR="${COREMARK_DIR}" && \
    cmake --build ./build --parallel $(nproc) && \
    cmake --build ./build --target test