#
# SPDX-License-Identifier: ISC
# Copyright 2023, Sergey Bronnikov.
#
################################################################################

FROM gcr.io/oss-fuzz-base/base-builder:v1

RUN apt-get update && apt-get install -y \
	build-essential ninja-build cmake make \
	libreadline-dev libunwind-dev zlib1g-dev

COPY . $SRC/lua-c-api-tests
WORKDIR $SRC/lua-c-api-tests
RUN git submodule update --init --recursive --force
COPY .clusterfuzzlite/build.sh $SRC/
