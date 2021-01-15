#!/bin/sh
set -e

(
    mkdir -p build/llvm
    rm -r build/llvm
    cp -r blst build/llvm
    cd build/llvm

    for p in /workdir/patches/*
    do
        patch -f -p1 -t < "$p" # -f to prevent patch from automatically enabling option -R when it things it should
    done

    export CFLAGS='-g -fPIC -Wall -Wextra -Werror -D__ADX__'
    export CC=wllvm
    export LLVM_COMPILER=clang
    sed -i'' 's/^CFLAGS=/# CFLAGS=/' build.sh
    ./build.sh
    extract-bc --bitcode libblst.a
)

(
    mkdir -p build/llvm_noadx
    rm -r build/llvm_noadx
    cp -r blst build/llvm_noadx
    cd build/llvm_noadx

    for p in /workdir/patches/*
    do
        patch -f -p1 -t < "$p"
    done

    export CFLAGS='-g -fPIC -Wall -Wextra -Werror'
    export CC=wllvm
    export LLVM_COMPILER=clang
    sed -i'' 's/^CFLAGS=/# CFLAGS=/' build.sh
    ./build.sh
    extract-bc --bitcode libblst.a
)
