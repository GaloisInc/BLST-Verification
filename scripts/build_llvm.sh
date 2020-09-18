#!/bin/sh
set -e

mkdir -p build/llvm
rm -r build/llvm
cp -r blst build/llvm
cd build/llvm

for p in `ls /workdir/patches`
do
  patch -p1 -t < /workdir/patches/"$p"
done

export CFLAGS='-g -fPIC -Wall -Wextra -Werror'
export CC=wllvm
export LLVM_COMPILER=clang
./build.sh
extract-bc --bitcode libblst.a
