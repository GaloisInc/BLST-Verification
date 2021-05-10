#!/bin/sh
set -e

build () {
    (
        mkdir -p "build/$1"
        rm -r "build/$1"
        cp -r "$2" "build/$1"
        cd "build/$1"

        if [ "$2" = blst ]; then
            patch -f -p1 -t < ../../patches/noxmmptr.patch
            patch -f -p1 -t < ../../patches/sgn0_pty_mod_384x.patch
        fi

        export CFLAGS="-g -fPIC $3"
        # export CFLAGS="-g -fPIC -Wall -Wextra -Werror $3"
        export CC=clang
        sed -i'' 's/^trap/# trap/' build.sh
        sed -i'' 's/^CFLAGS=/# CFLAGS=/' build.sh
        ./build.sh -shared
    )
}

build x86 blst '-D__ADX__'
build x86_noadx blst
build x86_recent blst_recent '-D__ADX__'
build x86_noadx_recent blst_recent
