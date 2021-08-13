#!/bin/sh
set -e

build () {
    (
        mkdir -p "build/$1"
        rm -r "build/$1"
        cp -r "$2" "build/$1"
        cd "build/$1"

        if [ "$2" = blst ]; then
            for p in ../../patches/*
            do
                patch -f -p1 -t < "$p" # -f to prevent patch from automatically enabling option -R when it thinks it should
            done
        fi

        export CFLAGS="-g -fPIC -Wall -Wextra -Werror $3"
        export CC=wllvm
        export LLVM_COMPILER=clang
        sed -i'' 's/^CFLAGS=/# CFLAGS=/' build.sh
        ./build.sh


        if [ "$2" = blst ]; then
            cp ../../proof/bls_operations.c .
            cp bindings/*.h .
            wllvm -c bls_operations.c
            ar rcs libblst.a bls_operations.o
        fi
        extract-bc --bitcode libblst.a
    )
}

build llvm blst '-D__ADX__'
build llvm_noadx blst
build llvm_recent blst_recent '-D__ADX__'
build llvm_noadx_recent blst_recent
build llvm_bulk_addition blst_bulk_addition '-D__ADX__'
