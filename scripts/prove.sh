#!/bin/sh
set -e

err_handler () {
    [ $? -eq 0 ] && exit
    echo "Verification failed"
}

trap err_handler EXIT

saw proof/memory_safety.saw
saw proof/keygen.saw

echo "All functions under verification were verified successfully"
