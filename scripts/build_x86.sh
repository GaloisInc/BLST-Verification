#!/bin/sh
set -e

mkdir -p build/x86
rm -r build/x86
cp -r blst build/x86
cd build/x86

export CFLAGS='-g -fPIC -Wall -Wextra -Werror -D__ADX__'
export CC=clang
sed -i'' 's/^trap/# trap/' build.sh
sed -i'' 's/^CFLAGS=/# CFLAGS=/' build.sh
./build.sh -shared
