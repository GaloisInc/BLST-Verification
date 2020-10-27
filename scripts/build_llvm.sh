#!/bin/sh
set -e

mkdir -p build/llvm
rm -r build/llvm
cp -r blst build/llvm
cd build/llvm

for p in /workdir/patches/*
do
  patch -f -p1 -t < "$p" # -f to prevent patch from automatically enabling option -R when it things it should
done

export CFLAGS='-g -fPIC -Wall -Wextra -Werror'
export CC=wllvm
export LLVM_COMPILER=clang
./build.sh
extract-bc --bitcode libblst.a
