#!/bin/sh
set -e # exit immediately if a command fails

export PATH=/workdir/bin:$PATH

./scripts/build_llvm.sh
./scripts/prove.sh
