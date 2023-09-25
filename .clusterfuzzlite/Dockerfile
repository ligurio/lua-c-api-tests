#
# SPDX-License-Identifier: ISC
# Copyright 2023, Sergey Bronnikov.
#
################################################################################

FROM gcr.io/oss-fuzz-base/base-builder:v1

RUN apt-get update && apt-get install -y \
	build-essential ninja-build cmake make \
	libreadline-dev libunwind-dev zlib1g-dev

RUN git clone --recursive https://github.com/ligurio/lua-c-api-tests testdir
WORKDIR $SRC/testdir
RUN git clone --depth 1 --jobs $(nproc) https://github.com/ligurio/lua-c-api-corpus corpus_dir
COPY .clusterfuzzlite/build.sh $SRC/
