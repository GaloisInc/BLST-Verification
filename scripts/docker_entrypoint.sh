#!/bin/sh
set -e # exit immediately if a command fails

export PATH=/workdir/bin:$PATH

./scripts/build_llvm.sh
./scripts/build_x86.sh
./scripts/prove.sh
