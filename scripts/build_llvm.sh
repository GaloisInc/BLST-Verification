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
                patch -f -p1 -t < "$p" # -f to prevent patch from automatically enabling option -R when it things it should
            done
        fi

        export CFLAGS="-g -fPIC -Wall -Wextra -Werror $3"
        export CC=wllvm
        export LLVM_COMPILER=clang
        sed -i'' 's/^CFLAGS=/# CFLAGS=/' build.sh
        ./build.sh
        extract-bc --bitcode libblst.a
    )
}

build llvm blst '-D__ADX__'
build llvm_noadx blst
build llvm_patched blst_patched '-D__ADX__'
build llvm_noadx_patched blst_patched
