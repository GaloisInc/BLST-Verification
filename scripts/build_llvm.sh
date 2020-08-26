#!/bin/sh
set -e

export LLVM_COMPILER=clang

wllvm -g -march=native -mno-avx -c /workdir/blst/src/server.c
wllvm -g -march=native -mno-avx -c /workdir/blst/build/assembly.S
extract-bc /workdir/server.o
