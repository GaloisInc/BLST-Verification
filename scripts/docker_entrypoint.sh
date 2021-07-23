#!/bin/sh
set -e # exit immediately if a command fails

export PATH=/workdir/bin:$PATH

if [ "$1" != "check" ]; then
    ./scripts/build_llvm.sh
    ./scripts/build_x86.sh
    echo "Proving C and assembly functions"
    ./scripts/prove.sh "$1"
fi
if [ -z "$1" ] || [ "$1" = "check" ]; then
    echo "Validating Cryptol specifications"
    ./scripts/check.sh | if grep False; then exit 1; fi # look for any failed checks
fi
