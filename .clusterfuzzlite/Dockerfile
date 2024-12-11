#
# SPDX-License-Identifier: ISC
# Copyright 2023-2024, Sergey Bronnikov.
#
################################################################################

FROM gcr.io/oss-fuzz-base/base-builder:v1

RUN apt-get update && apt-get install -y \
	build-essential ninja-build cmake make \
	libreadline-dev libunwind-dev zlib1g-dev \
	protobuf-compiler libprotobuf-dev

COPY . $SRC/lua-c-api-tests
WORKDIR $SRC/lua-c-api-tests
RUN git clone --depth 1 --branch cfl https://github.com/ligurio/lua-c-api-corpus corpus
COPY .clusterfuzzlite/build.sh $SRC/
